#Analysis of imaginal disk data
rm(list=ls(all=TRUE))

library(plyr)
library(tidyr)
library(scales)
library(ggplot2)
library(gridExtra)

CreateNormAttribute <- function(Table,name) {
  id <- which(names(Table)==name)
  r <- range(Table[,id])
  Table <- within(Table,NewAtt<-(Table[,id]-r[1])/(r[2]-r[1]))
  names(Table)[ncol(Table)] <- paste("Norm",name,sep="")
  return(Table)
}

TransformIntoPercentageInterval <- function(Vec) {
  Vec <- factor(     x = round(Vec/0.11),
                levels = seq(0,9,1),
                labels = paste(seq(0,90,10),'%','-',seq(10,100,10),'%',sep=""))
  return(Vec)
}

tEduDAPI <- 50
nGroups <- 5
gylim <- 0.001

folders<-list(path=c("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/SentForManualCounting/analysis/sample2/"),
              name=c("Sample1"))

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

id <- 1
Fig <- list()
for (text in unique(paste(Threshold$folder,Threshold$file,sep='.'))) {
  
  RootFolder <- strsplit(text,'\\.')[[1]][1]
  name <- strsplit(text,'\\.')[[1]][2]
  
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results_auto.txt",sep=""),header = F))
  names(Table) <- c("x","y","z","d","dapi","edu")
  
  thresh <- (tEduDAPI/100)*mean(Threshold$ratio[which(Threshold$file==name)])
  print(thresh)
  
  Table <- CreateNormAttribute(Table,"d")
  Table <- CreateNormAttribute(Table,"dapi")
  Table <- CreateNormAttribute(Table,"edu")
  Table <- within(Table,Prol<-edu/dapi)
  Table <- within(Table,Dividing<-Prol>=thresh)
  
  Table$Dist <- Table$Normd
  
  Table$Normd <- TransformIntoPercentageInterval(Table$Normd)
  
  TableS <- ddply(Table,~Normd,summarise,Dist=mean(Dist),NCells=sum(Prol>0),NDividing=sum(Dividing))
  
  TableS <- within(TableS,ProlFraction <- NDividing/(NCells*sum(NDividing)))
  
  TableS$AreaFold <- NA#Sizes$AreaFold[which(Sizes$Disk==name)]
  
  TableS$Id <- id
  TableS$Disk <- name
  
  Fig[['auto']] <- ggplot(TableS,aes(x=Normd,y=ProlFraction)) + geom_point(size=2) + 
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + ggtitle(paste(name,'Auto',sep=' / ')) +
    scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  id <- id + 1
}

TableST <- NULL
for (text in unique(paste(Threshold$folder,Threshold$file,sep='.'))) {
  
  RootFolder <- strsplit(text,'\\.')[[1]][1]
  name <- strsplit(text,'\\.')[[1]][2]
  
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results_person1.txt",sep=""),header = F))
  names(Table) <- c("x","y","z","d","dapi","edu")
  
  thresh <- (tEduDAPI/100)*mean(Threshold$ratio[which(Threshold$file==name)])
  print(thresh)
  
  Table <- CreateNormAttribute(Table,"d")
  Table <- CreateNormAttribute(Table,"dapi")
  Table <- CreateNormAttribute(Table,"edu")
  Table <- within(Table,Prol<-edu/dapi)
  Table <- within(Table,Dividing<-Prol>=thresh)
  
  Table$Dist <- Table$Normd
  
  Table$Normd <- TransformIntoPercentageInterval(Table$Normd)
  
  TableS <- ddply(Table,~Normd,summarise,Dist=mean(Dist),NCells=sum(Prol>0),NDividing=sum(Dividing))
  
  TableS <- within(TableS,ProlFraction <- NDividing/(NCells*sum(NDividing)))

  TableS$Id <- 'person1'
  TableS$Disk <- name

  TableST <- rbind(TableST,TableS)
}

for (text in unique(paste(Threshold$folder,Threshold$file,sep='.'))) {
  
  RootFolder <- strsplit(text,'\\.')[[1]][1]
  name <- strsplit(text,'\\.')[[1]][2]
  
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results_person2.txt",sep=""),header = F))
  names(Table) <- c("x","y","z","d","dapi","edu")
  
  thresh <- (tEduDAPI/100)*mean(Threshold$ratio[which(Threshold$file==name)])
  print(thresh)
  
  Table <- CreateNormAttribute(Table,"d")
  Table <- CreateNormAttribute(Table,"dapi")
  Table <- CreateNormAttribute(Table,"edu")
  Table <- within(Table,Prol<-edu/dapi)
  Table <- within(Table,Dividing<-Prol>=thresh)
  
  Table$Dist <- Table$Normd
  
  Table$Normd <- TransformIntoPercentageInterval(Table$Normd)
  
  TableS <- ddply(Table,~Normd,summarise,Dist=mean(Dist),NCells=sum(Prol>0),NDividing=sum(Dividing))
  
  TableS <- within(TableS,ProlFraction <- NDividing/(NCells*sum(NDividing)))
  
  TableS$Id <- 'person2'
  TableS$Disk <- name
  
  TableST <- rbind(TableST,TableS)
}

Fig[['manual']] <- ggplot(TableST) + geom_point(aes(x=Normd,y=NCells,col=as.factor(Id)),size=2) + 
  xlab("distance from the fold") + ylab("Number of dividing cells") + theme_bw() +
  coord_cartesian(ylim = c(0,50)) + ggtitle(paste(name,'Manual',sep=' / ')) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position='none')

pdf("~/Desktop/ManualCount1.pdf",width = 4, height=6,useDingbats=F);
  do.call("grid.arrange", c(Fig, ncol=1))
dev.off()