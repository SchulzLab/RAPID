#!/TL/opt/bin/Rscript
#CALL: Rscript RAPID/bin/rapid_CompareDatasets_auto.R ComparisonNormal.config AnnotationRegions.bed Comparison_normal/

#load libraries
library("ggplot2")
library("scales")


####FUNCTIONS####
readStatistics <- function(path){
  full=paste(path,"/Statistics.dat",sep="")
  stats=read.table(full,header=T,sep=" ",stringsAsFactors=FALSE)
  return(stats)
}

readTotal <- function(path){
  full=paste(path,"/TotalReads.dat",sep="")
  total=read.table(full,header=F,sep=" ")
  return(total$V1)
}

#This function compute the region lengths from the Annotation file given
#to the RAPID pipeline and used for intersection
computeRegionLengths <- function(data){
  #process
  names(data)=c("chr","start","end","label","type")
  #compute lengths
  singleLengths=apply(data,1,function(x){return(as.numeric(x[3])-as.numeric(x[2])+1)})
  dummyDF=data.frame(label=data$label,lens=singleLengths)
  res=by(dummyDF,dummyDF$label,function(x){sum(x$lens)})
  return(data.frame(region=as.character(names(res)),lens=as.numeric(res)))
}

addLengthColumnToStats <- function(Stats,lens){
  Lengths=computeRegionLengths(lens)
  for(i in 1:length(Stats)){
    df=Stats[[i]]
    Stats[[i]] = merge(df,Lengths,by="region")
  }
  return(Stats)
}

getMax <- function(Total){
  return(max(unlist(Total)))
}

normalizeEntries <- function(Stats,oldTotal,adjustForBackground=TRUE,normalizeByLength=TRUE){
  #the default is to adjust the counts for any small RNA background counts obtained and for region length
  #Note: that if the 3rd column of the config file has the entry none, then no count is substracted
  Total=oldTotal
  if(adjustForBackground){
    for (i in 1:length(Stats)){
      Total[i]=Total[[i]]-countBackgroundReads(Stats[[i]],conf$background[i])
    }
  }
  
  Max=getMax(Total)
  newList=Stats
  for (i in 1:length(Stats)){
    newList[[i]]$reads_norm=round(newList[[i]]$reads*(Max/Total[[i]]),digits=0)
    if(normalizeByLength){
      newList[[i]]$reads_avg=round( (newList[[i]]$reads_norm/newList[[i]]$lens),digits=3)
    }
  }
  return(newList)
}
#this function gets as input a string with region names. The total read count of these regions
#will be returned.
countBackgroundReads <- function(Stats,string){
  if(string=="none"){
    return(c(0))
  }
  else{
    entries=unlist(strsplit(string, ","))
    return(sum(subset(Stats,region %in% entries)$reads))
  }
} 

createPlottingData <- function(Stats,conf){
  rows=nrow(Stats[[1]])
  numDatasets=length(Stats)
  readCounts=rep(Stats[[1]]$reads,numDatasets)
  readCountsNorm=rep(Stats[[1]]$reads_norm,numDatasets)
  readCountsAvg=rep(Stats[[1]]$reads_avg,numDatasets)
  ASratio=rep(Stats[[1]]$ASratio,numDatasets)
  
  names=rep(conf$name[1],numDatasets*rows)
  for(i in 1:(numDatasets-1)){
    readCounts[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads
    readCountsNorm[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads_norm
    readCountsAvg[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads_avg
    ASratio[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$ASratio
    names[(i*rows+1):((i+1)*rows)] = rep(conf$name[i+1],rows)
  }
  df=data.frame(region = rep(Stats[[1]]$region,numDatasets), readCounts=readCounts,readCountsNorm=readCountsNorm, readCountsAvg=readCountsAvg, ASratio=ASratio, samples=names)
  return(df)
}
#compute the coefficient of variation for a vector of numbers based on median, MAD
coef <-function(vector){
   return(mad(vector)/median(vector)) 
  
}
  
computeCOEFs <-function(df,name,allowed){
  
  new=data.frame(coef=rep(0,length(allowed)),region=allowed,name=rep(name,length(allowed)))
  
  for (i in 1:length(allowed) ){
    new[i,1]=coef(subset(df,region==allowed[i])$readCounts)
  }
  return(new)
}



plotCOEFs <- function(df,allowed=c("all")){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  ggplot(df,aes(x=name,y=coef,fill=name)) +  geom_bar(stat="identity") +
    facet_wrap(~ region)+theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="Coefficient of variation")
}

#create barplot dividing the read counts for each region
createSamplePlot <- function(df,title,allowed=c("all"),plotlog=TRUE){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  if(plotlog){
  ggplot(df,aes(x=samples,y=readCountsNorm,fill=samples)) +  geom_bar(stat="identity") +
    facet_wrap(~ region)+theme_bw()+scale_y_continuous(trans=log2_trans()) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="read counts (log2)",title=title)
  }else{
    ggplot(df,aes(x=samples,y=readCountsNorm,fill=samples)) +  geom_bar(stat="identity") +
      facet_wrap(~ region)+theme_bw()+
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="read counts",title=title)
  }
}


#create barplot dividing the read counts for each region
createSampleASRatioPlot <- function(df,title,allowed=c("all"),y="antisense ratio "){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  ggplot(df,aes(x=samples,y=ASratio,fill=samples)) +  geom_bar(stat="identity") +theme_bw()+
    facet_wrap(~ region)+ theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(y=y,title=title)
}


#create barplot dividing the read counts for each sample
createRegionPlot <- function(df,title,allowed=c("all"),plotlog=FALSE){
 if(allowed[1] != "all"){
   df=subset(df,region %in% allowed)
 }
 if(plotlog){
  ggplot(df,aes(x=region,y=readCountsAvg,fill=region)) +  geom_bar(stat="identity") +
  facet_wrap(~ samples)+theme_bw() + scale_y_continuous(trans=log2_trans()) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="average read counts (log2) ",title=title)
 }else{
  ggplot(df,aes(x=region,y=readCountsAvg,fill=region)) +  geom_bar(stat="identity") +
  facet_wrap(~ samples)+theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y="average read counts",title=title)
   
 }
 
}

