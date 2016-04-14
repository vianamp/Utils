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

RootFolder <- args[1]

filename <- args[2]

PDF <- read.table(paste(RootFolder,"/",filename,".txt",sep=""),sep="\t");

names(PDF) <- c('fig','keyword','confidence')

PDF$keyword <- as.character(PDF$keyword)

sink(paste(RootFolder,"/",filename,".txt",sep=""))
for (line in seq(1,nrow(PDF),1)) {
  word <- PDF$keyword[line]
  word <- substr(word,2,nchar(word))
  q <- grep(paste(c('Fig','\\\\','/','\\.'),collapse="|"),word,ignore.case=TRUE)
  if (!length(q) & nchar(word) > 2) {
    PDF$keyword[line] <- word
    cat(paste(PDF$fig[line],PDF$keyword[line],PDF$confidence[line],sep="\t"))
    cat('\n')
  } else {
    PDF$keyword[line] <- NA
  }
}
sink()

PDF <- PDF[which(!is.na(PDF$keyword)),]
