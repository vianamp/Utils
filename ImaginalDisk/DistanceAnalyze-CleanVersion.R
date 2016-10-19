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

tEduDAPI <- 50
nGroups <- 5
gylim <- 0.005

folders<-list(path=c("/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/VeryEarlyInstar/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/EarlyInstar/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/LateInstar/",
                     "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/Feb2016/WT2/"),
              name=c("VeryEarlyInstar","EarlyInstar","LateInstar","OldWTData"))

Sizes <- NULL

for(RootFolder in folders$path){

  S <- data.frame(read.table(paste(RootFolder,"Sizes.txt",sep=""),header = T,sep=","))
  S$AreaFlat <- S$AreaFlat * (0.1317882^2)
  S$AreaFold <- S$AreaFold * (0.1317882^2)
  S$Data <- folders$name[which(folders$path==RootFolder)]

  Sizes <- rbind(Sizes, S)
}

# Fold extension

FoldExt <- NULL

for(RootFolder in folders$path) {

  FE <- data.frame(read.table(paste(RootFolder,"FoldExtension.txt",sep=""),header = T,sep=","))

  #FE$FoldExtensionP <- TransformIntoPercentageInterval(FE$FoldExtension)

  FoldExt <- rbind(FoldExt,FE)
  
}

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
  Table <- within(Table,Disk<-name)

  if (length(which(FoldExt$Disk==name)) > 0) {
    Table$FoldExt <- FoldExt$FoldExtension[which(FoldExt$Disk==name)]
  } else {
    Table$FoldExt <- NA
  }
  
  Global <- rbind(Global,Table)
  id <- id + 1
}

Groups <- sort(rep(seq(1,nGroups,1),nrow(Sizes)/nGroups))
if (length(Groups) < nrow(Sizes)) {
  Groups <- c(rep(Groups[1],times=nrow(Sizes)-length(Groups)),Groups)
}
Sizes$Class[order(Sizes$AreaFold)] <- Groups

Global$Class <- Sizes$Class[match(Global$Disk,Sizes$Disk)]

ggplot(Global) + geom_point(aes(x=Normd,y=Prol),size=2) + 
  #coord_cartesian(ylim = c(0,1)) + ggtitle(name) +
  geom_vline(aes(xintercept=FoldExt))+
  facet_wrap(~Class)

save(Global,file = "~/Dropbox/global.RData")
