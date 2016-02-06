#!/TL/opt/bin/R3script
#CALL: Rscript Rscript rapidVis.r <outputFolder_of_rapidStats.sh or rapidNorm.sh> <AnnotationFile> <plotMethod>
#load libraries
library("ggplot2")
library("scales")
library("knitr")
opts_chunk$set(echo=FALSE)
args <- commandArgs(trailingOnly = TRUE)
rapidPath <- Sys.getenv("rapid")
show(rapidPath)
plotMethod=as.character(args[1]) #value for differentiating Individual or Comparison Plots (stats, compare)

if(plotMethod=="stats"){
args <- commandArgs(trailingOnly = TRUE)
filename=as.character(args[2])
annotationfile=as.character(args[3])
rapidPath=as.character(args[4])
#################################For Individual Results
annotations=read.table(annotationfile,header=F,stringsAsFactors=FALSE)
tt=read.table(paste(filename,"alignedReads.sub.compact",sep=""),stringsAsFactors=FALSE)
allNames=annotations$V4[!duplicated(annotations$V4)] #Need to change this if we need to parse only a subset of regions

ipname=paste(rapidPath,"statsPlot.Rmd", sep="")
show(ipname)
for(name in allNames){
opts_chunk$set(echo=FALSE)
fname=paste(filename,paste(name,".html", sep=""), sep="")
show(fname)
knit2html(input=ipname,output=fname, envir=parent.frame())
##################################################For Individual Results - END
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
if(plotMethod=="compare"){
out=args[2]

#################################For Comparative Results

####FUNCTIONS####
#create barplot dividing the read counts for each region
createSamplePlot <- function(df,title,allowed=c("all"),plotlog=TRUE){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  #show(df)
  if(plotlog){
  #show("InIfSamplePlot")
  print(ggplot(df,aes(x=samples,y=readCountsNorm,fill=samples)) +  geom_bar(stat="identity") +
    facet_wrap(~ region)+theme_bw()+scale_y_continuous(trans=log2_trans()) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="read counts (log2)",title=title))
  }else{
    #show("InElseSamplePlot")
    print(ggplot(df,aes(x=samples,y=readCountsNorm,fill=samples)) +  geom_bar(stat="identity") +
      facet_wrap(~ region)+theme_bw()+
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="read counts",title=title))
  }
}
#create barplot dividing the read counts for each region
createSampleASRatioPlot <- function(df,title,allowed=c("all"),y="antisense ratio "){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  print(ggplot(df,aes(x=samples,y=ASratio,fill=samples)) +  geom_bar(stat="identity") +theme_bw()+
    facet_wrap(~ region)+ theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(y=y,title=title))
}
#create barplot dividing the read counts for each sample
createRegionPlot <- function(df,title,allowed=c("all"),plotlog=FALSE){
 if(allowed[1] != "all"){
   df=subset(df,region %in% allowed)
 }
 if(plotlog){
  print(ggplot(df,aes(x=region,y=readCountsAvg,fill=region)) +  geom_bar(stat="identity") +
  facet_wrap(~ samples)+theme_bw() + scale_y_continuous(trans=log2_trans()) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="average read counts (log2) ",title=title))
 }else{
  print(ggplot(df,aes(x=region,y=readCountsAvg,fill=region)) +  geom_bar(stat="identity") +
  facet_wrap(~ samples)+theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="average read counts",title=title))
   
 }
 
}
#create barplot dividing the read counts for each sample
createRegionASRatioPlot <- function(df,title,allowed=c("all"),y="antisense ratio"){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  
  print(ggplot(df,aes(x=region,y=ASratio,fill=region)) +  geom_bar(stat="identity") +
    facet_wrap(~ samples)+theme_bw()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y=y,title=title))
}
####DONE FUNCTIONS####
normData=read.table(paste(out,"NormalizedValues.dat",sep=""),header=T,stringsAsFactors=FALSE)
dfa=normData
allowed<-unique(dfa$region)
pdf(paste(out,"ComparativeAnalysesResults.pdf",sep=""))
createSamplePlot(dfa,title="",allowed,plotlog=FALSE)
createSamplePlot(dfa,title="",allowed)
createRegionPlot(dfa,title="",allowed)
createRegionPlot(dfa,title="",allowed,plotlog=TRUE)
createSampleASRatioPlot(dfa,title="",allowed)
createRegionASRatioPlot(dfa,title="",allowed)
#plotting the read counts per region (log2) as heatmap
dfa$readCountsAvgLog = log2(dfa$readCountsAvg)
print((p <- ggplot(dfa, aes(region, samples)) + geom_tile(data=subset(dfa,region %in% allowed),aes(fill = readCountsAvgLog),
                    colour = "white") + scale_fill_gradient(low = "white",
                    high = "steelblue")) + labs(y="Samples",x="Region",fill="Average count (log2)"))
#plotting the read counts per region (log2) as heatmap
print((p <- ggplot(dfa, aes(region, samples)) + geom_tile(data=subset(dfa,region %in% allowed),aes(fill = ASratio),
 colour = "white") + scale_fill_gradient(low = "white",
 high = "steelblue")) + labs(y="Samples",x="Region",fill="Antisense ratio"))
dev.off()
##################################################For Comparative Results - END
}
