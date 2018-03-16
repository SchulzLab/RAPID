********************
General Description
********************

Understanding the role of small RNA (sRNA) in diverse biological processes requires detailed attention to strand specificity, length distribution, and base modification. No integrated computational solution exists to investigate novel sRNA data in an unbiased way. We developed a generic sRNA analysis tool which captures information inherent in the dataset and automatically produces numerous visualizations, as user-friendly HTML reports, covering multiple categories required for sRNA analysis. Our tool also facilitates an automated comparison of multiple datasets, with different normalization techniques. For ease of use, our tool also integrates an automated differential expression analysis using DESeq2.


Features of RAPID
===================

Read Alignment, Analysis and Differential Pipeline (RAPID) is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data. RAPID currently consists of four modules, whose functionalities are described below.

* **rapidStats**: Prime module which performs alignment, calculates the basic statistics and writes them to a file
* **rapidNorm**: Normalizes the statistics of given samples and writes the normalized values to a file, enabling us to compare genes/samples
* **rapidVis**: Generates insightful graphs of the basic statistics and comparison
* **rapidDiff**: Differential analysis of the given samples using DESeq2

********************
Installation
********************

RAPID does not require any compilation. 

* You need to download (or clone) the git repository `RAPID <https://github.com/SchulzLab/RAPID>`_. 
* Extract the RAPID/bin/ files in your preferred location. 
* Ensure to give execute permissions to all files in RAPID/bin/ and then add the installed location to PATH variable.

RAPID makes use of the following tools, and requires them to be in your PATH.

* Bedtools2
* Bowtie2 (version 2.1.0 or higher)
* R version 3.2 or higher
* Samtools (version 0.1.19 or higher)
* R Packages required:
   * DESeq2, gplots and RColorBrewer (if you are using rapidDiff)
   * ggplot2, scales, pandoc, knitr


Conda
=============

RAPID is available as a recipe in the bioconda channel. Conda users can install RAPID, for example, using the following command. ::
    conda install rapid=0.2=pl5.22.0_3

This command installs the RAPID v0.2, build pl5.22.0_3. 

We recommend to use RAPID as a conda environment. An example command is given below. ::
    conda create --name <name> rapid=0.2=pl5.22.0_3

Always remember to set the rapid path variable to the bin directory where RAPID is found. In case of a conda environment it should look soemthing like ::
    rapid=/home/<username>/miniconda2/envs/<environment_name>/bin/

After installation you can try running RAPID using the provided script runTest.sh in the testData folder. 
Ensure you have initialized a shell variable named *rapid* if rapid installation bin folder (e.g. /home/software/RAPID/bin/) is not in the PATH variable


Simple Test
============

Simply run

`bash runTest.sh`

and there should be the folder TestRapid created by **rapidStats** and TestCompare from **rapidNorm** in the testData folder. 
You should also find the outputs described under the **rapidVis** section.

********************
Basic Usage
********************


**rapidStats**
================
Basic statistics calculation like analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions are done using this script.

*Input*
------------------

* Trimmed sequence file (FASTQ) or an alignment file (BAM/SAM) 
* BED file containing the localization and names of genes/regions to be quantified

We generate the alignments with bowtie2, if FASTQ files are provided as input. A two step alignment can also be performed, if necessary. i.e. First, to remove the sequences aligning to contaminants, and then aligning the rest of the sequences against the reference genome. 
To facilitate these alignments, bowtie2 index files should be provided against the respective input parameters along with the FASTQ file. 
We then subject the aligned files to quantify the read counts for the regions provided in the BED file. 
This quantification step provides an output file containing the read counts of various read lengths, modification, strandedness, etc.

*Sample script*: 
------------------

If using a previously aligned BAM file:
    `./rapidStats.sh -o=/path_to_output_directory/ -f=reads.bam -ft=BAM --remove=no --annot=file.bed --rapid=/rapidPath/`

If using a fastq file, and wish to quantify multiple BED files. Results will be stored in separate folders with each annotation file's name:
    `./rapidStats.sh -o=/path_to_output_directory/ -f=reads.fq --annot=file.bed,file2.bed --index=/path_to_index --rapid=/rapidPath/`
    
If using a fastq file, and wish to perform a two-step alignment:
    `./rapidStats.sh -o=/path_to_output_directory/ -f=reads.fq --annot=file.bed --index=/path_to_index --contamin=yes --indexco=/path_to_contaminants_index --rapid=/rapidPath/`

The different parameters we provide currently are listed below.

