library(ggplot2)
library(reshape2)

RootFolder <- "/Users/mviana/Documents/ProjectsPersonal/MoCo/build/temp/MitoGraph/"

Table <- data.frame(read.table(paste(RootFolder,"results.txt",sep=""),header = T,sep = "\t"))

Table <- melt(Table,id.vars = c("Id","Scale"))

Table$value <- abs(Table$value)

ggplot(Table) + geom_line(aes(Scale,value,group=Id),alpha=0.5) + facet_wrap(~variable) +
  coord_cartesian(ylim=c(0,0.1))
