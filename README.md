![RAPID Logo][logo]


[logo]: figures/Logo.png

Read Alignment and Analysis Pipeline
------------------------------------

RAPID is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data.
It currently features:
- a module for individual dataset analysis and investigation using automated plots in R (rapid_main)
- a comparative module (rapid_compare) that can take as input several datasets processed with rapid_main. It normalizes read counts and produces a battery of comparative visualizations of the different datasets provided.


## Installation
In addition to downloading the RAPID source you need to have installed the following programs in your path:
* Bedtools2
* Bowtie2 (version 2.1.0 or higher)
* R version 3.2 or higher
* Samtools (version 0.1.19 or higher)
* R Packages required:
** DESeq2, gplots and RColorBrewer (if you are using rapidDiff)
** ggplot2, scales, pandoc

Extract the RAPID/bin/ files in your preferred location. Ensure to give execute permissions to all files in RAPID/bin/ and then add the installed location to PATH variable.

## rapidStats
Basic statistics calculation like analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions are done using this script.

### Usage

`./rapidStats.sh -o=/path_to_output_directory/ -f=reads.bam -ft=BAM --remove=no --annot=file.bed --index=/path_to_index`


short | long params | explanation
-----------|------------|--------
-h | --help | show the help on screen
-o | --out  | path to the output directory, directory will be created if non-existent
-f | --file | path to the read fastq/BAM/SAM file
-ft | --filetype | BAM/SAM/fq : Mention either BAM/SAM or FASTQ. Default FASTQ
-a | --annot |  bed file with regions that should be annotated with read alignments (Multiple Bed files should be separated by commas)
-r | --rapid | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) if not in PATH
-i | --index | set location of the bowtie2 index for alignment
 | --contamin=yes | use a double alignment step first aligning to a contamination file (default no)
 | --indexco | set location of the contamination bowtie2 index for alignment (only with contamin=yes)
 | --remove=yes | remove unecessary intermediate files (default yes)

## rapidNorm
rapidNorm gets a config file as input that tells the software which folders have been created with rapidStats, these will be used to create the analysis.

### Usage
`./rapidNorm.sh --out=complete/path/outputDirectory --conf=data.config --annot=regions.bed --rapid=Path/To/Rapid `

short | long params | explanation
-----------|------------|--------
-h | --help | output help
-o | --out | path to the output directory, directory will be created if non-existent
-c | --conf | the config file that defines which rapidStats analysis folders should be used
-a | --annot | bed file with regions that should be used for the comparison, this must be a subset of the regions that was used for rapidStats calls
-r | --rapid | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable
-d | --deseq | LOGICAL value. Use only TRUE or FALSE. Set this to TRUE, if you wish to use DESeq2 based normalization. Default is FALSE, which does a total count based scaling.
-l | --restrictlength | An INTEGER of Read Lengths to be considered. If not provided, all reads will be used. (Multiple read lengths should be separated by commas)"

#### Config file format
location   |     name |   background
----------|----------|-------------
Control1 | Ctrl1  | none
Control2 | Ctrl2  | none
Condition1 | Cond1   | *geneA,geneB*
Condition2 | Cond2   | none

*geneA,geneB* - Gene names provided as background should be same as provided earlier in Annotation file.

The config file is a simple **tab-delimited** flat file that has 3 columns,  the path to the folder produced by rapidStats, the name of the experiment, and whether or not the file should substract regions for normalization (see section Normalization). Each line is one dataset that should be included in the Normalization. Later these normalized statistics can be used to make comparison plots using **rapidVis**.
For this example 4 datasets were run with **rapidStats** which created the folders Control1/2 and Condition1/2 (1st column), note that the string given in that column corresponds to the full path to the folders or the relative path from the folder where rapidNorm.sh is run. 
The 2nd column lists the name under which the experiment is represented in the Normalization analysis. 
Lastly the *background* column is important for normalization if gene/siRNA knockdown was done, default value if that is not the case is **none**. In case that region should be substracted before normalization they have to be given as a comma separated list and correspond to regions given in the Annotation bed file (parameter --annot).