+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| short | long params     | explanation                                                                                                             |
+=======+=================+=========================================================================================================================+
| -h    | --help          | show the help on screen                                                                                                 |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -o    | --out           | path to the output directory, directory will be created if non-existent                                                 |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -f    | --file          | path to the read fastq/BAM/SAM file                                                                                     |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -ft   | --filetype      | BAM/SAM/fq : Mention either BAM/SAM or FASTQ. Default FASTQ                                                             |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -a    | --annot         | bed file with regions that should be annotated with read alignments (Multiple Bed files should be separated by commas)  |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -r    | --rapid         | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) if not in PATH                       |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
| -i    | --index         | set location of the bowtie2 index for alignment                                                                         |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
|       | --contamin=yes  | use a double alignment step first aligning to a contamination file (default no)                                         |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
|       | --indexco       | set location of the contamination bowtie2 index for alignment (only with contamin=yes)                                  |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+
|       | --remove=yes    | remove unecessary intermediate files (default yes)                                                                      |
+-------+-----------------+-------------------------------------------------------------------------------------------------------------------------+

*Bed file format* (Do not provide a header, its shown here only for clarity)
--------------------------------------------------------------------------------

+------------+--------+-------+-----------+------------+--------------------------+
| chromosome |  start |  end  | geneName  | type       | strand (Gene Direction)  |
+============+========+=======+===========+============+==========================+
| chr1       |  1234  | 1368  | geneA     | region     |  \+                      |
+------------+--------+-------+-----------+------------+--------------------------+
| chr2       | 1234   | 1368  | geneB     | region     | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+
| chr2       | 1432   | 1568  | geneB     | region     | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+
| chr3       | 1234   | 1368  | geneC     | background | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+

The column *type* in the Bed file says whether a gene has to be treated as background (knockdown) or not during normalizations. 

**rapidNorm**
================
Normalization module aims to facilitate the comparison of genes across various samples, and vice versa. As sequencing depth differs across samples, the read counts have to be normalized. RAPID facilitates two kinds of normalization. (i) DESeq2 based, and (ii) a variant of Total Count Scaling (TCS) method to account for the knockdown associated smallRNAs inherent in sequencing. For a detailed description of the normalization strategy, please have a look at the bioarXiv. 

*Input*
------------------

* BED file containing the localization and names of genes/regions to be compared. Care should be taken to include only the gene/regions which were quantified in **rapidStats**
* Config file containing the location of **rapidStats** output folders


Sample script: 
------------------

If normalizing using the TCS based normalization:
    `./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/`
    
If normalizing using the DESeq2 based normalization:
    `./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/ -d=T`
    
If normalizing using the TCS based scaling, while considering only reads of length 23bp, and 25bp:
    `./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/ -l=23,25`


+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| short | long params            | explanation                                                                                                                                                        |
+=======+========================+====================================================================================================================================================================+
| -h    | --help                 | output help                                                                                                                                                        |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -o    | --out                  | path to the output directory, directory will be created if non-existent                                                                                            |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -c    | --conf                 | the config file that defines which rapidStats analysis folders should be used                                                                                      |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -a    | --annot                | bed file with regions that should be used for the comparison, this must be a subset of the regions that was used for rapidStats calls                              |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -r    | --rapid                | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable                                                       |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -d    | --deseq                | LOGICAL value. Use only TRUE or FALSE. Set this to TRUE, if you wish to use DESeq2 based normalization. Default is FALSE, which does a total count based scaling.  |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -l    | --restrictlength       | An INTEGER of Read Lengths to be considered. If not provided, all reads will be used. (Multiple read lengths should be separated by commas)"                       |
+-------+------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+

The config file is a simple **tab-delimited** file that has 3 columns,  the path to the folder produced by **rapidStats**, the name of the experiment, and list of regions need to be corrected in TCS based normalization. Each line is one dataset that should be included in the Normalization. Later these normalized statistics can be used to make comparison plots using **rapidVis**. 


*Config file format* 
----------------------

+--------------+---------+----------------+
| location     |  name   |   background   |
+==============+=========+================+
| /Control1/   | Ctrl1   | none           |
+--------------+---------+----------------+
| /Control2/   | Ctrl2   | none           |
+--------------+---------+----------------+
| /Condition1/ | Cond1   | *geneA,geneB*  |
+--------------+---------+----------------+
| /Condition2/ | Cond2   | none           |
+--------------+---------+----------------+

*geneA,geneB* - Gene names provided as background should be same as provided in the **rapidStats** *bed file*.



**rapidVis**
================
The visualization module of RAPID is a simple R script, which creates informative plots from the output of **rapidStats**, and **rapidNorm**. 

*Input*
------------------

* Path of the output folder from **rapidStats**, and **rapidNorm**
* BED file containing the localization and names of genes/regions need to be visualized. Care should be taken to include only the gene/regions which were quantified in **rapidStats**

