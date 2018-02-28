#!/usr/bin/Rscript

#CALL: R3script rapidVis.r <plotMethod> <outputFolder_of_rapidStats.sh or rapidNorm.sh (Where Statistics and other files are located)> <AnnotationFile> <rapidPath (MUST)>
#load libraries
library("reshape2")
library("ggplot2")
library("scales")
library("knitr")
library("gplots")
library("RColorBrewer")

opts_chunk$set(echo=FALSE, warning = FALSE)
args <- commandArgs(trailingOnly = TRUE)
rapidPath=Sys.getenv("rapid")
plotMethod=as.character(args[1]) #value for differentiating Individual or Comparison Plots (stats, compare)
#################################For Individual Results
if(plotMethod=="stats"){
  args <- commandArgs(trailingOnly = TRUE)
  filename=as.character(args[2])
  annotationfile=as.character(args[3])
  if(rapidPath==""){
    rapidPath=as.character(args[4])
  }
  annotations=read.table(annotationfile,header=F,stringsAsFactors=FALSE)
  names(annotations)=c("chr","start","end","label","type","strand")
  tt=read.table(paste(filename,"alignedReads.sub.compact",sep=""),stringsAsFactors=FALSE)
  allNames=annotations$label[!duplicated(annotations$label)] #Need to change this if we need to parse only a subset of regions
  
  smpName=system("pwd|rev|cut -d '/' -f 1|rev", intern = TRUE)
  homeIP=paste(rapidPath,"homePage.Rmd", sep="")
  homeOUT=paste(normalizePath(filename),"Information.html", sep="/")
  rmarkdown::render(input=homeIP,output_file = homeOUT, envir=parent.frame())
  
  ipname=paste(rapidPath,"statsPlot.Rmd", sep="")
  poscov=read.table(paste(filename,"poscov.tsv",sep=""), header = F, colClasses = c(rep('NULL',3), NA, rep('NULL',3), NA))
  negcov=read.table(paste(filename,"negcov.tsv",sep=""), header = F, colClasses = c(rep('NULL',3), NA, rep('NULL',3), NA))
  colnames(poscov)=c("region","depth")
  colnames(negcov)=c("region","depth")
  for(name in allNames){
    opts_chunk$set(echo=FALSE)
    subtt=subset(tt,V1==name)
    rmin=range(tt$V2)[1]-1
    rmax=range(tt$V2)[2]+1
    subtt=subset(subtt, V2 > rmin & V2 <rmax)
    aligned=nrow(subtt)
    if(aligned==0) {
    	next;
    }
    fname=paste(normalizePath(filename),paste(name,".html", sep=""), sep="/")
    rmarkdown::render(input=ipname,output_file = fname, envir=parent.frame())
    #knit2html(input=ipname,output=fname, envir=parent.frame())
  }
  masterFile=paste(paste("cp ", paste(rapidPath,"master.html", sep=""), sep=""), filename)
  system(masterFile)
  setwd(filename)
  system("echo \"<HTML>\" >>sidecolumn.html")
  system("for file in *.html; do printf \"<a href='$file' target='main'>\" >>sidecolumn.html; echo -n $file|cut -n -d '.' -f 1 >>sidecolumn.html; printf \"<br><br>\n\" >>sidecolumn.html;done;")
  system("echo \"</HTML>\" >>sidecolumn.html")
  system("sed -i '/sidecolumn\\|master/d' sidecolumn.html")
  system("mv master.html `pwd|rev|cut -d '/' -f 1|rev`.html")
}
##################################################For Individual Results - END
#################################For Comparative Results

if(plotMethod=="compare"){
  out=args[2]
  if(rapidPath==""){
    rapidPath=as.character(args[3])
  }
  opts_chunk$set(echo=FALSE, warning = FALSE)
  normData=read.table(paste(out,"NormalizedValues.dat",sep=""),header=T,stringsAsFactors=FALSE)
  dfa=normData
  allowed<-unique(dfa$region)
  hval=nrow(transform(allowed))*0.75
  if(hval>120){
    hval=120
  }
  if(hval<10){
    hval=10
  }
  dfa$readCountsAvgLog = log2(0.00001+dfa$readCountsAvg)
  asratio=as.data.frame(dcast(dfa, region~samples, value.var = 'ASratioNorm'))
  rdCntAvgLog=as.data.frame(dcast(dfa, region~samples, value.var = 'readCountsAvgLog'))
  rdCntNorm=as.data.frame(dcast(dfa, region~samples, value.var = 'readCountsNorm'))
  rdCntTPM=as.data.frame(dcast(dfa, region~samples, value.var = 'readCountsNormTPM'))
  rownames(asratio)=asratio$region
  rownames(rdCntAvgLog)=rdCntAvgLog$region
  rownames(rdCntNorm)=rdCntNorm$region
  rownames(rdCntTPM)=rdCntTPM$region
  rdCntNorm$region=NULL
  rdCntTPM$region=NULL
  rdCntAvgLog$region=NULL
  asratio$region=NULL
  ipfile=paste(rapidPath,"compPlot.Rmd", sep="")
  outfile=paste(normalizePath(out),"CompAnalysisResults.html", sep="/")
  rmarkdown::render(input=ipfile,output_file=outfile, envir=parent.frame())
  #knit2html(input=paste(rapidPath,"compPlot.Rmd", sep=""),output=paste(out,"CompAnalysisResults.html", sep=""), envir=parent.frame())
  setwd(out)
  system("mv CompAnalysisResults.html `pwd|rev|cut -d '/' -f 1|rev`.html")
}
##################################################For Comparative Results - END

