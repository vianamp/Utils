# **************************************************************************
# Warnings off
# **************************************************************************

options(warn=-1)

# **************************************************************************
# Loading reuired packages and auxiliar functions
# **************************************************************************

library(igraph, warn.conflicts = F)
source("auxiliar/Events.R")
source("auxiliar/IO.R")

# **************************************************************************
# Loading parameters from command line
# **************************************************************************

Args <- commandArgs(trailingOnly = T) 

NumberOfNodes <- as.numeric(Args[1])

AverageDegree <- as.numeric(Args[2])

RootFolder <- Args[3]

# **************************************************************************
# Erdos-Renyi graph
# **************************************************************************

g <- erdos.renyi.game(NumberOfNodes,AverageDegree/NumberOfNodes,directed = F)

# **************************************************************************
# Removing degree-2 nodes
# **************************************************************************

g <- GetRideOfDeg2Nodes(delete.vertices(g,which(degree(g)==0)),FALSE)

# **************************************************************************
# Placing nodes on 2D space
# **************************************************************************

r <- layout_with_fr(g)

V(g)$x = r[,1]
V(g)$y = r[,2]

# **************************************************************************
# Nodes and edges colors
# **************************************************************************

V(g)$color <- "gray"
E(g)$color <- "black"

# **************************************************************************
# New variable to store original nodes id
# **************************************************************************

V(g)$id <- seq(1,vcount(g),1)

# **************************************************************************
# Reshaping the graph topology
# **************************************************************************

W <- MergeClosetsTwoNodes(g)
annotation <- W[[2]]
w <- W[[1]]
w <- SplitLongestEdge(w)
w <- PullOut(w)
w <- Jiggle(w)

# **************************************************************************
# Creating PNG figure with before and after
# **************************************************************************

png(filename=paste(RootFolder,"/Graphs01.png",sep=""))
	par(mfrow=c(1, 2))
		plot(g,vertex.size=20,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(g)$y),max(V(g)$y)),xlim=c(min(V(g)$x),max(V(g)$x)), asp = 0)
		plot(w,vertex.size=20,vertex.frame.color="gray",rescale=F,axes=F,ylim=c(min(V(w)$y),max(V(w)$y)),xlim=c(min(V(w)$x),max(V(w)$x)), asp = 0)
graphics.off()

# **************************************************************************
# Exporting data
# **************************************************************************

ExportData(g,paste(RootFolder,"/GraphT0",sep=""),F,NA)
ExportData(w,paste(RootFolder,"/GraphT1",sep=""),T,annotation)
