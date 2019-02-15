
General Description
===================

Understanding the role of small RNA (sRNA) in diverse biological processes requires detailed attention to strand specificity, length distribution, and nucleotide soft-clipping. No integrated computational solution exists to investigate novel sRNA data in an unbiased way. We developed a generic eukaryotic sRNA analysis tool which captures information inherent in the dataset and automatically produces numerous visualizations, as user-friendly HTML reports, covering multiple categories required for sRNA analysis. Our tool also facilitates an automated comparison of multiple datasets, with different normalization techniques. For ease of use, our tool also integrates an automated differential expression analysis using DESeq2.

While our tool can be used for generic sRNA analysis, they are tailored to address the needs of eukaryotic siRNA analysis. 


Features of RAPID
-----------------

Read Alignment, Analysis and Differential Pipeline (RAPID) is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data. RAPID currently consists of four modules, whose functionalities are described below.

* **rapidStats**: Prime module which performs alignment, calculates the basic statistics and writes them to a file
* **rapidNorm**: Normalizes the statistics of given samples and writes the normalized values to a file, enabling us to compare genes/samples, with one normalization technique (KnockDown Corrected Scaling; KDCS) dedicated for siRNA knockdown analysis.
* **rapidVis**: Generates insightful graphs of the basic statistics and comparison
* **rapidDiff**: Differential analysis of the given samples using DESeq2

