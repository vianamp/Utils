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
gylim <- 0.002

folders<-list(path=c("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/EarlyInstar/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/LateInstar/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/Feb2016/WT2/"),
              name=c("EarlyInstar","LateInstar","OldWTData"))

Sizes <- NULL

for(RootFolder in folders$path){

  S <- data.frame(read.table(paste(RootFolder,"Sizes.txt",sep=""),header = T,sep=","))
  S$AreaFlat <- S$AreaFlat * (0.1317882^2)
  S$AreaFold <- S$AreaFold * (0.1317882^2)
  S$Data <- folders$name[which(folders$path==RootFolder)]

  Sizes <- rbind(Sizes, S)
}

# Fold versus flat region area

fig <- ggplot(Sizes) + geom_point(aes(x=AreaFlat,y=AreaFold,col=Data)) + theme_bw() +
  xlab("Flat area (um2)") + ylab("Fold area (um2)")

pdf("~/Desktop/ImaginalDisk/FoldVsFlatArea.pdf",width = 6, height = 6,useDingbats=F); fig; dev.off()

# Fold extension

FoldExt <- NULL

for(RootFolder in folders$path) {

  FE <- data.frame(read.table(paste(RootFolder,"FoldExtension.txt",sep=""),header = T,sep=","))

  FE$FoldExtensionP <- TransformIntoPercentageInterval(FE$FoldExtension)

  FoldExt <- rbind(FoldExt,FE)
  
}

fig <- ggplot(FoldExt) + geom_histogram(aes(x=FoldExtension,y=..count..),binwidth = 0.02) + theme_bw() +
  xlab("Fold extension (%)") + ylab("Count") + coord_cartesian(xlim=c(0,1))

pdf("~/Desktop/ImaginalDisk/FoldExtension.pdf",width = 6, height = 6,useDingbats=F); fig; dev.off()

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
  name <- strsplit(text,'\\.')[[1]][2]
  
  Table <- data.frame(read.table(file = paste(RootFolder,"/",name,"_results.txt",sep=""),header = F))
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
  
  TableS$AreaFold <- Sizes$AreaFold[which(Sizes$Disk==name)]
  
  TableS$Id <- id
  TableS$Disk <- name
  
  Fig[[name]] <- ggplot(TableS,aes(x=Normd,y=ProlFraction)) + geom_point(size=2) + 
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + ggtitle(name) +
    scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  Global <- rbind(Global,TableS)
  id <- id + 1
}

Fig[["global"]] <- ggplot(Global) +
  geom_point(aes(x=Normd,y=ProlFraction,group=1),alpha=0.5,size=1) +
  geom_smooth(aes(x=Normd,y=ProlFraction,group=1),col="red",size=1,method="loess") +
  xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
  coord_cartesian(ylim = c(0,gylim)) + ggtitle("global average") +
  scale_y_continuous(labels = percent)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

pdf(paste("~/Desktop/ImaginalDisk/FracOfDivCells-tEduDAPI",tEduDAPI,".pdf",sep=""),width = 24, height=24,useDingbats=F);
  do.call("grid.arrange", c(Fig, ncol=8))
dev.off()

# Creating nGroups groups of disks based on their fold size

rm(Fig)
Fig <- list()
Fig[["hist1"]] <- ggplot(Sizes) + geom_histogram(aes(x=AreaFold),binwidth=5E2,col="white") +
  theme_bw() + xlab("Fold area (um2)") + ylab("Count") + coord_cartesian(ylim = c(0,30))

Fig[["hist2"]] <- ggplot(Sizes) + geom_histogram(aes(x=AreaFold,y=cumsum(..count..)),binwidth=5E2,col="white") +
  theme_bw() + xlab("Fold area (um2)") + ylab("Cumulative count") + coord_cartesian(ylim = c(0,90))

pdf("~/Desktop/ImaginalDisk/HistFoldArea.pdf",width = 6, height=3,useDingbats=F);
  do.call("grid.arrange", c(Fig, ncol=2))
dev.off()

  # Scheme 1: not even spacing (bins with same number of disks)
  Groups <- sort(rep(seq(1,nGroups,1),nrow(Sizes)/nGroups))
  if (length(Groups) < nrow(Sizes)) {
    Groups <- c(rep(Groups[1],times=nrow(Sizes)-length(Groups)),Groups)
  }
  Sizes$Class[order(Sizes$AreaFold)] <- Groups

  Global$Class <- Sizes$Class[match(Global$Disk,Sizes$Disk)]
  
  Global$FoldExt <- FoldExt$FoldExtension[match(Global$Disk,FoldExt$Disk)]
  
  fig <- ggplot(Global) +
    geom_point(aes(x=Normd,y=ProlFraction,group=Class),alpha=0.5,size=1) +
    geom_smooth(aes(x=Normd,y=ProlFraction,group=Class),col="red",size=1,method="loess") +
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    facet_wrap(~Class,ncol=nGroups)
  
  pdf(paste("~/Desktop/ImaginalDisk/FracOfDivCellsGrouped-nGroups",nGroups,"-tEduDAPI",tEduDAPI,".pdf",sep=""),width = 12, height=5,useDingbats=F); fig; dev.off()

  # Scheme 2: equally spaced bins
  
  Sizes$Class <- findInterval(Sizes$AreaFold, hist(Sizes$AreaFold, breaks=seq(min(Sizes$AreaFold),max(Sizes$AreaFold),l=nGroups),plot = F)$breaks)
  
  Global$Class <- Sizes$Class[match(Global$Disk,Sizes$Disk)]
  
  fig <- ggplot(Global) +
    geom_point(aes(x=Normd,y=ProlFraction,group=Class),alpha=0.5,size=1) +
    geom_smooth(aes(x=Normd,y=ProlFraction,group=Class),col="red",size=1,method="loess") +
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    facet_wrap(~Class,ncol=nGroups)
  
  pdf(paste("~/Desktop/ImaginalDisk/FracOfDivCellsGrouped-EqSpace-nGroups",nGroups,"-tEduDAPI",tEduDAPI,".pdf",sep=""),width = 12, height=5,useDingbats=F); fig; dev.off()
    
  # Marco's format
  
  Global <- Global[with(Global, order(AreaFold,Dist)), ]
  
  Global$Disk <- factor(Global$Disk,levels = Sizes$Disk[order(Sizes$AreaFold)],labels = Sizes$Disk[order(Sizes$AreaFold)])
  
  fig <- ggplot(Global) + geom_line(aes(Dist,ProlFraction,group=Disk,col=AreaFold))+geom_vline(aes(xintercept=FoldExt))+
    scale_colour_gradientn(colours = rainbow(7)) + facet_wrap(~Disk) +
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + ggtitle("global average") +
    scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  pdf(paste("~/Desktop/ImaginalDisk/FracOfDivCells-Color-tEduDAPI",tEduDAPI,".pdf",sep=""),width = 24, height=24,useDingbats=F); fig; dev.off()
  
  fig <- ggplot(Global) + geom_line(aes(Dist,ProlFraction,group=Disk,col=AreaFold))+geom_vline(aes(xintercept=FoldExt))+
    scale_colour_gradientn(colours = rainbow(7)) +
    xlab("distance from the fold") + ylab("fraction of dividing cells") + theme_bw() +
    coord_cartesian(ylim = c(0,gylim)) + ggtitle("global average") +
    scale_y_continuous(labels = percent)+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  pdf(paste("~/Desktop/ImaginalDisk/FracOfDivCells-ColorAllTogether-tEduDAPI",tEduDAPI,".pdf",sep=""),width = 10, height=6,useDingbats=F); fig; dev.off()
  