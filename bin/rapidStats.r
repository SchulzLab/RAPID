#!/TL/opt/bin/Rscript
#CALL: Rscript Rscript rapidStats.r <outputFolder> <AnnotationFile>
args <- commandArgs(trailingOnly = TRUE)
filename=as.character(args[1])
annotationfile=as.character(args[2])
annotations=read.table(annotationfile,header=F,stringsAsFactors=FALSE)
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
##create datastructure that counts reads per length per region and strand
allNames=annotations$V4[!duplicated(annotations$V4)]
names=paste(c(17:25,17:25),c(rep("+",9),rep("-",9)),sep="")
allCounts=rep(0,length(names))
#names(allCounts)=names
for(name in allNames){
  counts=rep(0,length(names))
  subb=subset(tt,V1 == name)
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
  ASratio=round(stranded/reads,2)
  MODratio=round(mod/reads,2)
  return(as.character(c(header,reads,mod,MODratio,stranded,ASratio,Aplus,Cplus,Gplus,Tplus,Aminus,Cminus,Gminus,Tminus,Aratio,Cratio,Gratio,Tratio)))
}
#create table for stats results
Stats=c("region","reads","modified","MODratio","antisenseReads","ASratio","A+","C+","G+","T+","A-","C-","G-","T-","Aratio","Cratio","Gratio","Tratio")
for(name in allNames){
subtt=subset(tt,V1==name)
subtt=subset(subtt, V2 > 16 & V2 <27)
#add statistics for this subset
Stats=rbind(Stats,computeStats(subtt,name))
}
#add the header line of allCounts to the matrix to have the same nrow then Stats
allCounts = rbind(names,allCounts)
Stats=cbind(Stats,allCounts)
write.table(Stats,outStats,quote=F,col.names=F,sep=" ")

