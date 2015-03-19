#!/bin/bash
 
#
# RAPID
# Read Alignment and Analysis Pipeline
# 
 
# Copyright (C) 2014 Marcel H. Schulz 
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


VERSION="0.1"
OUT=""
FILE=""
BIN=""
ANNOT="/home/mschulz/smallRNA/paramecium/scripts/AnnotationRegions.bed"
INDEX=""
CONTAMIN="no"
INDEXCONT=""
COLLAPSE="no"
BAM="no"
REMOVE="yes"

function usage()
{
    echo " _________________________________________________"
echo "|_______               ________       _____      |"
echo "|  |    |                 |    |   I    |  \\     |"
echo "|  |    |      /\\         |    |   I    |   \\    |"
echo "|  |____|     /  \\        |____|   I    |    |   |"
echo "|  |\\        /____\\       |        I    |    |   |"
echo "|  | \\      /      \\      |        I    |    |   |"
echo "|  |  \\    /        \\     |        I    |   /    |"
echo "|  |   \\  /          \\    |        I    |__/     |"
echo "|                                                |"
echo "| -Read Alignment and Analysis Pipeline- V $VERSION   |"
echo "|________________________________________________|"
    echo "Usage: "
    echo ""
    echo "./rapid_main.sh -o=complete/path/outputDirectory -file=reads.fastq "
    echo "Parameters:"
    echo "-h --help"
    echo "-o= path to the output directory, directory will be created if non-existent"
    echo "--file= the read fastq file (currently in fastq format)"
    echo "--annot=file.bed : bed file with regions that should be annotated with read alignments"
    echo "--rapid=PATH/ set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable"
   # echo "--collapse=yes : activate read collapsing (default no)"
    echo "--bam=yes : create sorted and indexed bam file (default no, needs samtools on path)"
    echo "--index=PATH/ set location of the bowtie2 index for alignment" 
    echo "--contamin=yes : use a double alignment step first aligning to a contamination file (default no)"
    echo "--indexcont=PATH/ set location of the contamination bowtie2 index for alignment (only with contamin=yes)" 
    echo "--remove=yes : remove unecessary intermediate files (default yes)"
    echo ""
    echo ""
}
 
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --file)
            FILE=$VALUE
            ;;
        --out)
            OUT=$VALUE
            ;;
        --rapid)
            BIN=$VALUE
            ;;
        --annot)
            ANNOT=$VALUE
            ;;
        --collapse)
            COLLAPSE=$VALUE
            ;;
        --bam)
            BAM=$VALUE
            ;;
        --contamin)
            CONTAMIN=$VALUE
            ;;
        --index)
            INDEX=$VALUE
            ;;
        --indexcont)
            INDEXCONT=$VALUE
            ;;
        --remove)
            REMOVE=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

 ######Done parameter parsing######

 
#ERROR HANDLING#

if [ -z "$OUT" ]
    then
        echo "ERROR no outfolder defined "
        usage
        exit 1
fi   
if [ -z "$FILE" ]
    then
        echo "ERROR no input file defined "
        usage
        exit 1
fi
if [ -z "$INDEX" ]
    then
        echo "ERROR no bowtie2 index path given "
        usage
        exit 1
fi  


#Main routines#

 #should be in path
#bowtie=/home/mschulz/smallRNA/software/bowtie2-2.1.0/bowtie2
#samtools=/home/mschulz/smallRNA/software/samtools-0.1.19/samtools
#bedtools=/home/mschulz/smallRNA/software/bedtools2/bin/

#temp variables
#data=/home/mschulz/smallRNA/paramecium/data/
#out=/home/mschulz/smallRNA/paramecium/analysis/transgene_contamin/
#scripts=/home/mschulz/smallRNA/paramecium/scripts/

mkdir -p $OUT/
new=${OUT}/aligned

#collapse read file into unqiue reads if desired:
#if [ $COLLAPSE == "yes" ]
  # perl${BIN}rapid_ToFasta.pl $FILE  | ${BIN}fastx_collapser > ${new}_collapsed_reads.fa
  # bowtie2 -p 20  -k 2 -x /home/mschulz/smallRNA/paramecium/templates/OnlyContaminations -f ${new}_collapsed_reads.fa  --un ${new}_unmappedReads.fa -S ${new}_contamination.sam 2> ${new}_bowtie.LOG  

if [ $CONTAMIN == "yes" ]
    then
	echo run two-step alignment by aligning first to contamination index  ${INDEXCONT}
        bowtie2 -p 20  -k 2 -x ${INDEXCONT}  -U ${FILE}  --un ${new}_unmappedReads.fastq -S ${new}_contamination.sam 2> ${new}_bowtie.LOG  
	#reset FILE name to unmapped reads
	FILE=${new}_unmappedReads.fastq
    else
        echo run alignment with index ${INDEX}
        bowtie2 -p 20 --local -k 100 -x ${INDEX} -U ${FILE}  -S ${new}.sam  2> ${new}_bowtie_final.LOG 
fi



#format for R
#count number of mapping reads
awk 'BEGIN{sum=0}{if($0 ~ "1 time"){sum=sum+$1;}}END{print sum}' ${new}_bowtie_final.LOG > ${OUT}/TotalReads.dat

#compute statisticis for aligned reads of different lengths:
awk '{if( $1 !~ "4" && NF > 5){print $0}}' ${new}.sam | cut -f 10 |  uniq| awk '{if($0 !~ "^0"){print length($0)}}' | sort | uniq -c > ${new}_lengths.dat

if [ $BAM == "yes" ]
    then
        #create bam
            $samtools view -S -b ${new}.sam >  ${new}.bam
        #sort and 
            $samtools sort ${new}.bam ${new}_sorted
        #index
            $samtools index ${new}_sorted.bam 
fi

######Postprocess data######

#create summary gff file from SAM alignment files
perl ${BIN}rapid_ParseSam.pl ${new}.sam  > ${OUT}/alignedReads.gff

echo compute overlap with regions in bed file ${ANNOT}
intersectBed -a ${OUT}/alignedReads.gff -b ${ANNOT} -f 1 > ${OUT}/alignedReads.intersect -wao

#produce reduced output after using Bedtools
awk '{if($9 ~ /M*S/){add="Y"}else{add="N"};print $13,$6,add,$7,$8}' ${OUT}/alignedReads.intersect | awk '{if($1 !~ /\./){print $0}}' > ${OUT}/alignedReads.sub.compact

#remove intermediate files

if [ $REMOVE == "yes" ]
    then
	echo removing intermediate files
	rm ${OUT}/alignedReads.intersect 
	rm ${OUT}/alignedReads.gff 
	rm ${OUT}/aligned.sam 
	
fi

#generate Plots for 
Rscript ${BIN}/rapid_SummaryDataset.r ${OUT} ${ANNOT} >${OUT}/R_Errors.log 2>&1 