Sample script:
------------------

    `Rscript rapidVis.r <plotMethod> <outputfolder> <annotationfile> <rapidPath>`

If you want to plot rapidStats output:
    `Rscript ${rapidPath}/rapidVis.r stats /path_to_output_directory_rapidStats/ regions.bed <$rapid>`
    
If you want to plot rapidNorm output:
    `Rscript ${rapidPath}/rapidVis.r compare /path_to_output_directory_rapidNorm/ <$rapid>`


+---------------+-----------------------------------------------------------------------------------------------------------------------------------+
| arguments     | explanation                                                                                                                       |
+===============+===================================================================================================================================+
| plotMethod    | stats OR compare-use **stats** to visualize **rapidStats** or use **compare** to visualize results of **rapidNorm**               |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------+
| out           | outputFolder_of_rapidStats.sh or rapidNorm.sh (Where Statistics and other files are located)                                      |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------+
| annot         | Annotation file similar to BED file given in **rapidStats**                                                                       |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------+
| rapidPath     | **Must** provide the location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/)                               |
+---------------+-----------------------------------------------------------------------------------------------------------------------------------+



**rapidDiff**
================
This module of RAPID implements DESeq2 software and generate basic graphs to highlight the differentially expressed gene/region among the samples.

*Input*
------------------

* Path of the output folder from **rapidStats**
* Config file describing the DESeq2 analysis setup

Sample script:
------------------
    `./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config`
    
If a different q-value cut-off is required: 
    `./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config --alpha=0.01`
    
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| short | long params | explanation                                                                                                                          |
+=======+=============+======================================================================================================================================+
| -h    | --help      | output help                                                                                                                          |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -o    | --out       | path to the output directory, directory will be created if non-existent                                                              |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -c    | --conf      | the config file that defines which rapidStats analysis folders should be used for extracting the raw counts of gene/regions analyzed |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -a    | --alpha     | qValue (adjusted p-value) cut-off to highlight in MA-Plot. Default is 0.05                                                           |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -n    | --nVal      | Top 'n' values to be shown as heatmap. The top 'n' values are chosen in ascending order of qValue                                    |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -r    | --rapid     | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable                         |
+-------+-------------+--------------------------------------------------------------------------------------------------------------------------------------+

*Config file format*
-----------------------

+------------+------------+-------------+
| sampleName |   location |   condition |
+============+============+=============+
| Control1   |  Ctrl1     | untreated   |
+------------+------------+-------------+
| Condition1 |  Cond1     | treated     |
+------------+------------+-------------+

This config file is a simple **tab-delimited** file that has three columns, with the **same** headers as mentioned in the above format. 

*sampleName* tells the name to be used in the analysis output.
*location* tells the location of rapidStats analysis folders should be used for extracting the raw counts of gene/regions analyzed (**USE ONLY ABSOLUTE PATH**)
*condition* tells whether the sample is *untreated* or *treated* sample. For example, Use *treated*  drug treated cancerous samples and *untreated* for cancer samples.

********************
Output Description
********************
One of the strengths of RAPID is that a number of useful file with statistics and plots are automaically created which can be used for additional analysis.


Statistics
================
For each folder respective for each annotation file supplied in --annot parameter is created by rapidStats analysis contains the following files:

* Statistics.dat - A tab-separated file that contains a number of statistics for each region including read counts, number of read modifications and coverage on DNA strands
* TotalReads.dat : Lists the total number of reads mapped to the genome (given by parameter -i and excluding reads that may have mapped to the contamination file)
* Other associated files used for calculation and reporting. 
  * alignedReads.sub.compact has the compact information of aligned reads. If intermediate files are not removed, aligned BAM files will be present.



Normalization
================
In each folder created by rapidNorm analysis exist the following files:

* NormalizedValues.dat - A tab-separated file that contains the actual and normalized values for each region/sample provided in the config file.
* Other associated files used for calculation and reporting.



visualization
================
RapidVis output description when ran in two different modes. 

* rapidStats

   *FolderName*.html - An automatically generated main HTML file which is an ensemble of individual gene/region's HTML files that contain different plots analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions.

* rapidNorm

   *FolderName*.html - An automatically generated HTML file consisting of various plots like read lengths, antisense ratio, etc. in different scales, compared across all the samples.


Differential Analysis
======================

In each folder created by rapidDiff analysis exist the following files:
  * DiffExp_Statistics.csv - A CSV file containing the normal counts retrieved for each sample and the DESeq2 statistics obtained
  * DiffExp_Plots.pdf - A PDF file containing MA-Plot, Heatmap of top 'n' q-values, PCA plot of the samples analysed
