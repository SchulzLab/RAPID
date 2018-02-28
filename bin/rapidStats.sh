#!/bin/bash
 
#
# RAPID
# Read Alignment, Analysis, and Differential Pipeline
# 
 
# Copyright (C) 2018 Marcel H. Schulz  and Sivarajan Karunanithi
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
REMOVE="yes"
FILETYPE="fq"

function usage()
{
    echo " ________________________________________________________________"
echo "|_______               ________       _____                          |"
echo "|  |    |                 |    |   I    |  \\                        |"
echo "|  |    |      /\\         |    |   I    |   \\                      |"
echo "|  |____|     /  \\        |____|   I    |    |                      |"
echo "|  |\\        /____\\       |        I    |    |                     |"
echo "|  | \\      /      \\      |        I    |    |                     |"
echo "|  |  \\    /        \\     |        I    |   /                      |"
echo "|  |   \\  /          \\    |        I    |__/                       |"
echo "|                                                                    |"
echo "| -Read Alignment, Analysis, and Differential Pipeline- V $VERSION   |"
echo "|____________________________________________________________________|"
    echo "Usage: "
    echo ""
    echo "./rapidStats.sh -o=/path_to_output_directory/ -f=reads.bam -ft=BAM --remove=no --annot=file.bed --index=/path_to_index"
    echo "Parameters:"
    echo "-h|--help"
    echo "-o|--out=/path_to_output_directory/ : path to the output directory, directory will be created if non-existent"
    echo "-f|--file=filename : the input file"
	echo "-ft|--filetype = BAM/SAM/fq : Mention either BAM/SAM or FASTQ. Default FASTQ"
    echo "-a|--annot=file.bed : bed file with regions that should be annotated with read alignments (Multiple Bed files should be separated by commas)"
    echo "-r|--rapid=PATH/ : set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable"
    echo "-i|--index=PATH/ : set location of the bowtie2 index for alignment" 
    echo "--contamin=yes : use a double alignment step first aligning to a contamination file (default no)"
    echo "--indexco=PATH/ set location of the contamination bowtie2 index for alignment (only with contamin=yes)" 
    echo "--remove=yes : remove unecessary intermediate files (default yes)"
}
 
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -ft | --filetype)
            FILETYPE=$VALUE
            ;;
        -f | --file)
            FILE=$VALUE
            ;;
        -o | --out)
            OUT=$VALUE
            ;;
        --rapid | -r)
            BIN=$VALUE
            ;;
        -a | --annot)
            ANNOT=$VALUE
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
if [ -z "$ANNOT" ]
    then
        echo "ERROR no annotation file defined "
        usage
        exit 1
fi 


#Main routines#

#create project 
mkdir -p $OUT/
new=${OUT}/aligned

if [ $FILETYPE == "BAM" ]
then
	BASEFILE=$(basename $FILE)
	FILENAME=`echo ${BASEFILE}|cut -d. -f1`
	samtools sort -T ${new} -O sam -o ${new}.sam ${FILE}
	samtools flagstat ${new}.sam >${new}.flagstat
	awk 'BEGIN{total=0}{if($0~"secondary"){total=total-$1}; if($0~"mapped"){total=total+$1};}END{print total}' ${new}.flagstat >${OUT}/TotalReads.dat
	awk '{if( $1 !~ "4" && NF > 5){print $0}}' ${new}.sam | cut -f 10 |  uniq| awk '{if($0 !~ "^0"){print length($0)}}' | sort | uniq -c > ${new}_lengths.dat
	samtools sort -T ${new} -o ${new}_sorted.bam ${FILE}
	samtools index ${new}_sorted.bam
elif [ $FILETYPE == "SAM" ]
then
	BASEFILE=$(basename $FILE)
	FILENAME=`echo ${BASEFILE}|cut -d. -f1`
	samtools sort -T ${new} -O sam -o ${new}.sam ${FILE}
	samtools flagstat ${new}.sam >${new}.flagstat
	awk 'BEGIN{total=0}{if($0~"secondary"){total=total-$1}; if($0~"mapped"){total=total+$1};}END{print total}' ${new}.flagstat >${OUT}/TotalReads.dat
	awk '{if( $1 !~ "4" && NF > 5){print $0}}' ${new}.sam | cut -f 10 |  uniq| awk '{if($0 !~ "^0"){print length($0)}}' | sort | uniq -c > ${new}_lengths.dat
	#create bam
	samtools view -S -b ${new}.sam >  ${new}.bam
	#sort and 
	samtools sort -T ${new} -o ${new}_sorted.bam ${new}.bam
	#index
	samtools index ${new}_sorted.bam
	rm ${new}.bam
