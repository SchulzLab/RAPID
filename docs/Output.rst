Output Description
==================
One of the strengths of RAPID is that a number of useful file with statistics and plots are automaically created which can be used for additional analysis.


Statistics
----------

For each folder respective for each annotation file supplied in --annot parameter is created by rapidStats analysis contains the following files:

* Statistics.dat - A tab-separated file that contains a number of statistics for each region including read counts, number of read modifications and coverage on DNA strands
* TotalReads.dat : Lists the total number of reads mapped to the genome (given by parameter -i and excluding reads that may have mapped to the contamination file)
* Other associated files used for calculation and reporting. 
  * alignedReads.sub.compact has the compact information of aligned reads. If intermediate files are not removed, aligned BAM files will be present.



Normalization
-------------

In each folder created by rapidNorm analysis exist the following files:

* NormalizedValues.dat - A tab-separated file that contains the actual and normalized values for each region/sample provided in the config file.
* Other associated files used for calculation and reporting.



Visualization
-------------

RapidVis output description when ran in two different modes. 

* rapidStats

   *FolderName*.html - An automatically generated main HTML file which is an ensemble of individual gene/region's HTML files that contain different plots analyzing read counts, distribution of reads on the two DNA strands and listing smallRNA modifications stratified by the defined regions.

* rapidNorm

   *FolderName*.html - An automatically generated HTML file consisting of various plots like read lengths, antisense ratio, etc. in different scales, compared across all the samples.


Differential Analysis
---------------------

In each folder created by rapidDiff analysis exist the following files:
  * DiffExp_Statistics.csv - A CSV file containing the normal counts retrieved for each sample and the DESeq2 statistics obtained
  * DiffExp_Plots.pdf - A PDF file containing MA-Plot, Heatmap of top 'n' q-values, PCA plot of the samples analysed
