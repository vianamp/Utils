run("Duplicate...", "duplicate channels=3");
run("Make Substack...", "  slices=4-9");
run("Z Project...", "projection=[Max Intensity]");
run("Find Maxima...", "noise=100 output=[Segmented Particles] light");
run("Analyze Particles...", "size=1-6 add");

//R code
//rm(list=ls())
//library(ggplot2)
//W <- data.frame(read.csv('~/Desktop/CellShape.txt',row.names=NULL)) 
//W$Y <- W$Y / 134.95
//f <- ggplot(W) + geom_smooth(aes(Y,Width/Height)) + coord_cartesian(ylim=c(0.8,1.7),xlim=c(0,1))
//pdf("~/Desktop/temp.pdf",width=5,height=5,useDingbats=F);f;dev.off()
 
