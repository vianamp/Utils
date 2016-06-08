rm(list=ls(all=TRUE))

RootFolder <- '/Users/mviana/Documents/ProjectsPersonal/Utils/JPG-PNG-to-MNIST-NN-Format/charts/'

DestFolder <- '/Users/mviana/Documents/ProjectsPersonal/Utils/JPG-PNG-to-MNIST-NN-Format/'

Classes <- list.dirs(path = RootFolder, full.names = FALSE, recursive = TRUE)[-1]

p <- 0.2

for (folder in Classes) {
  dir.create(paste(DestFolder,'training-images/',folder,sep=''),showWarnings = F)
  dir.create(paste(DestFolder,'test-images/',folder,sep=''),showWarnings = F)
}

for (folder in Classes) {
  Images <- list.files(path = paste(RootFolder,folder,sep=''),pattern = "\\.png$")
  Suffix <- sample(c('training-images/','test-images/'),size = length(Images),prob = c(1-p,p),replace = T)
  for (im in seq(1,length(Images),1)) {
    cmd <- paste('cp ',RootFolder,folder,'/',Images[im],' ',DestFolder,Suffix[im],folder,'/',Images[im],sep='')
    system(cmd)
  }
}


