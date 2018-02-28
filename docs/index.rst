==================
General Description
===================

Understanding the role of small RNA (sRNA) in diverse biological processes requires detailed attention to strand specificity, length distribution, and base modification. No integrated computational solution exists to investigate novel sRNA data in an unbiased way. We developed a generic sRNA analysis tool which captures information inherent in the dataset and automatically produces numerous visualizations, as user-friendly HTML reports, covering multiple categories required for sRNA analysis. Our tool also facilitates an automated comparison of multiple datasets, with different normalization techniques. For ease of use, our tool also integrates an automated differential expression analysis using DESeq2.


Features of RAPID
-----------------------------------------------

Read Alignment, Analysis and Differential Pipeline (RAPID) is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data. RAPID currently consists of four modules, whose functionalities are described below.

* **rapidStats**: Prime module which performs alignment, calculates the basic statistics and writes them to a file
* **rapidNorm**: Normalizes the statistics of given samples and writes the normalized values to a file, enabling us to compare genes/samples
* **rapidVis**: Generates insightful graphs of the basic statistics and comparison
* **rapidDiff**: Differential analysis of the given samples using DESeq2

=============
Installation
=============

RAPID does not require any compilation. You need to download (or clone) the git repository `RAPID <https://github.com/SchulzLab/RAPID>`_. 
Extract the RAPID/bin/ files in your preferred location. Ensure to give execute permissions to all files in RAPID/bin/ and then add the installed location to PATH variable.

RAPID makes use of the following tools, and requires them to be in your PATH.

* Bedtools2
* Bowtie2 (version 2.1.0 or higher)
* R version 3.2 or higher
* Samtools (version 0.1.19 or higher)
* R Packages required:
** DESeq2, gplots and RColorBrewer (if you are using rapidDiff)
** ggplot2, scales, pandoc, knitr

============
Usage
============

**rapidStats**
-----------------------------------------------
Basic statistics calculation like analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions are done using this script.

*Input*
* Trimmed sequence file (FASTQ) or an alignment file (BAM/SAM) 
* BED file containing the localization and names of genes/regions to be quantified

We generate the alignments with bowtie2, if FASTQ files are provided as input. A two step alignment can also be performed, if necessary. 
First, to remove the sequences aligning to contaminants, and then aligning the rest of the sequences against the reference genome. 
To facilitate these alignments, bowtie2 index files should be provided against the respective input parameters along with the FASTQ file. 
We then subject the aligned files to quantify the read counts for the regions provided in the BED file. 
This quantification step provides an output file containing the read counts of various read lengths, modification, strandedness, etc.

Sample script: ::
./rapidStats.sh -o=/path_to_output_directory/ -f=reads.bam -ft=BAM --remove=no --annot=file.bed --index=/path_to_index


=====================
Parameter definition
=====================

**Write bold text.**

Secondary headline
-----------------------------------------------
Explain here the usage, text from the RAPID readme can be pasted here


**1.** Below is how to highlight code 
::
  cd EpigenomicsTutorial-ISMB2017/session1
  ls -lh step1/input
  

