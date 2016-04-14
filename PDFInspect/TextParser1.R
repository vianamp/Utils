# *****************************************************************
# Turning warnings off
# *****************************************************************

options(warn=-1)

# *****************************************************************
# Variables from command line
# *****************************************************************

args = commandArgs(trailingOnly=TRUE)

# *****************************************************************
# Returns the first number found in a string. numb$valid = F
# indicates no number has been found. numb$composed = T indicates
# the figure is possible of type composed. numb$value stores the
# number found.
# *****************************************************************

TextToNumber = function(text) {
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

# *****************************************************************
# Returns the numb$value as numeric or NA if numb$valid = F
# *****************************************************************

GetFigureNumber <- function(Obj) {
  if (Obj$number$valid) {
    nfigs <- as.numeric(Obj$number$value)
  } else {
    nfigs <- NA
  }
  return(nfigs)
}

# *****************************************************************
# Returns the total number of figures
# *****************************************************************

GetNumberOfFiguresInPDF <- function(Section) {
  return(max(unlist(lapply(Section,GetFigureNumber)),na.rm = T))
}

# *****************************************************************
# Returns the text related to a given figure
# *****************************************************************

FindTextRelatedToThisFig <- function(Obj,value) {
  text <- NA
  if (Obj$number$valid) {
    if (Obj$number$value==value) {
      text <- Obj$text
    }
  }
  return(text)
}

# *****************************************************************
# Main function
# *****************************************************************

RootFolder <- args[1]

filename <- args[2]

PDF <- readLines(paste(RootFolder,"/",filename,".txt",sep=""));

# *****************************************************************
# Bag of words that relates a text with a figure
# *****************************************************************

bag <- c('Fig')

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

NFigs <- GetNumberOfFiguresInPDF(Section)

for (section in seq(1,length(Section),1)) {
  for (word in bag) {
    q <- regexpr(word,Section[[section]]$text,ignore.case=TRUE)[1]
    if (q > -1) {
      Section[[section]]$number <- TextToNumber(substr(Section[[section]]$text,q,q+10))
      break
    }
  }
}

sink(paste(RootFolder,"/",filename,".txt",sep=""))
for (fig in seq(1,NFigs,1)) {
  Text <- lapply(Section,FindTextRelatedToThisFig,value=as.character(fig))
  Text <- paste(unlist(Text[which(!is.na(Text))]),collapse = ' ')
  cat(Text)
  cat('\n')
}
sink()
