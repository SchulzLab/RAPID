![RAPID Logo][logo]


[logo]: figures/Logo.png

Read Alignment and Analysis Pipeline
------------------------------------

RAPID is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data.
It currently features:
- a module for individual dataset analysis and investigation using automated plots in R (rapid_main)
- a comparative module (rapid_compare) that can take as input several datasets processed with rapid_main. It normalizes read counts and produces a battery of comparative visualizations of the different datasets provided.


##rapid_main

###Usage

./rapid_main.sh -o=complete/path/outputDirectory -file=reads.fastq 

Parameters | explanation
-----------|------------
--help | show the help on screen
-o=PATH/ | path to the output directory, directory will be created if non-existent
--file=PATH/ | path to the read fastq file (currently only fastq format)
--annot=file.bed |  bed file with regions that should be annotated with read alignments
--rapid=PATH/ | set location of the rapid installation bin folder (e.g. /home/software/RAPID/bin/) or put into PATH variable
--bam=yes | create sorted and indexed bam file (default no, needs samtools on path)
--index=PATH/ | set location of the bowtie2 index for alignment
--contamin=yes | use a double alignment step first aligning to a contamination file (default no)
--indexcont=PATH/ | set location of the contamination bowtie2 index for alignment (only with contamin=yes)
--remove=yes | remove unecessary intermediate files (default yes)

