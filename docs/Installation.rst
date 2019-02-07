Installation
============

We strongly recommend using the latest version of our tool, using a conda environment, as this sorts out all the dependency issues. 

Conda
-----

RAPID is available as a recipe in the bioconda channel. If bioconda is not in your channel list (You can see it, with the command "conda info"), you can add it ::

    conda config --add channels bioconda
    conda config --add channels conda-forge

You can search for rapid using the following command: ::

    conda search rapid

An example command to use RAPID as a conda environment : ::

    conda create --name <environment_name> rapid=<version>

This command creates an environment for RAPID. We advise to use conda environment based approach, as this would not disturb your existing installations, and use only the compatible versions of dependencies. 


If you wish to test the installation, download the testData folder from the git repository `RAPID <https://github.com/SchulzLab/RAPID>`_. 
Please refer to **TroubleShooting_FAQs** section, if you encounter issues.


First activate the desired conda environment ::

    source activate <environment_name>
    
Now, simply run ::

    bash runTest.sh
    
Upon successful completion, there should be two folders TestRapid created by **rapidStats**, and TestCompare from **rapidNorm** in the testData folder. 
You should see outputs as shown in the SampleOutput folder. The output descriptions can be found in the **Visualization** section.

If you encounter any issues, which is not addressed in the **TroubleShooting_FAQs** section, please report to us.
 
To move out of the environment, type ::

    source deactivate <environment_name>

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
* pandoc
* R Packages required:
   * DESeq2, gplots and RColorBrewer (if you are using rapidDiff)
   * ggplot2, scales, rmarkdown, knitr, viridis

Simple Test
-----------
After installation you can try running RAPID using the provided script runTest.sh (You will have to uncomment respective lines) in the testData folder. Ensure to add the rapid in the PATH variable or provide the scripts with an environment variable for rapid.
Now, simply run ::

    bash runTest.sh

Upon successful completion, there should be two folders TestRapid created by **rapidStats**, and TestCompare from **rapidNorm** in the testData folder. 
You should see outputs as shown in the SampleOutput folder. The output descriptions can be found in the **Visualization** section.