![RAPID Logo][logo]

[logo]: figures/Logo.png

## Statistical Report
This section describe the plots in the statistical report produced from *rapidVis*.

#### Read alignment percentage of various read lengths
This plot shows various read lengths utilized in the analysis and their percentage of alignment.

#### Alignment percentage of reads with (Un)Modified bases
This plot shows the alignment percentage of reads containing (un)modified bases.

#### Strand specific alignment percentage of reads
The alignment percentage of reads corresponding to each strand is shown in this plot.

#### Reads aligned with base modifications above 'n' reads
This plot shows the modified bases and the number of reads containing such modifications. We only show bases which have at least 'n' reads. Here, 'n' corresponds to 5% of the overall alignment.

#### Alignment percentage of reads with base modifications above 'n' reads
This plot shows the modified bases and the percentage of reads containing such modifications. We only show bases which have at least 'n' reads. Here, 'n' corresponds to 5% of the overall alignment.

#### Strand specific reads of varied length
This plot shows various read lengths utilized in the analysis and their read counts, specific to each strand.

#### Modification status specific reads of varied length
Various read lengths utilized in the analysis and their read counts, specific to their modification status is shown in this plot.

#### 1-base modification specific reads of varied length
This plot shows various read legnths utilized in the analysis and their read counts, with respected to the modified bases. Only the single bases (A,T,G and C) modified were considered.

#### Strand specific reads with respect to base modification status
This plot shows the strand specific read counts with their base modification status.

## Comparison Report
This section describe the plots in the comparison report produced from *rapidVis*. The normalized values mentioned below corresponds to the normalization method you choose, while running *rapidNorm*

#### Clustered heatmap of TPM
This is a heatmap of the TPM of gene/region corresponding to the samples analyzed. The dendograms shown are calculated using the default clustering parameters of heatmap.2 function, which uses a complete linkage method with an euclidean measure.

#### Clustered heatmap of antisense ratio
This is a heatmap of the antisense ratio of gene/region corresponding to the samples analyzed. The dendograms shown are calculated using the default clustering parameters of heatmap.2 function, which uses a complete linkage method with an euclidean measure.

#### Clustered heatmap of average read count (log2 scale)
This is a heatmap of the average read count (log2) of gene/region corresponding to the samples analyzed. The dendograms shown are calculated using the default clustering parameters of heatmap.2 function, which uses a complete linkage method with an euclidean measure.

#### PCA plot of samples
This principle component analysis (PCA) plot shows where your samples fall in the first and second principle components. The principle componenets are calculated using the read counts of each sample. 

#### MDS plot of samples
This multi dimensional scaling (MDS) plot shows the proximities of your samples in two dimension. Read counts of each sample is used for performing MDS.

#### Box plot of read counts
This is a box plot of the normalized read counts of each gene/region.

#### Sample wise comparison of read counts for each gene/region
This plot shows the normalized read counts of each sample for each gene/region.

#### Sample wise comparison of read counts for each gene/region (log2 scale)
Log2 of normalized read counts of each sample for each gene/region is shown in this plot.

#### Sample wise comparison of TPM for each gene/region
This plot shows the TPM values of each sample for each gene/region. TPM values are calculated from the read counts, after accounting for read length restrictions, if provided by user. 

#### Sample wise comparison of TPM for each gene/region (log2 scale)
Log2 of TPM Values of each sample for each gene/region is shown in this plot. TPM values are calculated from the read counts, after accounting for read length restrictions, if provided by user.

#### Sample wise comparison of antisense ratio for each gene/region
This plot shows the antisense ratio of each sample is shown for each gene/region.

#### Gene/Region wise comparsion of average read counts for each sample
This plot shows the gene/region wise average read counts for each sample.

#### Gene/Region wise comparsion of average read counts for each sample (log2 scale)
Log2 of gene/region wise average read counts for each sample is shown in this plot.

#### Gene/Region wise comparsion of TPM for each sample
This plot shows the gene/region wise TPM for each sample. TPM values are calculated from the read counts, after accounting for read length restrictions, if provided by user.

#### Gene/Region wise comparsion of TPM for each sample (log2 scale)
Log2 of gene/region wise TPM for each sample is shown in this plot. TPM values are calculated from the read counts, after accounting for read length restrictions, if provided by user.

#### Gene/Region wise comparison of antisense ratio for each sample
Antisense ratio of gene/region for each samples is shown in this plot.