GetRideOfDeg2Nodes <- function(g,diffCol) {

  # Before:           After:
  #
  # i    k    j   =>  i         j
  # o----o----o       o---------o

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

  # Before:               After:
  #
  # i    p   q    j   =>  i             j
  # o----o   o----o       o-------------o
  #
  # OR
  #
  # i    p q    j   =>    i    m       j
  # o----o-o----o         o----o------o
  #      | |                   |\
  #      o o                   o o

  # Calculate the distance between every pair of nodes

  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
    
  # Nodes in cluster with only two nodes are not
  # allowed to merge together

  f <- clusters(g)$membership
  f <- as.numeric(table(f))[f]
  for (i in which(f==2)) {
    d[i,] <- max(d)
    d[,i] <- max(d)
  }
  
  # Two nodes with degree 1 are not allowed to
  # merge together (This might happen in real
  # networks, but here we want to avoid multiple
  # edges)

  k <- degree(g)
  for (i in seq(1,vcount(g),1)) {
    for (j in seq(1,vcount(g),1)) {
      if (k[i]==1&k[j]==1) {
        d[i,j] <- max(d)
        d[j,i] <- max(d)
      }
    }
  }

  i <- which(d==min(d[d>0]), arr.ind = TRUE)[1,1]
  j <- which(d==min(d[d>0]), arr.ind = TRUE)[1,2]
  
  e <- get.edge.ids(g,c(i,j))
  
  if (e > 0) {
  
    # if there is edge between i and j, these
    # nodes merge together.

    g <- add.vertices(g,1)
    V(g)$id[vcount(g)] <- -1
    V(g)$color[vcount(g)] <- "red"
    
    annotation <- list(0,i,j)
    
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

    # if there is no edge between i and j
    # we create a connection between them

    annotation <- list(1,i,j)
    g <- add.edges(g,c(i,j),attr=list(color="red"))
  }

  # remove degree-2 nodes that might have
  # been created

  if(sum(degree(g)==2)>0) {
    g <- GetRideOfDeg2Nodes(g,TRUE)
  }
  
  return(list(g,annotation))
}

SplitLongestEdge <- function(g) {

  # Before:               After:
  #
  # i             j  =>   i    p   q    j
  # o-------------o       o----o   o----o

  # Calculate the distance between every pair of nodes

  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  
  # Assign negative values to the distances between connected pairs

  e <- get.edgelist(g)
  d[cbind(e[,1],e[,2])] <- -d[cbind(e[,1],e[,2])]

  # Sort 4 out of 5 longest edges and set length as
  # zero so they will not be chosen for splitting
  
  d[sample(order(d,decreasing = F)[1:5],4)] <- 0

  # Picking i and j

  i <- which(d==min(d), arr.ind = TRUE)[1,1]
  j <- which(d==min(d), arr.ind = TRUE)[1,2]
  
  # Creating new node 1

  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -2
  V(g)$color[vcount(g)] <- "green"
  V(g)$x[vcount(g)] <- mean(c(V(g)$x[i],mean(V(g)$x[c(i,j)])))
  V(g)$y[vcount(g)] <- mean(c(V(g)$y[i],mean(V(g)$y[c(i,j)])))
  g <- add.edges(g,c(i,vcount(g)),attr=list(color="black"))

  # Creating new node 2
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -2
  V(g)$color[vcount(g)] <- "green"
  V(g)$x[vcount(g)] <- mean(c(V(g)$x[j],mean(V(g)$x[c(i,j)])))
  V(g)$y[vcount(g)] <- mean(c(V(g)$y[j],mean(V(g)$y[c(i,j)])))
  g <- add.edges(g,c(j,vcount(g)),attr=list(color="black"))
  
  # Deleting edges between i and j

  g <- delete.edges(g,get.edge.ids(g,c(i,j)))
  g <- simplify(g,edge.attr.comb = "first")
  return(g)
}

PullOut <- function(g) {

  # Before:               After:
  #
  # i             j  =>   i      p      j
  # o-------------o       o------o------o
  #                              |
  #                              o

  # Calculate the distance between every pair of nodes

  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  
  # Assign negative values to the distances between connected pairs

  e <- get.edgelist(g)
  d[cbind(e[,1],e[,2])] <- -d[cbind(e[,1],e[,2])]
  
  # Picking i and j

  i <- which(d==min(d), arr.ind = TRUE)[1,1]
  j <- which(d==min(d), arr.ind = TRUE)[1,2]
  
  # Creating nodes 1 and its connections

  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -3
  V(g)$color[vcount(g)] <- "purple"
  V(g)$x[vcount(g)] <- mean(V(g)$x[c(i,j)])
  V(g)$y[vcount(g)] <- mean(V(g)$y[c(i,j)])
  g <- add.edges(g,c(i,vcount(g)),attr=list(color="black"))
  g <- add.edges(g,c(j,vcount(g)),attr=list(color="black"))

  # Creating nodes 2 and its connection
  
  g <- add.vertices(g,1)
  V(g)$id[vcount(g)] <- -3
  V(g)$color[vcount(g)] <- "purple"
  V(g)$x[vcount(g)] <- mean(V(g)$x[c(i,j)])-(V(g)$y[i]-mean(V(g)$y[c(i,j)]))
  V(g)$y[vcount(g)] <- mean(V(g)$y[c(i,j)])+(V(g)$x[i]-mean(V(g)$x[c(i,j)]))
  g <- add.edges(g,c(vcount(g),vcount(g)-1),attr=list(color="purple"))
  
  # Deleting edges between i and j

  g <- delete.edges(g,get.edge.ids(g,c(i,j)))
  g <- simplify(g,edge.attr.comb = "first")
  return(g)
}

Jiggle <- function(g) {

  # Change the nodes coordinates around the original position

  delta <- 4*sqrt((diff(range(V(g)$x)))^2+(diff(range(V(g)$y)))^2)/100
  V(g)$x <- V(g)$x + runif(vcount(g),-delta,delta)
  V(g)$y <- V(g)$y + runif(vcount(g),-delta,delta)
  return(g)
}

