#!/TL/opt/bin/Rscript
#!/TL/opt/bin/R3script
#CALL: R3script rapidStats.r <outputFolder> <AnnotationFile>
args <- commandArgs(trailingOnly = TRUE)
filename=as.character(args[1])
annotationfile=as.character(args[2])

computeRegionLengths <- function(data){
  #process
  names(data)=c("chr","start","end","label","type","strand")
  #compute lengths
  singleLengths=apply(data,1,function(x){return(as.numeric(x[3])-as.numeric(x[2])+1)})
  dummyDF=data.frame(label=data$label,lens=singleLengths)
  res=by(dummyDF,dummyDF$label,function(x){sum(x$lens)})
  return(data.frame(region=as.character(names(res)),lens=as.numeric(res)))
}

addLengthColumnToStats <- function(dfStats,lens){
  Lengths=computeRegionLengths(lens)
  df2=dfStats
  dfStats = merge(df2,Lengths,by="region")
  return(dfStats)
}


#Calculates TPM
calcTPM <- function(df, annot) {
  colnames(df) = df[1, ]
  df=df[-c(1),]
  if(class(df)=="character"){
    df=t(as.matrix(df)) 
  }
  df = addLengthColumnToStats(df, annot)
  df$reads=as.integer(as.character(df$reads))
  df$lens=as.integer(as.character(df$lens))
  df$RPK=(df$reads/df$lens)*1000
  df$TPM=df$RPK/(sum(df$RPK)/1e+06)
  df$RPK=NULL
  df$lens=NULL
  df$reads=as.character(df$reads)
  df$TPM=as.character(df$TPM)
  return(df)
}

annotations=read.table(annotationfile,header=F,stringsAsFactors=FALSE)
names(annotations)=c("chr","start","end","label","type","strand")
outStats=paste(filename,"Statistics.dat",sep="")
tt=read.table(paste(filename,"alignedReads.sub.compact",sep=""),stringsAsFactors=FALSE)
tt$ID=paste(tt$V1,tt$V2,tt$V3,tt$V4,sep="")
tt$LM=paste(tt$V2,tt$V3,sep="")
tt$LS=paste(tt$V2,tt$V4,sep="")
nomodtt=subset(tt,V5 != "-")
nomodtt$LSEQ=paste(nomodtt$V2,nomodtt$V5,sep="")
tt$MS=paste(tt$V4,tt$V3,sep="")
stt=subset(tt,V5 != "-")
tab=table(stt$V5)
rmin=range(tt$V2)[1]-1
rmax=range(tt$V2)[2]+1

##create datastructure that counts reads per length per region and strand
allNames=annotations$label[!duplicated(annotations$label)]
#names=paste(c(17:25,17:25),c(rep("+",9),rep("-",9)),sep="")
names=paste(c((rmin+1):(rmax-1), (rmin+1):(rmax-1)), c(rep("+", rmax-rmin-1), rep("-", rmax-rmin-1)), sep = "")
allCounts=rep(0,length(names))
#names(allCounts)=names
for(name in allNames){
  counts=rep(0,length(names))
  subb=subset(tt,V1 == name)
  idx=which(annotations$label==name)
  strandInfo=annotations$strand[idx][1]
  if(strandInfo=="-") {
    subb$LS=sub('\\+$','t',subb$LS)
    subb$LS=sub('\\-$','+',subb$LS)
    subb$LS=sub('t$','-',subb$LS)
  }
  for (i in 1:length(names)){
    #counts[i]=length(grep(names[i],tt$LS,fixed=T))
    counts[i]=nrow(subset(subb,LS == names[i]))
  }
  allCounts=rbind(allCounts,counts)
  
}
#remove first dummy row
allCounts=allCounts[-1,]
#stats function returns line of stats for each matrix of alignments
computeStats <- function(subMatrix,header){
  reads=nrow(subMatrix)
  mod=nrow(subset(subMatrix,V3 == "Y"))
  stranded=nrow(subset(subMatrix,V4 == "-"))
  Aplus=nrow(subset(subMatrix,V4 == "+" & V5 == "A"))
  Cplus=nrow(subset(subMatrix,V4 == "+" & V5 == "C"))
  Gplus=nrow(subset(subMatrix,V4 == "+" & V5 == "G"))
  Tplus=nrow(subset(subMatrix,V4 == "+" & V5 == "T"))
  Aminus=nrow(subset(subMatrix,V4 == "-" & V5 == "A"))
  Cminus=nrow(subset(subMatrix,V4 == "-" & V5 == "C"))
  Gminus=nrow(subset(subMatrix,V4 == "-" & V5 == "G"))
  Tminus=nrow(subset(subMatrix,V4 == "-" & V5 == "T"))
  Aratio=round(Aminus/(Aplus+Aminus),2)
  Cratio=round(Cminus/(Cplus+Cminus),2)
  Gratio=round(Gminus/(Gplus+Gminus),2)
  Tratio=round(Tminus/(Tplus+Tminus),2)
  if(reads==0){
    ASratio=0
    MODratio=0
  }
  else {
    ASratio=round(stranded/reads,2)
    MODratio=round(mod/reads,2)
  }
  return(as.character(c(header,reads,mod,MODratio,stranded,ASratio,Aplus,Cplus,Gplus,Tplus,Aminus,Cminus,Gminus,Tminus,Aratio,Cratio,Gratio,Tratio)))
}

