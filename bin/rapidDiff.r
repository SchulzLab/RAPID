#!/usr/bin/env Rscript

#load libraries
library("DESeq2")
library("ggplot2")
library("RColorBrewer")
library("gplots")
####FUNCTIONS####
parseStatsGetReadCountFile <- function(path){
  full=paste(path,"/Statistics.dat",sep="")
  stats=read.table(full,header=T,sep=" ",stringsAsFactors=FALSE)
  #check if variable is defined then updated Stats values 
  if(!is.na(restrictLength)){
    # update reads column in each Stats entry to the sum of the counts 
    # in the columns of given read counts
    restrictPattern=gsub(',','|',restrictLength)
    indices=grep(restrictPattern,names(stats))
    if(length(indices) > 0){
        stats$reads=apply(stats[,indices],1,sum)
    }
  }
  dfa=data.frame(stats$region, stats$reads)
  write.table(dfa,paste(path,"/readCounts.txt",sep=""),quote=F,row.names=F, col.names=F, sep="\t")
}
####DONE FUNCTIONS####
args <- commandArgs(trailingOnly = TRUE)

config=args[1]
out=args[2]
ALPHA=as.numeric(args[3])
restrictLength=args[4]

conf=read.table(config,header=T,sep="\t",stringsAsFactors=FALSE)
lapply(conf$location,parseStatsGetReadCountFile)
sampleTable=data.frame(sampleName=conf$sampleName, filename=paste(conf$location,"/readCounts.txt",sep=""), condition=conf$condition)

#This working directory changing is done, because the DESeqDataSetFromHTSeqCount function uses "./" before the location we provide.
actWD<-getwd()
setwd("/")
ddsHTSeq<-DESeqDataSetFromHTSeqCount(sampleTable=sampleTable, design=~condition)
setwd(actWD)

colData(ddsHTSeq)$condition<-factor(colData(ddsHTSeq)$condition, levels=c("untreated","treated"))
dds<-DESeq(ddsHTSeq)
res<-results(dds)
deStats<-as.data.frame(cbind(assay(dds), res$baseMean, res$log2FoldChange, res$lfcSE, res$stat, res$pvalue, res$padj))
colnames(deStats)=t(c(colnames(assay(dds)),colnames(res)))
write.table(deStats,paste(out,"DiffExp_Statistics.csv",sep=""),quote=F,sep=",",col.names=NA)
res<-res[order(res$padj),]

#Making Plots as a PDF file
pdf(paste(out,"DiffExp_Plots.pdf",sep=""))

#MAPlot
print(plotMA(res,main="MAPlot",alpha=ALPHA,colNonSig="blue",colLine=NULL,cex=0.6))
#print(plotMA(dds,main="MAPlot",alpha=ALPHA))

#Data Transformation
vsd <- varianceStabilizingTransformation(dds, blind=TRUE)

#Heatmaps For different transformations
#selection<-rownames(res)[1:NVAL]
selection<-rownames(na.omit(res[(res$padj[complete.cases(res$padj)]<ALPHA),]))
cpalette<-colorRampPalette(c("red", "yellow", "green"))(n = 128)
#celtextm<-as.data.frame(rep(transform(round(res$padj[1:NVAL],4)),4))
print(heatmap.2(assay(vsd)[selection,], col = cpalette, margin=c(9,9), density.info="none", scale="none", trace="none", srtRow=0, srtCol=30, key.xlab = "Read Count", cexRow = 0.5, cexCol = 0.75))

#PCA Plot
pcaPl<-plotPCA(vsd,intgroup=c("condition"),returnData=TRUE)
print(ggplot(pcaPl,aes(PC1, PC2,color=condition))+geom_point(size=3))
dev.off()

print(paste("No. of DE genes w.r.t cut-off:", length(selection), sep=""))
