##
## This document is a test run for the RAPID pipeline.
## It contains a small set of reads that are aligned against a gene
## with two regions in the Regions.bed
## After the first part of the pipeline (rapidStats) is complete, an example comparative
## analysis (with three times the same data) is run to verify the different outputs through rapidVis.r
##
## Note that bedtools2, bowtie2, samtools (for bam support) should be in your PATH
## otherwise uncomment the lines below and add the paths.
##
## We recommend to use RAPID as a conda environment, where the software PATHs are automatically created.
## However, If you install RAPID manually, ensure RAPID's bin directory is in the PATH or set an environment variable and pass it in the scripts.
## 




############################################################## UNCOMMENT THE RESPECTIVE PARTS TO RUN THE SCRIPT ############################################################## 


#### TEST FOR CONDA ENVIRONMENT ####

rapidStats.sh --file=test.fastq.gz --out=TestRapid/ --remove=yes --annot=Regions.bed --index=./GeneIndex -p=2

rapidNorm.sh --conf=test.config --out=TestCompare/ --annot=Regions.bed

rapidVis.sh -t=stats -o=./TestRapid/Regions/ -a=./Regions.bed
rapidVis.sh -t=compare -o=./TestCompare/



#### TEST FOR MANUAL INSTALLATION (If RAPID's location is added to System PATH variable) ####
#add programs to path 
#PATH=$PATH:/  #bowtie 2
#PATH=$PATH:/  #samtools
#PATH=$PATH:/  #bedtools2
#PATH=$PATH:/  #RAPID/bin/

#first create a rapid analysis of a small data set with 1 gene and 2 regions
#bash ${rapid}/rapidStats.sh --file=test.fastq.gz --out=TestRapid/ --remove=yes --annot=Regions.bed --index=./GeneIndex -p=2

#second use the config file test.config to generate a toy comparative analysis
#bash ${rapid}/rapidNorm.sh --conf=test.config --out=TestCompare/ --annot=Regions.bed

#third run the rapidVis pipeline to generate the visualizations for both rapidStats and rapidNorm
#bash ${rapid}/rapidVis.sh -t=stats -o=./TestRapid/Regions/ -a=./Regions.bed
#bash ${rapid}/rapidVis.sh -t=compare -o=./TestCompare/



#### TEST FOR MANUAL INSTALLATION (If RAPID's location is set only as an environment variable) ####

#rapid=/Users/siva/Softwares/miniconda2/envs/testrapid/bin/
#rapid=/Users/siva/Softwares/githubrepos/RAPID/bin

#bash ${rapid}/rapidStats.sh --file=test.fastq.gz --out=TestRapid/ --remove=yes --annot=Regions.bed --index=./GeneIndex --rapid=$rapid/ -p=2

#bash ${rapid}/rapidNorm.sh --conf=test.config --out=TestCompare/ --annot=Regions.bed  --rapid=$rapid/

#bash ${rapid}/rapidVis.sh -t=stats -o=./TestRapid/Regions/ -a=./Regions.bed -r=${rapid}
#bash ${rapid}/rapidVis.sh -t=compare -o=./TestCompare/ -r=${rapid}
