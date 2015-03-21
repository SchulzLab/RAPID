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
ANNOT=""
INDEX=""
CONTAMIN="no"
INDEXCONT=""
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
    echo "-h|--help"
    echo "-o|--out= path to the output directory, directory will be created if non-existent"
    echo "-f|--file= the read fastq file (currently in fastq format)"
    echo "-a|--annot=file.bed : bed file with regions that should be annotated with read alignments"
    echo "-r|--rapid=PATH/ set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable"
    echo "-i|--index=PATH/ set location of the bowtie2 index for alignment" 
    echo "--bam=yes : create sorted and indexed bam file (default no, needs samtools on path)"
    echo "--contamin=yes : use a double alignment step first aligning to a contamination file (default no)"
    echo "--indexco=PATH/ set location of the contamination bowtie2 index for alignment (only with contamin=yes)" 
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
        -f | --file)
            FILE=$VALUE
            ;;
        -o | --out)
            OUT=$VALUE
            ;;
        --rapid)
            BIN=$VALUE
            ;;
        -a | --annot)
            ANNOT=$VALUE
            ;;
        --bam)
            BAM=$VALUE
            ;;
        --contamin)
            CONTAMIN=$VALUE
            ;;
        -i | --index)
            INDEX=$VALUE
            ;;
        --indexco)
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

#create project 
mkdir -p $OUT/
new=${OUT}/aligned

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







