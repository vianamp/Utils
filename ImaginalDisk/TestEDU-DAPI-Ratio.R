#Finding the best threshold for each disk

library(plyr)
library(scales)
library(ggplot2)
library(gridExtra)

RootFolder <- "/Volumes/WAILERS/UCI/Collaborators/Marcos/Data/May2016/LateInstar/"

EDUDAPI <- data.frame(read.table(paste(RootFolder,"EDU-DAPI-Ratio.txt",sep=""),header = T))

EDUDAPI$Disk <- as.factor(EDUDAPI$Disk)

EDUDAPI <- within(EDUDAPI,Ratio<-EDU/DAPI)

fig <- ggplot(EDUDAPI) + geom_boxplot(aes(Disk,Ratio,col=Disk),outlier.shape = NA) +
  coord_cartesian(ylim=c(0,2)) + theme_bw() + theme(legend.position="none") +
  ylab("EDU-to-DAPI ratio") + geom_hline(yintercept = mean(EDUDAPI$Ratio)) + 
  geom_hline(yintercept = 0.5*mean(EDUDAPI$Ratio)) + ggtitle(paste("Threshold =",0.5*mean(EDUDAPI$Ratio)))

pdf("~/Desktop/Temp.pdf",width=6,height=6,useDingbats=F);fig;dev.off()

for (disk in levels(EDUDAPI$Disk)) {
  print(paste(disk," = ",0.5*mean(EDUDAPI$Ratio[which(EDUDAPI$Disk==disk)])))
}