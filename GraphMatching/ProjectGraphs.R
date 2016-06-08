# **************************************************************************
# Warnings off
# **************************************************************************

options(warn=-1)

# **************************************************************************
# Loading reuired packages and auxiliar functions
# **************************************************************************

library(igraph, warn.conflicts = F)

# **************************************************************************
# Loading parameters from command line
# **************************************************************************

Args <- commandArgs(trailingOnly = T) 

RootFolder <- Args[1]

GName1 <- Args[2]

GName2 <- Args[3]

SaveTo <- Args[4]

CleanView <- Args[5]

# **************************************************************************
# Loading graph files
# **************************************************************************

g <- graph.data.frame(data.frame(read.table(paste(RootFolder,'/',GName1,'.gnet',sep=''),header = F,skip = 1)),directed = F)

w <- graph.data.frame(data.frame(read.table(paste(RootFolder,'/',GName2,'.gnet',sep=''),header = F,skip = 1)),directed = F)

# **************************************************************************
# Loading coordinates
# **************************************************************************

rg <- data.frame(read.table(paste(GName1,'coo',sep='.'),header = F))

rw <- data.frame(read.table(paste(GName2,'coo',sep='.'),header = F))

# **************************************************************************
# Assign coordinates
# **************************************************************************

V(g)$x <- rg$V1[as.numeric(V(g)$name)+1]
V(g)$y <- rg$V2[as.numeric(V(g)$name)+1]
V(w)$x <- rw$V1[as.numeric(V(w)$name)+1]
V(w)$y <- rw$V2[as.numeric(V(w)$name)+1]

# **************************************************************************
# Creating PNG figure for the two instances
# **************************************************************************

png(filename=paste(RootFolder,SaveTo,sep="/"),width=800,height=500,units='px')
	par(mfrow=c(1, 2))
	if (CleanView==1) {
		plot(g,vertex.label=NA,vertex.size=20,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(g)$y),max(V(g)$y)),xlim=c(min(V(g)$x),max(V(g)$x)), asp = 0)
	  plot(w,vertex.label=NA,vertex.size=20,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(w)$y),max(V(w)$y)),xlim=c(min(V(w)$x),max(V(w)$x)), asp = 0)
	} else {
	  plot(g,vertex.label=as.numeric(V(g)$name)+1,vertex.size=250,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(g)$y),max(V(g)$y)),xlim=c(min(V(g)$x),max(V(g)$x)), asp = 0)
	  plot(w,vertex.label=as.numeric(V(g)$name)+1,vertex.size=250,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(w)$y),max(V(w)$y)),xlim=c(min(V(w)$x),max(V(w)$x)), asp = 0)
	}
graphics.off()

