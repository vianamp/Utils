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

#RootFolder <- "/Users/mviana/Documents/ProjectsIBM/PDFminer/temp"

#filename <- "temp4"

system(paste("pdftocairo ",RootFolder,"/",filename,".pdf"," -png -gray -q ",RootFolder,"/",filename,sep=""))

PNGFiles <- list.files(path = RootFolder, pattern = "\\.png$")

sink(paste(RootFolder,"/",filename,".json",sep=""))

cat("{\n")
cat("\t\"page\":\n")
cat("\t[\n")

for (fname in PNGFiles) {

  page_number <- as.numeric(strsplit(strsplit(fname,"-")[[1]][2],"\\.")[[1]][1])
    
  output <- system(paste("~/Documents/ProjectsIBM/ImageDetection/build/ImageDetection.app/Contents/MacOS/ImageDetection ",RootFolder,"/",fname,sep=""),intern = T)

  if (length(output) > 0) {

    imdim <- strsplit(system(paste('file ',RootFolder,'/',fname,sep=''),intern=T),',')[[1]][2]
    width <- as.numeric(strsplit(imdim,'x')[[1]][1])
    height <- as.numeric(strsplit(imdim,'x')[[1]][2])
      
    cat("\t\t{\n")
    cat(paste("\t\t\"number\":",page_number,",\n",sep=""))
    cat(paste("\t\t\"width\":",width,",\n",sep=""))
    cat(paste("\t\t\"height\":",height,",\n",sep=""))
    if (output != "") {
      cat("\t\t\"rectangle\":\n")
      cat("\t\t[\n")
      cat(output,sep = "\n")
      cat("\t\t]\n")
    } else {
      cat("\t\t\"rectangle\":[]\n")
    }
    if (fname != PNGFiles[length(PNGFiles)]) {
      cat("\t\t},\n")
    } else {
      cat("\t\t}\n")
    }
  }
}

cat("\t]\n")
cat("}\n")  

sink()

system(paste("rm ",RootFolder,"/*.txt",sep=""))
system(paste("rm ",RootFolder,"/*.png",sep=""))