else
	if [ $CONTAMIN == "yes" ]
	then
		echo run two-step alignment by aligning first to contamination index  ${INDEXCONT}
		bowtie2 -p 20  -k 2 -x ${INDEXCONT}  -U ${FILE}  --un ${new}_unmappedReads.fastq -S ${new}_contamination.sam 2> ${new}_bowtie.LOG  
		#reset FILE name to unmapped reads
		FILE=${new}_unmappedReads.fastq
		echo run alignment with index ${INDEX}
		bowtie2 -p 20 --local -k 100 -x ${INDEX} -U ${FILE}  -S ${new}.sam  2> ${new}_bowtie_final.LOG 
	else
		echo run alignment with index ${INDEX}
		bowtie2 -p 20 --local -k 100 -x ${INDEX} -U ${FILE}  -S ${new}.sam  2> ${new}_bowtie_final.LOG 
	fi

	#format for R
	#count number of mapping reads
	awk 'BEGIN{sum=0}{if($0 ~ "1 time"){sum=sum+$1;}}END{print sum}' ${new}_bowtie_final.LOG > ${OUT}/TotalReads.dat

	#compute statisticis for aligned reads of different lengths:
	awk '{if( $1 !~ "4" && NF > 5){print $0}}' ${new}.sam | cut -f 10 |  uniq| awk '{if($0 !~ "^0"){print length($0)}}' | sort | uniq -c > ${new}_lengths.dat

	#create bam
	samtools view -S -b ${new}.sam >  ${new}.bam
	#sort and 
	samtools sort -T ${new} -o ${new}_sorted.bam ${new}.bam
	#index
	samtools index ${new}_sorted.bam
	rm ${new}.bam
fi

######Postprocess data######

#create summary gff file from SAM alignment files
if [  ! -z "$BIN" -a "$BIN" != " "  ];	then
	perl ${BIN}rapid_ParseSam.pl ${new}.sam  > ${OUT}/alignedReads.gff
else
	rapid_ParseSam.pl ${new}.sam  > ${OUT}/alignedReads.gff
fi

IFS=',' read -ra ANNFILES <<< "$ANNOT"
for ANNFILE in "${ANNFILES[@]}"; do
BASEFILE=$(basename $ANNFILE)
ANNFILENAME=`echo ${BASEFILE}|cut -d. -f1`
mkdir -p ${OUT}/${ANNFILENAME}
cp ${OUT}/TotalReads.dat ${OUT}/${ANNFILENAME}/TotalReads.dat

echo compute overlap with regions in bed file ${ANNFILE}
intersectBed -a ${OUT}/alignedReads.gff -b ${ANNFILE} -f 1 > ${OUT}/${ANNFILENAME}/alignedReads.intersect -wao

#produce reduced output after using Bedtools
awk '{if($9 ~ /M*S/){add="Y"}else{add="N"};print $13,$6,add,$7,$8}' ${OUT}/${ANNFILENAME}/alignedReads.intersect | awk '{if($1 !~ /^\./){print $0}}' > ${OUT}/${ANNFILENAME}/alignedReads.sub.compact

#generate Statistics for 
if [  ! -z "$BIN" -a "$BIN" != " "  ];	then
	Rscript ${BIN}/rapidStats.r ${OUT}/${ANNFILENAME}/ ${ANNFILE} >${OUT}/${ANNFILENAME}/R_Errors.log 2>&1 
else
	rapidStats.r ${OUT}/${ANNFILENAME}/ ${ANNFILE} >${OUT}/${ANNFILENAME}/R_Errors.log 2>&1 
fi

#To generate coverage plot information
#awk 'OFS="\t" {print $0,"+"}' ${ANNFILE} >${OUT}/${ANNFILENAME}/${ANNFILENAME}_coverage.bed
bedtools coverage -abam ${new}_sorted.bam -b ${ANNFILE} -d -s >${OUT}/${ANNFILENAME}/poscov.tsv
bedtools coverage -abam ${new}_sorted.bam -b ${ANNFILE} -d -S >${OUT}/${ANNFILENAME}/negcov.tsv

echo "Options Used:" >${OUT}/${ANNFILENAME}/Analysis.log
echo "Output Directory: ${OUT}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Input File: ${FILE}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Contamination Used?: ${CONTAMIN}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Contamination Index: ${INDEXCONT}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Template Index: ${INDEX}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Create BAM?: ${BAM}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Remove intermediates?: ${REMOVE}" >>${OUT}/${ANNFILENAME}/Analysis.log
echo "Annotation File Used: ${ANNFILE} and its contents are below." >>${OUT}/${ANNFILENAME}/Analysis.log
cat $ANNFILE >>${OUT}/${ANNFILENAME}/Analysis.log

done;

#remove intermediate files
if [ $REMOVE == "yes" ]
    then
	echo removing intermediate files
	for ANNFILE in "${ANNFILES[@]}"; do
		BASEFILE=$(basename $ANNFILE)
		ANNFILENAME=`echo ${BASEFILE}|cut -d. -f1`
		rm ${OUT}/${ANNFILENAME}/alignedReads.intersect
	done;
	rm ${OUT}/alignedReads.gff 
	rm ${OUT}/aligned.sam 
	
fi
