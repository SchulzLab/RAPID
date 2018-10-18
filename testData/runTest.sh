##
## This document is a test run for the RAPID pipeline.
## It contains a small set of reads that are aligned against a gene
## with two regions in the Regions.bed
## After the first part of the pipeline (rapidStats) is complete, an example comparative
## analysis (with three times the same data) is run to verify the different outputs through rapidVis.r
## rapidVis.r test run for normalization output is excluded, as the quality plots (like MDS) would fail because of identical data.
##
## Note that bedtools2, bowtie2, samtools (for bam support) and the RAPID bin folder should be in your PATH
## otherwise uncomment the lines below and add the paths.

#add programs to path 
#PATH=$PATH:/  #bowtie 2
#PATH=$PATH:/  #samtools
#PATH=$PATH:/  #bedtools2
#PATH=$PATH:/  #RAPID/bin/

#rapid=/home/software/RAPID-master/bin/
#rapid=/MMCI/MS/smallRNA-1/work/paramecium/softwares/githubrepos/RAPID/bin/
#rapid=/Users/siva/Softwares/miniconda2/envs/testrapid/bin/
rapid=/Users/siva/Softwares/githubrepos/RAPID/bin

#first create a rapid analysis of a small data set with 1 gene and 2 regions
bash ${rapid}/rapidStats.sh --file=test.fastq.gz --out=TestRapid/ --remove=yes --annot=Regions.bed --index=./GeneIndex --rapid=$rapid

#second use the config file test.config to generate a toy comparative analysis
bash ${rapid}/rapidNorm.sh --conf=test.config --out=TestCompare/ --annot=Regions.bed  --rapid=$rapid

#third run the rapidVis pipeline to generate the visualizations for both rapidStats and rapidNorm
Rscript ${rapid}/rapidVis.r stats ./TestRapid/Regions/ ./Regions.bed $rapid
