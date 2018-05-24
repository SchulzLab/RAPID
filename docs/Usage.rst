Basic Usage
===========


rapidStats
--------------

Basic statistics calculation like analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions are done using this script.

*Input*
^^^^^^^

* Trimmed sequence file (FASTQ) or an alignment file (BAM/SAM) 
* BED file containing the localization and names of genes/regions to be quantified

We generate the alignments with bowtie2, if FASTQ files are provided as input. A two step alignment can also be performed, if necessary. i.e. First, to remove the sequences aligning to contaminants, and then aligning the rest of the sequences against the reference genome. 
To facilitate these alignments, bowtie2 index files should be provided against the respective input parameters along with the FASTQ file. 
We then subject the aligned files to quantify the read counts for the regions provided in the BED file. 
This quantification step provides an output file containing the read counts of various read lengths, modification, strandedness, etc.

*Sample script*
^^^^^^^^^^^^^^^

If using a previously aligned BAM file: ::

    ./rapidStats.sh -o=/path_to_output_directory/ -f=reads.bam -ft=BAM --remove=no -a=file.bed -r=/rapidPath/

If using a fastq file, and wish to quantify multiple BED files. 
Results will be stored in separate folders with each annotation file's name: ::

    ./rapidStats.sh -o=/path_to_output_directory/ -f=reads.fq -a=file.bed,file2.bed -i=/path_to_index -r=/rapidPath/
    
If using a fastq file, and wish to perform a two-step alignment: ::

    ./rapidStats.sh -o=/path_to_output_directory/ -f=reads.fq -a=file.bed -i=/path_to_index --contamin=yes --indexco=/path_to_contaminants_index -r=/rapidPath/

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+------------+--------+-------+-----------+------------+--------------------------+
| chromosome |  start |  end  | geneName  | type       | strand (Gene Direction)  |
+============+========+=======+===========+============+==========================+
| chr1       |  1234  | 1368  | geneA     | region     | \+                       |
+------------+--------+-------+-----------+------------+--------------------------+
| chr2       | 1234   | 1368  | geneB     | region     | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+
| chr2       | 1432   | 1568  | geneB     | region     | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+
| chr3       | 1234   | 1368  | geneC     | background | \-                       |
+------------+--------+-------+-----------+------------+--------------------------+

The column *type* in the Bed file says whether a gene has to be treated as background (knockdown) or not during normalizations. 

rapidNorm
----------

Normalization module aims to facilitate the comparison of genes across various samples, and vice versa. As sequencing depth differs across samples, the read counts have to be normalized. RAPID facilitates two kinds of normalization. (i) DESeq2 based, and (ii) a variant of Total Count Scaling (TCS) method to account for the knockdown associated smallRNAs inherent in sequencing. For a detailed description of the normalization strategy, please have a look at the bioarXiv.

By default, RAPID uses the modified TCS based normalization method. However, in order to provide flexibility with the choice of normalization, we have also incorporated the DESeq2 based normalization. If an user can safely assume that most of the genes between samples are not differentially expressed, in a small RNA based study, then they can use the DESeq2 based normalization. 

*Input*
^^^^^^^

* BED file containing the localization and names of genes/regions to be compared. Care should be taken to include only the gene/regions which were quantified in **rapidStats**
* Config file containing the location of **rapidStats** output folders


Sample script: 
^^^^^^^^^^^^^^

If normalizing using the TCS based normalization: ::
    
    ./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/
    
If normalizing using the DESeq2 based normalization: ::
    
    ./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/ -d=T
    
If normalizing using the TCS based scaling, while considering only reads of length 23bp, and 25bp: ::
    
    ./rapidNorm.sh --out=/path_to_output_directory/ --conf=data.config --annot=regions.bed --rapid=/rapidPath/ -l=23,25


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

The config file is a simple **tab-delimited** file that has three columns, the path to the folder produced by **rapidStats**, the name of the experiment, and list of regions need to be corrected in TCS based normalization. Each line is one dataset that should be included in the Normalization. Later these normalized statistics can be used to make comparison plots using **rapidVis**. 


*Config file format* 
^^^^^^^^^^^^^^^^^^^^

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



rapidVis
----------

The visualization module of RAPID is a simple R script, which creates informative plots from the output of **rapidStats**, and **rapidNorm**. 

*Input*
^^^^^^^

* Path of the output folder from **rapidStats**, and **rapidNorm**
* BED file containing the localization and names of genes/regions need to be visualized. Care should be taken to include only the gene/regions which were quantified in **rapidStats**

Sample script:
^^^^^^^^^^^^^^
Generic Format: ::

    `Rscript rapidVis.r <plotMethod> <outputfolder> <annotationfile> <rapidPath>`

If you want to plot rapidStats output: ::

    Rscript ${rapidPath}/rapidVis.r stats /path_to_output_directory_rapidStats/ regions.bed <$rapid>
    
If you want to plot rapidNorm output: ::

    Rscript ${rapidPath}/rapidVis.r compare /path_to_output_directory_rapidNorm/ <$rapid>


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



rapidDiff
----------

This module of RAPID implements DESeq2 software and generate basic graphs to highlight the differentially expressed gene/region among the samples.

*Input*
^^^^^^^

* Path of the output folder from **rapidStats**
* Config file describing the DESeq2 analysis setup

Sample script:
^^^^^^^^^^^^^^

Generic Format: ::

    ./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config
    
If a different q-value cut-off is required: ::

    ./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config --alpha=0.01

If only reads of length 23bp, and 25bp should be considered: ::
    ./rapidDiff.sh --out=complete/path/outputDirectory/ --conf=data.config --alpha=0.01 -l=23,25
    
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| short | long params      | explanation                                                                                                                          |
+=======+==================+======================================================================================================================================+
| -h    | --help           | output help                                                                                                                          |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -o    | --out            | path to the output directory, directory will be created if non-existent                                                              |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -c    | --conf           | the config file that defines which rapidStats analysis folders should be used for extracting the raw counts of gene/regions analyzed |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -a    | --alpha          | qValue (adjusted p-value) cut-off to highlight in MA-Plot. Default is 0.05                                                           |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -n    | --nVal           | Top 'n' values to be shown as heatmap. The top 'n' values are chosen in ascending order of qValue                                    |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -r    | --rapid          | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable                         |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+
| -l    | --restrictlength | An INTEGER of Read Lengths to be considered (Default: All). Separate multiple values by commas.                                      |
+-------+------------------+--------------------------------------------------------------------------------------------------------------------------------------+

*Config file format*
^^^^^^^^^^^^^^^^^^^^

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
