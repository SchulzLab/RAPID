#!/usr/bin/env bash
 
#
# RAPID
# Read Alignment, Analysis, and Differential Pipeline
# 
 
# Copyright (C) 2019 Marcel H. Schulz  and Sivarajan Karunanithi
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


VERSION="1.0"
OUT=""
BIN=""
ANNOT=""
raploc=`which rapidVis.r`
BIN=$(dirname $raploc)
TYPE=""

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
    echo "./rapidVis.sh -t=stats -o=/path_to_output_directory/ -a=file.bed -r=/path_to_rapid"
    echo "./rapidVis.sh -t=compare -o=/path_to_output_directory/ -r=/path_to_rapid"
    echo "Parameters:"
    echo "-h|--help"
    echo "-t|--type= stats/Compare - Choose basic statistics, or comparison plots"
    echo "-o|--out=/path_to_output_directory/ : path to the output directory, directory will be created if non-existent"
    echo "-a|--annot=file.bed : bed file with regions that should be visualised (Not required for comparison plots)"
    echo "-r|--rapid=PATH/ : set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable"
}
 
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
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
        -t | --type)
            TYPE=$VALUE
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
if [ -z "$BIN" ]
    then
        echo "ERROR: RAPID is not in PATH, or rapid environment variable is not set. At least one should be done. "
        usage
        exit 1
fi 
if [ -z "$TYPE" ]
    then
        echo "ERROR Plot Type not defined, please say whether to use stats (or) compare mode "
        usage
        exit 1
fi 

#Main routines#

 
if [ $TYPE == "stats" ]; then
	Rscript $BIN/rapidVis.r $TYPE $OUT $ANNOT $BIN/
else
	Rscript $BIN/rapidVis.r $TYPE $OUT $BIN/
fi
