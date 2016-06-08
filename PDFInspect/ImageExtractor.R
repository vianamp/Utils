# *****************************************************************
# Turning warnings off
# *****************************************************************

options(warn=-1)

# *****************************************************************
# Variables from command line
# *****************************************************************

args = commandArgs(trailingOnly=TRUE)

# *****************************************************************
# Main function
# *****************************************************************

library(rjson)

fname <- args[1]

Data <- fromJSON(paste(readLines(paste(fname,'.json',sep='')), collapse=""))

for (i in seq(1,length(Data$page),1)) {

  pg = Data$page[[i]]$number
  
  nRec <- length(Data$page[[i]]$rectangle)

  if (nRec > 0) {

    for (rec in seq(1,nRec,1)) {
      x <- Data$page[[i]]$rectangle[[rec]]$x
      y <- Data$page[[i]]$rectangle[[rec]]$y
      w <- Data$page[[i]]$rectangle[[rec]]$width
      h <- Data$page[[i]]$rectangle[[rec]]$height
      system(paste('pdftocairo ',fname,'.pdf',' -x ',x,' -y ',y,' -W ',w,' -H ',h,' -f ',pg,' -l ',pg,' -jpeg -q ',fname,'-img-',rec,sep=''))
    }

  }

}