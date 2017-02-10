#!/bin/bash
 
#
# RAPID
# Read Alignment and Analysis Pipeline
# 
 
# Copyright (C) 2017 Marcel H. Schulz and Sivarajan Karunanithi
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
CONFIG=""
ANNOT=""
BIN=""
RESTLEN=""
DESEQ="FALSE"

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
    echo "./rapidNorm.sh --out=complete/path/outputDirectory/ --conf=data.config --annot=regions.bed --rapid=Path/To/Rapid "
    echo "Parameters:"
    echo "-h|--help"
    echo "-o|--out=PATH/ : path to the output directory, directory will be created if non-existent"
    echo "-c|--conf=PATH/ : the config file that defines which rapidStats analysis folders should be used"
    echo "-a|--annot=file.bed : bed file with regions that should be used for the comparison"
    echo "-d|--deseq=<LOGICAL> : Use only TRUE or FALSE. Set this to TRUE, if you wish to use DESeq2 based normalization. Default is FALSE." 
    echo "-r|--rapid=PATH/ : set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable"
	echo "-l|--restrictlength=<INTEGER> : Read Lengths to be considered. If not provided, all reads will be used. (Multiple read lengths should be separated by commas)"
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
        -c | --conf)
            CONFIG=$VALUE
            ;;
        -o | --out)
            OUT=$VALUE
            ;;
        -r | --rapid)
            BIN=$VALUE
            ;;
        -a | --annot)
            ANNOT=$VALUE
            ;;
        -d | --deseq)
            DESEQ=$VALUE
            ;;            
	-l | --restrictlength)
	    RESTLEN=$VALUE
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
if [ -z "$ANNOT" ]
    then
        echo "ERROR no annotation file defined "
        usage
        exit 1
fi
if [ -z "$CONFIG" ]
    then
        echo "ERROR no config file defined "
        usage
        exit 1
fi  


#Main routines#

#create new folder for comparative results
mkdir -p $OUT/
echo Run comparative analysis using config file ${CONFIG} 
if [  ! -z "$BIN" -a "$BIN" != " "  ];	then
	R3script ${BIN}rapidNorm.r ${CONFIG} ${ANNOT} ${OUT} ${DESEQ} ${RESTLEN} >${OUT}/R_Errors.log 2>&1
else
	rapidNorm.r ${CONFIG} ${ANNOT} ${OUT} ${DESEQ} ${RESTLEN} >${OUT}/R_Errors.log 2>&1
fi
echo Normalized values are calculated using the config file ${CONFIG} > $OUT/Analysis.Log

