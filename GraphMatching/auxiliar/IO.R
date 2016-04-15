ExportData <- function(g,filename,expids,annotation) {
  sink(paste(filename,".gnet",sep=""))
  cat(paste(vcount(g),"\n",sep=""))
  sink()
  d <- as.matrix(dist(as.matrix(cbind(V(g)$x,V(g)$y)), method = "euclidean"))
  e <- get.edgelist(g)
  write.table(format(data.frame(data.frame(e-1,d[cbind(e[,1],e[,2])])), digits=4),file = paste(filename,".gnet",sep=""),sep = "\t",row.names = F,col.names=F,append = T,quote = F)
  write.table(format(data.frame(V(g)$x,V(g)$y,0.0), digits=4),file = paste(filename,".coo",sep=""),sep = "\t",row.names = F,col.names=F,quote = F)
  if (expids) {
    write.table(data.frame("@nodes"),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F)
    write.table(cbind(c(V(w)$id),c(as.numeric(V(w)))),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F,append=T)
    if (!annotation[[1]]) {
      write.table(format(data.frame(annotation[[2]],-1), digits=4),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F,append=T)
      write.table(format(data.frame(annotation[[3]],-1), digits=4),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F,append=T)
    } else {
      write.table(data.frame("@edges"),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F,append=T)
      write.table(format(data.frame(annotation[[2]],annotation[[3]]), digits=4),file = paste(filename,".output",sep=""),sep = "\t",row.names=F,col.names=F,quote=F,append=T)
    }
  }
}
