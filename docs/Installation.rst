
Installation
============

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
-----

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
-----------

Simply run

`bash runTest.sh`

and there should be the folder TestRapid created by **rapidStats** and TestCompare from **rapidNorm** in the testData folder. 
You should also find the outputs described under the **rapidVis** section.
