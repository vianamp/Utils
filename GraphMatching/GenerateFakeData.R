rm(list=ls(all=TRUE))
library(igraph)
library(ggplot2)

GetRideOfDeg2Nodes <- function(g,diffCol) {
  while (sum(degree(g)==2) > 0) {
    k <- degree(g)
    i <- which(k==2)[1]
    n <- neighbors(g,i)
    g <- add.edges(g,n)
    if (diffCol) {
      E(g)$color[ecount(g)] <- "red"
    } else {
      E(g)$color[ecount(g)] <- "black"
    }
    g <- delete.vertices(g,i)
    g <- simplify(g,edge.attr.comb = "first")
  }
  return(g)
}

MergeClosetsTwoNodes <- function(g) {
  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  
  f <- clusters(g)$membership
  f <- as.numeric(table(f))[f]
  for (i in which(f==2)) {
    d[i,] <- max(d)
    d[,i] <- max(d)
  }
  
  i <- which(d==min(d[d>0]), arr.ind = TRUE)[1,1]
  j <- which(d==min(d[d>0]), arr.ind = TRUE)[1,2]
  
  e <- get.edge.ids(g,c(i,j))
  
  if (e > 0) {
    
    g <- add.vertices(g,1)
    V(g)$id[vcount(g)] <- -1
    V(g)$color[vcount(g)] <- "red"
    
    g <- delete.edges(g,e)

    V(g)$x[vcount(g)] <- mean(V(g)$x[c(i,j)])
    V(g)$y[vcount(g)] <- mean(V(g)$y[c(i,j)])
    n <- neighbors(g,i)
    if (length(n) > 0) {
      for (k in n) {
        g <- add.edges(g,c(k,vcount(g)),attr=list(color="black"))
      }
    }
    n <- neighbors(g,j)
    if (length(n) > 0) {
      for (k in n) {
        g <- add.edges(g,c(k,vcount(g)),attr=list(color="black"))
      }
    }
    
    g <- delete.vertices(g,c(i,j))
    g <- simplify(g,edge.attr.comb = "first")
    
  } else {
    g <- add.edges(g,c(i,j),attr=list(color="red"))
  }

  if(sum(degree(g)==2)>0) {
    g <- GetRideOfDeg2Nodes(g,TRUE)
  }
  
  return(g)
}

Jiggle <- function(g) {
  delta <- 4*sqrt((diff(range(V(g)$x)))^2+(diff(range(V(g)$y)))^2)/100
  V(g)$x <- V(g)$x + runif(vcount(g),-delta,delta)
  V(g)$y <- V(g)$y + runif(vcount(g),-delta,delta)
  return(g)
}

ExportData <- function(g,filename,expids) {
  sink(paste(filename,".gnet",sep=""))
  cat(paste(vcount(g),"\n",sep=""))
  sink()
  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  e <- get.edgelist(g)
  write.table(format(data.frame(data.frame(e-1,d[cbind(e[,1],e[,2])])), digits=4),file = paste(filename,".gnet",sep=""),sep = "\t",row.names = F,col.names=F,append = T,quote = F)
  write.table(format(data.frame(V(g)$x,V(g)$y,0.0), digits=4),file = paste(filename,".coo",sep=""),sep = "\t",row.names = F,col.names=F,quote = F)
  if (expids) {
    write.table(format(data.frame(seq(0,vcount(g)-1,1),V(g)$id), digits=4),file = paste(filename,".output",sep=""),sep = "\t",row.names = F,col.names=F,quote = F)
  }
}

SplitLongestEdge <- function(g) {
  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  
  e <- get.edgelist(g)
  d[cbind(e[,1],e[,2])] <- -d[cbind(e[,1],e[,2])]
  
  i <- which(d==min(d), arr.ind = TRUE)[1,1]
  j <- which(d==min(d), arr.ind = TRUE)[1,2]
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -2
  V(g)$color[vcount(g)] <- "green"
  V(g)$x[vcount(g)] <- mean(c(V(g)$x[i],mean(V(g)$x[c(i,j)])))
  V(g)$y[vcount(g)] <- mean(c(V(g)$y[i],mean(V(g)$y[c(i,j)])))
  g <- add.edges(g,c(i,vcount(g)),attr=list(color="black"))
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -2
  V(g)$color[vcount(g)] <- "green"
  V(g)$x[vcount(g)] <- mean(c(V(g)$x[j],mean(V(g)$x[c(i,j)])))
  V(g)$y[vcount(g)] <- mean(c(V(g)$y[j],mean(V(g)$y[c(i,j)])))
  g <- add.edges(g,c(j,vcount(g)),attr=list(color="black"))
  
  g <- delete.edges(g,get.edge.ids(g,c(i,j)))
  g <- simplify(g,edge.attr.comb = "first")
  return(g)
}

PullOut <- function(g) {
  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  
  e <- get.edgelist(g)
  d[cbind(e[,1],e[,2])] <- -d[cbind(e[,1],e[,2])]
  
  i <- which(d==min(d), arr.ind = TRUE)[1,1]
  j <- which(d==min(d), arr.ind = TRUE)[1,2]
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -3
  V(g)$color[vcount(g)] <- "purple"
  V(g)$x[vcount(g)] <- mean(V(g)$x[c(i,j)])
  V(g)$y[vcount(g)] <- mean(V(g)$y[c(i,j)])
  g <- add.edges(g,c(i,vcount(g)),attr=list(color="black"))
  g <- add.edges(g,c(j,vcount(g)),attr=list(color="black"))
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -3
  V(g)$color[vcount(g)] <- "purple"
  V(g)$x[vcount(g)] <- mean(V(g)$x[c(i,j)])-(V(g)$y[i]-mean(V(g)$y[c(i,j)]))
  V(g)$y[vcount(g)] <- mean(V(g)$y[c(i,j)])+(V(g)$x[i]-mean(V(g)$x[c(i,j)]))
  g <- add.edges(g,c(vcount(g),vcount(g)-1),attr=list(color="purple"))
  g <- add.edges(g,c(vcount(g),vcount(g)-1),attr=list(color="purple"))
  
  g <- delete.edges(g,get.edge.ids(g,c(i,j)))
  g <- simplify(g,edge.attr.comb = "first")
  return(g)
}

# Generating a fake two time points time-varying network

g <- erdos.renyi.game(40,2.5/40,directed = F)

r <- layout_with_kk(g)

V(g)$x = r[,1]
V(g)$y = r[,2]
V(g)$color <- "gray"
E(g)$color <- "black"

g <- GetRideOfDeg2Nodes(delete.vertices(g,which(degree(g)==0)),FALSE)
r <- layout_with_kk(g)
V(g)$x = r[,1]
V(g)$y = r[,2]
V(g)$id <- seq(1,vcount(g),1)

w <- MergeClosetsTwoNodes(g)
w <- SplitLongestEdge(w)
w <- PullOut(w)
w <- Jiggle(w)

png(filename=paste("/Users/mviana/Documents/ProjectsPersonal/Utils/GraphMatching/data/Graphs.png",sep=""))
  par(mfrow=c(1, 2))
  plot(g,vertex.label=NA,vertex.size=10)
  plot(w,vertex.label=NA,vertex.size=10)
dev.off()
    
ExportData(g,"/Users/mviana/Documents/ProjectsPersonal/Utils/GraphMatching/data/GraphT0",F)
ExportData(w,"/Users/mviana/Documents/ProjectsPersonal/Utils/GraphMatching/data/GraphT1",T)
