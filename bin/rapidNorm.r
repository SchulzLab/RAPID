#!/TL/opt/bin/Rscript
#!/TL/opt/bin/R3script
#CALL: Rscript rapidNorm.R <configFile> <AnnotationFile> <OutputFolder> <LengthRestrictionIfAny>

#load libraries
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
  names(data)=c("chr","start","end","label","type","strand")
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

normalizeEntries <- function(Stats,oldTotal,adjustForBackground=TRUE,normalizeByLength=TRUE, normalizeByDESeq=FALSE){
  #the default is to adjust the counts for any small RNA background counts obtained and for region length
  #Note: that if the 3rd column of the config file has the entry none, then no count is substracted
  Total=oldTotal
  if(adjustForBackground){
    for (i in 1:length(Stats)){
      Total[i]=Total[[i]]-countBackgroundReads(Stats[[i]],conf$background[i])
    }
  }
  
  if(normalizeByDESeq){
    library("DESeq2")
    newList=Stats
    readData=as.data.frame(Stats[[1]]$region)
    for(i in 1:length(Stats)){ 
      readData=cbind(readData,Stats[[i]]$reads)
    }
    colnames(readData)=c("Regions",c(1:length(Stats)))
    readData$Regions=NULL
    sizes=estimateSizeFactorsForMatrix(readData)
    for (i in 1:length(Stats)){
      newList[[i]]$reads_norm=round(newList[[i]]$reads/sizes[i],digits = 0)
      newList[[i]]$asreads_norm=round(newList[[i]]$antisenseReads/sizes[i],digits = 0)
      newList[[i]]$asratio_norm=round(newList[[i]]$asreads_norm/newList[[i]]$reads_norm,digits=2)
      newList[[i]]$asratio_norm[is.na(newList[[i]]$asratio_norm)]=0
      if(normalizeByLength){
        newList[[i]]$reads_avg=round( (newList[[i]]$reads_norm/newList[[i]]$lens),digits=3)
      }
      newList[[i]]$RPK=(newList[[i]]$reads/newList[[i]]$lens)*1000
      newList[[i]]$TPM=round(newList[[i]]$RPK/(sum(newList[[i]]$RPK)/1e+06), digits = 3)
      newList[[i]]$RPK=NULL
    }
  }
  else {
    Max=getMax(Total)
    newList=Stats
    for (i in 1:length(Stats)){
      newList[[i]]$reads_norm=round(newList[[i]]$reads*(Max/Total[[i]]),digits=0)
      newList[[i]]$asreads_norm=round(newList[[i]]$antisenseReads*(Max/Total[[i]]),digits=0)
      newList[[i]]$asratio_norm=round(newList[[i]]$asreads_norm/newList[[i]]$reads_norm,digits=2)
      newList[[i]]$asratio_norm[is.na(newList[[i]]$asratio_norm)]=0
      if(normalizeByLength){
        newList[[i]]$reads_avg=round( (newList[[i]]$reads_norm/newList[[i]]$lens),digits=3)
      }
      newList[[i]]$RPK=(newList[[i]]$reads/newList[[i]]$lens)*1000
      newList[[i]]$TPM=round(newList[[i]]$RPK/(sum(newList[[i]]$RPK)/1e+06),digits = 3)
      newList[[i]]$RPK=NULL
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
  readCountsTPM=rep(Stats[[1]]$TPM,numDatasets)
  readCountsNorm=rep(Stats[[1]]$reads_norm,numDatasets)
  ASreadCountsNorm=rep(Stats[[1]]$asreads_norm,numDatasets)
  readCountsAvg=rep(Stats[[1]]$reads_avg,numDatasets)
  ASratio=rep(Stats[[1]]$ASratio,numDatasets)
  ASratioNorm=rep(Stats[[1]]$asratio_norm,numDatasets)
  
  names=rep(conf$name[1],numDatasets*rows)
  for(i in 1:(numDatasets-1)){
    readCounts[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads
    readCountsTPM[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$TPM
    readCountsNorm[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads_norm
    ASreadCountsNorm[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$asreads_norm
    readCountsAvg[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$reads_avg
    ASratio[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$ASratio
    ASratioNorm[(i*rows+1):((i+1)*rows)] = Stats[[i+1]]$asratio_norm
    names[(i*rows+1):((i+1)*rows)] = rep(conf$name[i+1],rows)
  }
  df=data.frame(region = rep(Stats[[1]]$region,numDatasets), readCounts=readCounts, readCountsTPM=readCountsTPM, readCountsNorm=readCountsNorm, readCountsAvg=readCountsAvg, ASratio=ASratio, ASreadCountsNorm=ASreadCountsNorm, ASratioNorm=ASratioNorm, samples=names)
  return(df)
}

####DONE FUNCTIONS####
args <- commandArgs(trailingOnly = TRUE)

config=args[1]
annot=args[2]
out=args[3]
useDEseq=args[4]
restrictLength=args[5]

#load datasets 
conf=read.table(config,header=T,sep="\t",stringsAsFactors=FALSE)
lens=read.table(annot,header=F,stringsAsFactors=FALSE)
names(lens)=c("chr","start","end","region","type","strand")
Stats=lapply(conf$location,readStatistics)
Total=lapply(conf$location,readTotal)

#check if variable is defined then updated Stats values 
if(!is.na(restrictLength)){
  # update reads column in each Stats entry to the sum of the counts 
  # in the columns of given read counts
  restrictPattern=gsub(',','|',restrictLength)
  #show(paste(restrictPattern)) 
  for (i in 1:length(Stats)){
    indices=grep(restrictPattern,names(Stats[[i]]))
    #show(paste(indices))
    if(length(indices) > 0){
      Stats[[i]]$reads=apply(Stats[[i]][,indices],1,sum)
    }
  }
}


#add length column
Stats=addLengthColumnToStats(Stats,lens)

#normalize read counts
if(useDEseq){
  normalized=normalizeEntries(Stats,Total,normalizeByDESeq=TRUE)
} else {
  normalized=normalizeEntries(Stats,Total,normalizeByDESeq=FALSE) 
}

allowed= unique(subset(lens,type == "region")$region)

#Filter only the non-background regions. Also enables to use different bed files while using rapidStats, although it is not advised.
normalizedSub = normalized
for(i in 1:length(normalized)){
  normalizedSub[[i]]=subset(normalized[[i]], region %in% allowed)
}

df=createPlottingData(normalizedSub,conf)
#save data.frame in output folder
write.table(subset(df,region %in% allowed),paste(out,"NormalizedValues.dat",sep=""),quote=F,row.names=F,sep="\t")


