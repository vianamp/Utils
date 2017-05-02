#
# Analysis of imaginal disk data
#
# Ectopic Experiment data
#

rm(list=ls(all=TRUE))

library(plyr)
library(tidyr)
library(MASS)
library(scales)
library(ggplot2)
library(gridExtra)

TransformIntoPercentageInterval <- function(Vec) {
  Vec <- factor(     x = Vec,
                     levels = seq(0,9,1),
                     labels = paste(seq(0,90,10),'%','-',seq(10,100,10),'%',sep=""))
  return(Vec)
}

RollingAverageXY <- function(table,varx,vary,varclass,n) {
  idx <- which(names(table)==varx)
  idy <- which(names(table)==vary)
  idclass <- which(names(table)==varclass)
  
  Q <- NULL
  for (group in levels(table[,idclass])) {
    
    or_data <- table[which(table[,idclass]==group),c(idx,idy)]
    data <- or_data
    data[,1] <- scale(or_data[,1])[,1]
    data[,2] <- scale(or_data[,2])[,1]
    v <- cov.trob(data)
    center <- v$center
    if (summary(lm(data[,2]~data[,1]))$coefficients[2,4] < 0.04) {
      chol_decomp <- chol(v$cov)
      segments <- 501    
      angles <- (0:segments) * 1 * pi/segments
      unit.circle <- cbind(cos(angles), sin(angles))
      ellipse <- data.frame(t(t(unit.circle %*% chol_decomp)))
      angle <- angles[which.max(sqrt(ellipse[,1]^2+ellipse[,2]^2))]      
    } else {
      angle <- 0
    }
    
    data$rx <-  (data[,1]-center[1])*cos(angle) + (data[,2]-center[2])*sin(angle)
    data$ry <- -(data[,1]-center[1])*sin(angle) + (data[,2]-center[2])*cos(angle)
    
    o <- order(data$rx)
    
    N <- nrow(data)
    for (i in seq(n+1,length(o)-n,n)) {
      xm <- mean(or_data[o[(i-n):(i+n)],1])
      xs <-   sd(or_data[o[(i-n):(i+n)],1])
      xc <- xs / sqrt(N) * qt(0.95/2 + .5, N-1)  
      ym <- mean(or_data[o[(i-n):(i+n)],2])
      ys <-   sd(or_data[o[(i-n):(i+n)],2])
      yc <- ys / sqrt(N) * qt(0.95/2 + .5, N-1)  
      Q <- rbind(Q,data.frame(x=xm,sdx=xs,xci=xc,y=ym,sdy=ys,yci=yc,group=group))
    }
  }
  
  names(Q)[c(1,4,7)] <- c(names(or_data),varclass)
  
  return(Q)
}

summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE, conf.interval=.95, .drop=TRUE) {
  
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) {
      sum(!is.na(x))
    } else {
      length(x)
    }
  }
  
  datac <- ddply(data, groupvars, .drop=.drop, .fun =
                   function(xx, col) {
                     c(N = length2(xx[[col]], na.rm=na.rm),
                       mean = mean (xx[[col]], na.rm=na.rm),
                       sd = sd (xx[[col]], na.rm=na.rm))
                   },
                 measurevar
  )
  
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)
  
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

CreateNormAttribute <- function(Table,name) {
  id <- which(names(Table)==name)
  r <- range(Table[,id])
  Table <- within(Table,NewAtt<-(Table[,id]-r[1])/(r[2]-r[1]))
  names(Table)[ncol(Table)] <- paste("Norm",name,sep="")
  return(Table)
}

tEduDAPI <- 50
nGroups <- 3
gylim <- 0.2

folders<-list(path=c("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C13H/Control/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/EctopicExperiment_new/Temp/29C13H/Experimental/"),
              name=c("Ctrl",
                     "Exp"))

# Edu-to-DAPI thresholds

