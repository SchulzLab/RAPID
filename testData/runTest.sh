#test the new RAPID pipeline
rapid=/home/mschulz/smallRNA/software/github/RAPID/bin/
data=/home/mschulz/smallRNA/paramecium/data/
#add programs to path
PATH=$PATH:/home/mschulz/smallRNA/software/bowtie2-2.1.0/
PATH=$PATH:/home/mschulz/smallRNA/software/samtools-0.1.19/
PATH=$PATH:/home/mschulz/smallRNA/software/bedtools2/bin/
PATH=$PATH:/home/mschulz/smallRNA/software/github/RAPID/bin/

bash ${rapid}rapid_main.sh --file=test.fastq.gz --out=TestRapid/ --rapid=$rapid --annot=Regions.bed --index=/home/mschulz/smallRNA/software/github/RAPID/testData/GeneIndex 

