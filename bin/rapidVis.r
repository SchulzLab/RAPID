#!/TL/opt/bin/Rscript
#CALL: Rscript Rscript rapidVis.r <outputFolder_of_rapidStats.sh or rapidNorm.sh> <AnnotationFile> <plotMethod>
#load libraries
library("ggplot2")
library("scales")
args <- commandArgs(trailingOnly = TRUE)
plotMethod=as.character(args[1]) #value for differentiating Individual or Comparison Plots (stats, compare)

if(plotMethod=="stats"){
args <- commandArgs(trailingOnly = TRUE)
filename=as.character(args[2])
annotationfile=as.character(args[3])
#################################For Individual Results
annotations=read.table(annotationfile,header=F,stringsAsFactors=FALSE)
outPlot=paste(filename,"Results.pdf",sep="")
tt=read.table(paste(filename,"alignedReads.sub.compact",sep=""),stringsAsFactors=FALSE)
allNames=annotations$V4[!duplicated(annotations$V4)] #Need to change this if we need to parse only a subset of regions

pdf(outPlot)

for(name in allNames){
par(mfrow=c(3,1))
#single category plots
subtt=subset(tt,V1==name)
subtt=subset(subtt, V2 > 16 & V2 <27)

if(nrow(subtt)>0){
aligned=nrow(subtt)
barplot(table(subtt$V2)/aligned*100,ylab="%",main=paste("Read lengths",name,filename,aligned,sep=" - "))
barplot(table(subtt$V3)/aligned*100,ylab="%",main=paste("Modifications",name,aligned,sep=" - "))
barplot(table(subtt$V4)/aligned*100,ylab="%",main=paste("Strand distribution",name,aligned,sep=" - "))
par(mfrow=c(2,1))
tab=table(subset(tt,V1==name & V5 != "-")$V5)
aligned=nrow(subset(tt,V1==name))
if(length(tab) >0){
threshold=nrow(subset(tt,V1==name & V5 != "-"))*0.05
threshold=max(threshold,1)

barplot(tab[tab>=threshold],main=paste("Read Modifications minimum",threshold,name ,sep=" "))
barplot(tab[tab>=threshold]/aligned*100,ylab="%",main=paste("Read Modifications minimum",threshold, name, sep=" - "))
}
par(mfrow=c(2,1))
#double category plots
#barplot(table(subset(tt,V1==name)$LS)/nrow(subset(tt,V1==name))*100,ylab="%",main=paste("Read strand by length",name,sep=" - "))
counts=table(subtt$V4,subtt$V2)
barplot(counts,legend= rownames(counts),ylab="count",main=paste("Read strand by length",name,sep=" - "))
counts=table(subtt$V3,subtt$V2)
barplot(counts,legend= rownames(counts),ylab="count",main=paste("Read modifications by length",name,sep=" - "))
counts=table(subtt$V3,subtt$V4)
barplot(counts,legend= rownames(counts),ylab="count",main=paste("Read modifications by strand",name,sep=" - "))

#check if alignments are corrected, if minimum frequency is achieved
#nrow(subset(tt,V5 != "-"))

if(length(tab) >0){
  #create subset with 1-base modifications
  modtt=subset(subtt,V5 %in% c("A","C","G","T"))
  if(nrow(modtt) >0){
        counts=table(modtt$V5,modtt$V2)
        barplot(counts,legend= rownames(counts),ylab="count",main=paste("Read length by modification",name, aligned,sep=" - "))
}
}
}
}

dev.off()
##################################################For Individual Results - END
}
if(plotMethod=="compare"){
out=args[2]
#config=args[3]
#annot=args[4]
#restrictLength=args[5]
#################################For Comparative Results
#load libraries
#library("ggplot2")
#library("scales")
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
#nosamples=data.frame(table(dfa$region))$Freq[1]
#noregions=data.frame(table(dfa$samples))$Freq[1]
#regionValues=rep(1:noregions,nosamples)
#sampleValues=rep(1:nosamples, each=noregions)
#dafr=data.frame(region=regionValues,readCounts=dfa$readCounts,readCountsNorm=dfa$readCountsNorm,readCountsAvg=dfa$readCountsAvg,ASratio=dfa$ASratio,samples=sampleValues)
#show(dafr)
allowed<-unique(dfa$region)
#show(allowed)
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
