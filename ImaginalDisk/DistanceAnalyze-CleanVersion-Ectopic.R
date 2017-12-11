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

folders<-list(path=c("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/NoFoldExperiment-TimeVaryingData/29C26H/Control/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/NoFoldExperiment-TimeVaryingData/29C26H/Experimental/"),
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
  pd <- as.numeric(quantile(Table$d,c(0.025,0.975)))
  Table$d[which(Table$d<pd[1])] <- pd[1]
  Table$d[which(Table$d>pd[2])] <- pd[2]
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
  Global <- rbind(Global,Table)
  id <- id + 1
}

Global$NormdBin <- findInterval(Global$Normd, seq(0.0,1.0,length.out=10))

Global$Cond <- as.factor(Global$Cond)

q <- summarySE(Global, "Dividing", c("NormdBin","Cond"))

vertical_refs_29C26h = data.frame(pos=10*c(0.368,0.535,0.520,0.417,0.517))
vertical_refs_29C39h = data.frame(pos=10*c(0.344,0.400,0.277,0.220,0.200))

fig <- ggplot(q) + geom_errorbar(aes(x=NormdBin,ymin=Dividing-ci,ymax=Dividing+ci), width=0.5,position=position_dodge(.9)) +
  geom_point(aes(NormdBin,Dividing,col=Cond),size=2) +
  scale_x_continuous(name='Distance (%)',breaks=seq(1,10,length.out=10),labels=paste(seq(0,90,10),seq(10,100,10),sep='-')) +
  theme_bw() + coord_cartesian(ylim=c(0.0,0.5)) +
  geom_vline(data=vertical_refs_29C26h,aes(xintercept=pos))

pdf("~/Desktop/ImaginalDisk/Curve1_new.pdf",width = 8, height = 5,useDingbats=F); fig; dev.off()

#
# Test limits of "distance"
#

dplots <- list()
for (text in unique(paste(Threshold$folder,Threshold$file,sep='.'))) {
  RootFolder <- strsplit(text,'\\.')[[1]][1]
  Cond <- strsplit(RootFolder,'/')
  Cond <- Cond[[1]][length(Cond[[1]])]
  name <- strsplit(text,'\\.')[[1]][2]
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results.txt",sep=""),header = F))
  names(Table) <- c("x","y","z","d","dapi","edu")
  pd <- as.numeric(quantile(Table$d,c(0.025,0.975)))
  Table$d[which(Table$d<pd[1])] <- pd[1]
  Table$d[which(Table$d>pd[2])] <- pd[2]
  dplots[[text]] <- ggplot(Table) + geom_histogram(aes(x=d)) + ggtitle(name)
}

do.call("grid.arrange", c(dplots, ncol=2))
