##
## This document is a test run for the RAPID pipeline.
## It contains a small set of reads that are aligned against a gene
## with two regions in the Regions.bed
## After the first part of the pipelien (rapid_main) is run an example comparative
## analysis (with three times the same data) is run to illustrate the different outputs
##
## Note that bedtools2, bowtie2, samtools (fro bam support) and the RAPID bin folder should be in your PATH
## otherwise uncomment the lines below and at the paths.
#add programs to path 
#PATH=$PATH:/  #bowtie 2
#PATH=$PATH:/  #samtools
#PATH=$PATH:/  #bedtools2
#PATH=$PATH:/  #RAPID/bin/
#rapid=/home/skarunan/software/RAPID-master/bin/
#first create a rapid analysis of a small data set with 1 gene and 2 regions

bash ${rapid}rapid_main.sh --file=test.fastq.gz --out=TestRapid --bam=yes --remove=no --annot=Regions.bed --index=./GeneIndex
 
#second use the config file test.config to generate a toy comparative analysis

bash ${rapid}rapid_compare.sh --conf=test.config --out=TestCompare --annot=Regions.bed  
