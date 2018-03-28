
Installation
============

Manual
------

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

Simple Test
-----------
After installation you can try running RAPID using the provided script runTest.sh in the testData folder. Ensure to set the *rapid* path variable in the script.
Now, simply run ::

    bash runTest.sh

Upon succesful completion, there should be two folders TestRapid created by **rapidStats**, and TestCompare from **rapidNorm** in the testData folder. 
You should also find the outputs described under the **rapidVis** section.

Conda
-----

RAPID is available as a recipe in the bioconda channel. If bioconda is not in your channel list, you can add it ::

    conda config --add channels bioconda
    conda config --add channels conda-forge

We recommend to use RAPID as a conda environment using the following command: ::

    conda create --name <name> rapid=0.2=pl5.22.0_3

This command creates an environment for RAPID v0.2, build pl5.22.0_3. We advise to use conda environment based approach, as this would not disturb your exisiting installations, and use only the compatible versions of dependencies. 

If you wish to test the installation, download the testData folder from the git repository `RAPID <https://github.com/SchulzLab/RAPID>`_. 

Move to the test data folder. Edit the *rapid* path variable in the runTest.sh script. With a conda environment it should look soemthing like ::

    rapid=/home/<username>/miniconda2/envs/<environment_name>/bin/

First activate the desired conda environment ::

    source activate <environment_name>
    
Now, simply run ::

    bash runTest.sh
    
Upon succesful completion, there should be two folders TestRapid created by **rapidStats**, and TestCompare from **rapidNorm** in the testData folder. 
You should also find the outputs described under the **rapidVis** section.

To move out of the environment, type ::

    source deactivate <environment_name>