#create barplot dividing the read counts for each sample
createRegionASRatioPlot <- function(df,title,allowed=c("all"),y="antisense ratio"){
  if(allowed[1] != "all"){
    df=subset(df,region %in% allowed)
  }
  
  ggplot(df,aes(x=region,y=ASratio,fill=region)) +  geom_bar(stat="identity") +
    facet_wrap(~ samples)+theme_bw()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(y=y,title=title)
}

Poisson <- function(mean,value){
 return( ppois(value,mean,lower.tail=T,log.p=T))
}

####DONE FUNCTIONS####

#read CMD line parameters
#options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)

config=args[1]
annot=args[2]
out=args[3]


#load datasets 
conf=read.table(config,header=T,sep="\t",stringsAsFactors=FALSE)
lens=read.table(annot,header=F,stringsAsFactors=FALSE)
names(lens)=c("chr","start","end","region","type")
Stats=lapply(conf$location,readStatistics)
Total=lapply(conf$location,readTotal)
#add length column
Stats=addLengthColumnToStats(Stats,lens)

#normalize read counts 
normalized=normalizeEntries(Stats,Total)

df=createPlottingData(normalized,conf)
#save data.frame in output folder
allowed= unique(subset(lens,type == "region")$region)
write.table(subset(df,region %in% allowed),paste(out,"/NormalizedValues.dat",sep=""),quote=F,row.names=F,sep="\t")

pdf(paste(out,"/ComparativeAnalysesResults.pdf",sep=""))
createSamplePlot(df,title="",allowed,plotlog=FALSE)
createSamplePlot(df,title="",allowed)
createRegionPlot(df,title="",allowed)
createRegionPlot(df,title="",allowed,plotlog=TRUE)
createSampleASRatioPlot(df,title="",allowed)
createRegionASRatioPlot(df,title="",allowed)

#compare coefficients of variation for different normalizations
#joint=computeCOEFs(df,"without",allowed)
#plotCOEFs(joint,allowed)

#plotting the read counts per region (log2) as heatmap
df$readCountsAvgLog = log2(df$readCountsAvg)
(p <- ggplot(df, aes(region, samples)) + geom_tile(data=subset(df,region %in% allowed),aes(fill = readCountsAvgLog),
                    colour = "white") + scale_fill_gradient(low = "white",
                    high = "steelblue")) + labs(y="Samples",x="Region",fill="Average count (log2)")
#plotting the read counts per region (log2) as heatmap
(p <- ggplot(df, aes(region, samples)) + geom_tile(data=subset(df,region %in% allowed),aes(fill = ASratio),
 colour = "white") + scale_fill_gradient(low = "white",
 high = "steelblue")) + labs(y="Samples",x="Region",fill="Antisense ratio")

#compute significance of pairwise tests:
#pairs=computePairwiseSignificance(df,allowed)
#plotting the read counts per region (log2) as heatmap
#(p <- ggplot(pairs, aes(sample1, sample2)) + geom_tile(data=subset(pairs,region == "NDgene"),aes(fill = pval),
#           colour = "white") + scale_fill_gradient(low = "white",
#        high = "steelblue")) + labs(y="Sample1",x="Sample2",fill="p-value (log)")
dev.off()
