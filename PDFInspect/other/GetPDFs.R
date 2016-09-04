rm(list=ls(all=TRUE))

for (page in seq(0,10,1)) {

  cmd <- paste('wget --user-agent="NOT WGET" http://arxiv.org/find/grp_q-bio,grp_stat,grp_cs,grp_q-fin,grp_math,grp_physics/1/ti:+gravitational/0/1/0/2016/0/1?skip=',page*25,' -O ~/Desktop/arxiv/search.txt',sep="")
  
  system(cmd)
  
  webpage <- readLines("~/Desktop/arxiv/search.txt");
  
  vec <- NA
  for (line in seq(1,length(webpage))) {
    q <- regexpr('.pdf',webpage[line])[1]
    if (q > -1) {
      vec <- c(vec,line)
    }
  }
  
  webpage <- webpage[vec[-1]]
  
  for (line in seq(1,length(webpage))) {
    code <- strsplit(strsplit(webpage[line],":")[[1]][2],"<")[[1]][1]
    cmd <- paste('wget --user-agent="NOT WGET" http://arxiv.org/pdf/',code,' -O ~/Desktop/arxiv/',code,'.pdf',sep="")
    system(cmd)
  }
  
} 