## rapidVis
rapidVis is a R-script used to generate visualisations of the statistics calculated using rapidStats and rapidNorm.

### Usage
`R3script rapidVis.r *plotMethod* *out* *annot* *rapidPath*`

arguments | explanation
-------|-------------
plotMethod | stats OR compare - use **stats** to visualize results of rapidStats or use **compare** to visualize results of rapidNorm
out | outputFolder_of_rapidStats.sh or rapidNorm.sh (Where Statistics and other files are located)
annot | Annotation file similar to BED file given in rapidStats/rapidNorm
rapidPath | **Must** provide the location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/)


## rapidDiff
rapidDiff implements DESeq2 software and generate basic graphs to highlight the differentially expressed gene/region.

### Usage

`./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config`

short | long params | explanation
-----------|------------|--------
-h | --help | output help
-o | --out | path to the output directory, directory will be created if non-existent
-c | --conf | the config file that defines which rapidStats analysis folders should be used for extracting the raw counts of gene/regions analyzed
-a | --alpha | qValue (adjusted p-value) cut-off to highlight in MA-Plot. Default is 0.05 
-n | --nVal | Top 'n' values to be shown as heatmap. The top 'n' values are chosen in ascending order of qValue
-r | --rapid | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable

#### Config file format
sampleName   |     location |   condition
----------|----------|-------------
Control1 | Ctrl1  | untreated
Condition1 | Cond1   | treated

This config file is a simple **tab-delimited** file that has 3 columns, with the **same** headers as mentioned in the above format. 
First field **sampleName** tells the name to be used in the analysis output.
Second field **location** tells the location of rapidStats analysis folders should be used for extracting the raw counts of gene/regions analyzed (USE ONLY ABSOLUTE PATH)
Third field **condition** tells whether the sample is *untreated* or *treated* sample. For example, Use *treated*  drug treated cancerous samples and *untreated* for cancer samples.

## Output file formats
One of the strengths of RAPID is that a number of useful file with statistics and plots are automaically created which can be used for additional analysis.

### rapidStats
For each folder respective for each annotation file supplied in --annot parameter is created by rapidStats analysis contains the following files:
* Statistics.dat - A tab-separated file that contains a number of statistics for each region including read counts, number of read modifications and coverage on DNA strands
* TotalReads.dat : Lists the total number of reads mapped to the genome (given by parameter -i and excluding reads that may have mapped to the contamination file)
* Other associated files used for calculation and reporting. 
** alignedReads.sub.compact has the compact information of aligned reads. If intermediate files are not removed, aligned BAM files will be present.

### rapidNorm
In each folder created by rapidNorm analysis exist the following files:
* NormalizedValues.dat - A tab-separated file that contains the actual and normalized values for each region/sample provided in the config file.
* Other associated files used for calculation and reporting.

### rapidVis
RapidVis output description when ran in two different modes. 

#### rapidStats
* *FolderName*.html - An automatically generated main HTML file which is an ensemble of individual gene/region's HTML files that contain different plots analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions.

#### rapidNorm
* *FolderName*.html - An automatically generated HTML file consisting of various plots like read lengths, antisense ratio, etc. in different scales, compared across all the samples.

### rapidDiff
In each folder created by rapidDiff analysis exist the following files:
*DiffExp_Statistics.csv - A CSV file containing the normal counts retrieved for each sample and the DESeq2 statistics obtained
*DiffExp_Plots.pdf - A PDF file containing MA-Plot, Heatmap of top 'n' q-values, PCA plot of the samples analysed

## Example
After installation you can try running RAPID using the provided script runTest.sh in the testData folder. 
Ensure you have initialized a shell variable named *rapid* if rapid installation bin folder (e.g. /home/software/RAPID/bin/) is not in the PATH variable

Simply run

`bash runTest.sh`

and there should be the folder TestRapid created by rapidStats.sh and TestCompare from rapidNorm.sh in the testData folder. 
You should also find the outputs described under the **rapidVis** section.


