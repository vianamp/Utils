# *****************************************************************
# Turning warnings off
# *****************************************************************
#rm(list=ls(all=TRUE))

options(warn=-1)

# *****************************************************************
# Variables from command line
# *****************************************************************

args = commandArgs(trailingOnly=TRUE)

# *****************************************************************
# Main function
# *****************************************************************

library(rjson)

get_rec_distance <- function(xi,yi,wi,hi,xj,yj,wj,hj) {
  Points <- NULL
  for (dx in c(0,1)) {
    for (dy in c(0,1)) {
      Points <- rbind(Points,data.frame(X=xi+dx*wi,Y=yi+dy*hi))
    }
  }
  for (dx in c(0,1)) {
    for (dy in c(0,1)) {
      Points <- rbind(Points,data.frame(X=xj+dx*wj,Y=yj+dy*hj))
    }
  }
  return(min(dist(Points,diag = F,upper = F)))
}

get_distance_between_recs <- function(ID) {
  Dist <- matrix(nrow = nrow(ID),ncol = nrow(ID))
  for (i in seq(1,nrow(ID),1)) {
    for (j in seq(1,nrow(ID),1)) {
      if ( (ID$id[j]>ID$id[i]) && (ID$pg[i]==ID$pg[j]) ) {
        Dist[i,j] = get_rec_distance(ID$x[i],ID$y[i],ID$w[i],ID$h[i],ID$x[j],ID$y[j],ID$w[j],ID$h[j])
      }
    }
  }
  return(Dist)
}

update_list_of_recs <- function(Dist,ID) {
  cont <- FALSE
  M <- which(Dist==min(Dist,na.rm = T),arr.ind = T)
  if (nrow(M) > 0) {
    cont <- TRUE
    
    id <- max(ID$id) + 1
    i <- as.numeric(M[1,1])
    j <- as.numeric(M[1,2])
    
    x <- min(c(ID$x[i],ID$x[j]))
    y <- min(c(ID$y[i],ID$y[j]))
    xf <- max(c(ID$x[i]+ID$w[i],ID$x[j]+ID$w[j]))
    yf <- max(c(ID$y[i]+ID$h[i],ID$y[j]+ID$h[j]))
    w <- xf-x
    h <- yf-y
    
    ID <- rbind(ID,data.frame(id=id,pg=ID$pg[i],rec=NA,x=x,y=y,w=w,h=h))
    ID <- ID[-c(i,j),]
    
  }
  return(list(cont,ID,c(id,i,j)))
}

fname <- args[1]

nFinal <- args[2]

Data <- fromJSON(paste(readLines(paste(fname,'.json',sep='')), collapse=""))

n <- 1
ID <- NULL
Hierarq <- list()
for (i in seq(1,length(Data$page),1)) {
  nRec <- length(Data$page[[i]]$rectangle)
  if (nRec>0) {
    for (rec in seq(1,nRec,1)) {
      xi <- Data$page[[i]]$rectangle[[rec]]$x
      yi <- Data$page[[i]]$rectangle[[rec]]$y
      wi <- Data$page[[i]]$rectangle[[rec]]$width
      hi <- Data$page[[i]]$rectangle[[rec]]$height
      ID <- rbind(ID,data.frame(id=n,pg=i,rec=rec,x=xi,y=yi,w=wi,h=hi))
      Hierarq[[n]] <- n
      n <- n + 1
    }
  }
}

if (length(unique(ID$pg)) > nFinal) {

    cat('Final number of figures provided is greater than number of pages containing at least one rectangle\n')

} else {

  while (nrow(ID) > nFinal) {
    Dist <- get_distance_between_recs(ID)
    q <- update_list_of_recs(Dist,ID)
  
    i <- ID$id[q[[3]][2]]
    j <- ID$id[q[[3]][3]]
    Hierarq[[q[[3]][1]]] <- c(Hierarq[[i]],Hierarq[[j]])
    
    ID <- q[[2]]
  }
  
  ID <- ID[order(ID$pg),]
  ID$rec <- seq(1,nrow(ID),1)
  
  for (fig in ID$id) {
    for (rec in sort(Hierarq[[fig]])) {
      cat(paste(rec,ID$rec[which(ID$id==fig)],'\n',sep=' '))
    }
  }
  
}