Threshold <- NULL
for(RootFolder in folders$path) {
  
  ratios <- list.files(path = RootFolder, pattern = "\\-Ratio.txt$")
  
  TH <- NULL
  for (name in ratios) {
    Table <- read.table(file = paste(RootFolder,"/",name,sep=""),header = F,skip = 1)
    Table <- data.frame(EDU=Table$V2[1:(nrow(Table)/2)],DAPI=Table$V2[(nrow(Table)/2+1):nrow(Table)])
    temp <- strsplit(name,"-")
    if (length(temp[[1]])==2) {
      temp <- temp[[1]][1]
    } else {
      temp <- paste(temp[[1]][1],"-",temp[[1]][2],sep="")
    }
    TH <- rbind(TH,data.frame(ratio=Table$EDU/Table$DAPI,file=temp,folder=RootFolder))
  }
  Threshold <- rbind(Threshold,TH)
}  

fig <- ggplot(Threshold) + geom_boxplot(aes(x=file,y=ratio,fill=file)) + theme_bw() +
  theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 0)) +
  ggtitle(paste("global average = ",mean(Threshold$ratio),sep="")) +
  coord_cartesian(ylim = c(0,5))

pdf("~/Desktop/ImaginalDisk/EduDapiRatios.pdf",width = 16, height = 8,useDingbats=F); fig; dev.off()

id <- 1
Fig <- list()
Global <- NULL
for (text in unique(paste(Threshold$folder,Threshold$file,sep='.'))) {
  
  RootFolder <- strsplit(text,'\\.')[[1]][1]
  Cond <- strsplit(RootFolder,'/')
  Cond <- Cond[[1]][length(Cond[[1]])]
  name <- strsplit(text,'\\.')[[1]][2]
  
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results.txt",sep=""),header = F))
  names(Table) <- c("x","y","z","d","dapi","edu")
  
  thresh <- (tEduDAPI/100)*mean(Threshold$ratio[which(Threshold$file==name)])
  print(thresh)
  
  Table <- CreateNormAttribute(Table,"d")
  Table <- CreateNormAttribute(Table,"dapi")
  Table <- CreateNormAttribute(Table,"edu")
  Table <- within(Table,Prol<-edu/dapi)
  Table <- within(Table,Dividing<-as.numeric(Prol>=thresh))
  #Table$Dividing <- Table$Dividing / sum(Table$Dividing)
  Table <- within(Table,Disk<-name)
  Table <- within(Table,Cond<-Cond)
  
  #if (length(which(FoldExt$Disk==name)) > 0) {
  #  Table$FoldExt <- FoldExt$FoldExtension[which(FoldExt$Disk==name)]
  #} else {
  #  Table$FoldExt <- NA
  #}
  
  Global <- rbind(Global,Table)
  id <- id + 1
}

Global$NormdBin <- findInterval(Global$Normd, seq(0.1,0.9,0.08))

#Q <- list()
#for (c in seq(1,nGroups,1)) {
#  Q[['Table']][[c]] <- summarySE(Global, "Dividing", "NormdBinP")
#  Q[['Folds']][[c]] <- data.frame(FoldExt = nbins * unique(subset(Global,Class==c)$FoldExt))
#}

ggplot(Global) + geom_smooth(aes(Normd,Prol),method='loess') + facet_wrap(~Cond)

Global$Cond <- as.factor(Global$Cond)

q<-summarySE(Global, "Dividing", c("NormdBin","Cond"))

fig <- ggplot(q) + geom_errorbar(aes(x=NormdBin,y=Dividing,ymin=Dividing-ci,ymax=Dividing+ci), width=0.5,position=position_dodge(.9)) +
  geom_point(aes(NormdBin,Dividing,col=Cond),size=2)

pdf("~/Desktop/ImaginalDisk/Curve1.pdf",width = 5, height = 4,useDingbats=F); fig; dev.off()

q <- RollingAverageXY(Global,"Normd","Dividing","Cond",1000)

fig <- ggplot(q) + geom_errorbar(aes(x=Normd,y=Dividing,ymin=Dividing-yci,ymax=Dividing+yci), width=0.05,position=position_dodge(.9)) +
  geom_point(aes(Normd,Dividing,col=Cond),size=2)

pdf("~/Desktop/ImaginalDisk/Curve2.pdf",width = 5, height = 4,useDingbats=F); fig; dev.off()