computeStatsNeg <- function(subMatrix,header){
  reads=nrow(subMatrix)
  mod=nrow(subset(subMatrix,V3 == "Y"))
  stranded=nrow(subset(subMatrix,V4 == "+"))
  Aminus=nrow(subset(subMatrix,V4 == "+" & V5 == "A"))
  Cminus=nrow(subset(subMatrix,V4 == "+" & V5 == "C"))
  Gminus=nrow(subset(subMatrix,V4 == "+" & V5 == "G"))
  Tminus=nrow(subset(subMatrix,V4 == "+" & V5 == "T"))
  Aplus=nrow(subset(subMatrix,V4 == "-" & V5 == "A"))
  Cplus=nrow(subset(subMatrix,V4 == "-" & V5 == "C"))
  Gplus=nrow(subset(subMatrix,V4 == "-" & V5 == "G"))
  Tplus=nrow(subset(subMatrix,V4 == "-" & V5 == "T"))
  Aratio=round(Aminus/(Aplus+Aminus),2)
  Cratio=round(Cminus/(Cplus+Cminus),2)
  Gratio=round(Gminus/(Gplus+Gminus),2)
  Tratio=round(Tminus/(Tplus+Tminus),2)
  if(reads==0){
    ASratio=0
    MODratio=0
  }
  else {
    ASratio=round(stranded/reads,2)
    MODratio=round(mod/reads,2)
  }
  return(as.character(c(header,reads,mod,MODratio,stranded,ASratio,Aplus,Cplus,Gplus,Tplus,Aminus,Cminus,Gminus,Tminus,Aratio,Cratio,Gratio,Tratio)))
}

#create table for stats results
Stats=c("region","reads","modified","MODratio","antisenseReads","ASratio","A+","C+","G+","T+","A-","C-","G-","T-","Aratio","Cratio","Gratio","Tratio")
for(name in allNames){
subtt=subset(tt,V1==name)
subtt=subset(subtt, V2 > rmin & V2 < rmax)
#subtt=subset(subtt, V2 > 16 & V2 <27)
#add statistics for this subset
idx=which(annotations$label==name)
strandInfo=annotations$strand[idx][1]
if(strandInfo=="+") {
  Stats=rbind(Stats,computeStats(subtt,name))
} else {
  #For -ve gene direction
  Stats=rbind(Stats,computeStatsNeg(subtt,name))
}
}
Stats2=calcTPM(Stats, annotations)
names(Stats2)=NULL
Stats2=data.frame(lapply(Stats2, as.character), stringsAsFactors=FALSE)
thead=c("region","reads","modified","MODratio","antisenseReads","ASratio","A+","C+","G+","T+","A-","C-","G-","T-","Aratio","Cratio","Gratio","Tratio","TPM")
Stats=rbind(thead,as.data.frame(Stats2))

#add the header line of allCounts to the matrix to have the same nrow then Stats
allCounts = rbind(names,allCounts)
Stats=cbind(Stats,allCounts)
write.table(Stats,outStats,quote=F,col.names=F,row.names=F,sep=" ")
