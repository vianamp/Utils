rm(list=ls(all=TRUE))

library(plyr)
library(scales)
library(ggplot2)
library(gridExtra)

TextToNumber <- function(text) {
  numb <- list()
  numb$valid <- T
  curr <- gregexpr('[0-9]+',text)[[1]][1]
  if (curr > -1) {
    numb$value = substr(text,curr,curr)
    while (!is.na(as.numeric(substr(text,curr+1,curr+1)))) {
      numb$value = paste(numb$value,substr(text,curr+1,curr+1),sep="")
      curr = curr + 1
    }
    numb$composed <- F
    if (is.na(match(substr(text,curr+1,curr+1),c(' ','.',',',':',']',')')))) {
      numb$composed <- T
    }
  } else {
    numb$valid <- F
  }
  return(numb)
}

GetFigureNumber <- function(Obj) {
  if (Obj$number$valid) {
    nfigs <- as.numeric(Obj$number$value)
  } else {
    nfigs <- NA
  }
  return(nfigs)
}

GetNumberOfFiguresInPDF <- function(Section) {
  return(max(unlist(lapply(Section,GetFigureNumber)),na.rm = T))
}

filename <- "0811.2743"

RootFolder <- "/Users/mviana/Documents/ProjectsIBM/PDFminer"

cmd <- paste("pdftotext ",RootFolder,"/seismicarxiv/",filename,".pdf && echo -e '\n' >> ",RootFolder,"/seismicarxiv/",filename,".txt",sep="")

system(cmd)

PDF <- readLines(paste(RootFolder,"/seismicarxiv/",filename,".txt",sep=""));

bag <- c('Fig.','Figure')

id <- 0
Section <- list()
for (line in seq(1,length(PDF),1)) {
  q <- grep(paste(bag,collapse="|"),PDF[line],ignore.case=TRUE)
  if (length(q) > 0) {
    id <- id + 1
    Section[[id]] <- list(line=line,text=paste(PDF[c(line-1,line,line+1)],collapse=" "))
  }
}

for (section in seq(1,length(Section),1)) {
  for (word in bag) {
    q <- regexpr(word,Section[[section]]$text,ignore.case=TRUE)[1]
    if (q > -1) {
      Section[[section]]$number <- TextToNumber(substr(Section[[section]]$text,q,q+10))
      break
    }
  }
}

print(GetNumberOfFiguresInPDF(Section))
