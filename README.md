![RAPID Logo][logo]


[logo]: figures/Logo.png

Read Alignment and Analysis Pipeline
------------------------------------

RAPID is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data.
It currently features:
- a module for individual dataset analysis and investigation using automated plots in R (rapid_main)
- a comparative module (rapid_compare) that can take as input several datasets processed with rapid_main. It normalizes read counts and produces a battery of comparative visualizations of the different datasets provided.


##Installation
In addition to download the RAPID source you need to have installed the following programs:
* Bedtools2
* Bowtie2 (version 2.1.0 or higher)
* R version 3.0 or higher with packages ggplot2, scales
* Samtools (only if you want BAM files, version 0.1.19 or higher)

##rapid_main

###Usage

`./rapid_main.sh -o=complete/path/outputDirectory -f=reads.fastq.gz -a=Regions.bed  `

**Necessary parameters are file, annot, out**

short | long params | explanation
-----------|------------|--------
-h | --help | show the help on screen
-o | --out  | path to the output directory, directory will be created if non-existent
-f | --file | path to the read fastq file (currently only fastq format)
-a | --annot |  bed file with regions that should be annotated with read alignments
-r | --rapid | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) if not in PATH
 | --bam=yes | create sorted and indexed bam file (default no, needs samtools on path)
-i | --index | set location of the bowtie2 index for alignment
 | --contamin=yes | use a double alignment step first aligning to a contamination file (default no)
 | --indexco | set location of the contamination bowtie2 index for alignment (only with contamin=yes)
 | --remove=yes | remove unecessary intermediate files (default yes)

##rapid_compare
rapid_compare gets a config file as input that tells the software which folders have been created with rapid_main, these will be used to create the analysis.

####Config file format
location   |     name |   background
----------|----------|-------------
Control1 | Ctrl1  | none
Control2 | Ctrl2  | none
Condition1 | Cond1   | none
Condition2 | Cond2   | none

The config file is a simple **tab-delimited** flat file that has 3 columns,  the path to the folder produced by rapid_main, the name of the experiment, and whether or not the file should substract regions for normalization (see section Normalization). Each line is one dataset that should be included in the comparison.
For this example 4 datasets were run with ** rapid_main ** which created the folders Control1/2 and Condition1/2 (1st column), note that the string given in that column corresponds to the full path to the folders or the relative path from the folder where rapid_compare.sh is run. The 2nd column list the name under which the experiment is represented in the comparative analysis, lastly the *background* column is important for normalization if siRNA knockdown were done, default value if that is not the case is **none**.
 
###Usage
`./rapid_compare.sh --out=complete/path/outputDirectory --conf=data.config --annot=regions.bed --rapid=Path/To/Rapid `

short | long params | explanation
-----------|------------|--------
-h | -- | output help
-o | --out | path to the output directory, directory will be created if non-existent
-c | --conf | the config file that defines which rapid_main analysis folders should be used
-a | --annot | bed file with regions that should be used for the comparison, this must be a subset of the regions that was used for rapid_main calls
-r | --rapid | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable

##Example
After installation you can try running RAPID using the provided script runTest.sh in the testData folder.

Simply run

`bash runTest.sh`

and there should be the folder TestRapid created in the TestData folder.
