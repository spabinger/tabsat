# NEW VERSION OF TABSAT
Please check out our [new version of TABSAT](https://tabsat.ait.ac.at).<br/>
-> [https://tabsat.ait.ac.at](http://tabsat.ait.ac.at)
<br/><br/>
<br/><br/>

# TABSAT

TABSAT - Targeted Amplicon Bisulfite Sequencing Analysis Tool - is a tool for analyzing targeted bisulfite sequencing data generated on an Ion Torrent PGM / Illumina MiSeq. 
It performs
* Quality Assessment
* Alignment using [Bismark](http://www.bioinformatics.babraham.ac.uk/projects/bismark/)
* Result aggregation into a table
* Visualization as lollipop plots

Available as
* Fully configured Docker image [Dockerfile](Dockerfile) - see usage information below.
* Source code

## Collaboration
Please contact us if you need help running your analyses. Also we have developed an **extended version** for our collaborators with the following additional features:
* Interactive web-based visualization
* Download FASTA of target regions
* Strand specific CpGs
* Automatic mapping of primers
* Restriction enzyme positions
* Start using web frontend
* Pattern visualization and analysis


## Publication
TABSAT is published:<br/>
http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0160227


## Example usage
```sh
${TABSAT} -l NONDIR -g hg19 -q 20 -m 10 -p 0.8 -r 0 -t target.csv -a tmap -o output_dir input.fastq
```
**-t** Targetlist in CSV format [example](https://github.com/tadKeys/tabsat/blob/master/tools/zz_test/target_list_tmap.csv) [mandatory] - Strand can be "+", "-", "+/-"<br />
**-e** Sequencing library - SE/PE (PE reads must be called \*_1.fastq, \*_2.fastq)<br />
**-g** Genome (hg19, mm10)<br />
**-l** Library mode of bisulfite experiment<br />
**-a** *[optional]* Specify the aligner that should be used<br />
**-m** *[optional]* This parameter is used for filtering reads that are shorter than the given threshold.<br />
**-q** *[optional]* Bases that are below the given threshold are removed from the 3’ end of the reads (read trimming)<br />
**-p** *[optional]* Percent of target covered by a read for pattern creation. This value specifies the percent of the target that needs to be covered by a read to include it for pattern analysis.<br />
**-r**: *[optional]* Minimum number of mapped reads that need to be present at each CpG site.	<br />
**-s**: *[optional]* Sorted list of samples that is used to specify the order in the lollipop plots.<br />
**-o** Output directory<br />
**-d** Directory of inputfiles (absolute path); if not specified, the input files are added at the end [optional]<br />

#### Examples
Test with input file directory
```sh
tabsat -l NONDIR -g hg19 -t target.csv -d test_input_dir -a tmap -o test_output_dir
```
Test with separate input files
```sh
tabsat -l NONDIR -g hg19 -t target.csv -o test_output_files xy.fastq abs.fastq
```

## Test data
Test data is available [here](test_data)



## Installation
* Check out the project (git clone)
* Download the reference genome
 * Human
   * UCSC: http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.2bit <br/>
     Download the twoBitToFa from here: http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/
   * NCBI: ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/human_g1k_v37.fasta.gz
 * Mouse
    * USCS: http://hgdownload.cse.ucsc.edu/goldenPath/mm10/bigZips/mm10.2bit
* If a 2bit file was downloaded, please extract the file using ```twoBitToFa``` (see http://hgdownload.cse.ucsc.edu/goldenPath/mm10/bigZips/ and http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/)
* Please make sure that the reference genome uses a <b>"chr" prefix</b>
* Put the reference genome file into the correct folder
  * Human<br/>
  tabsat/reference/human/hg19/hg19.fasta
  * Mouse<br/>
  tabsat/reference/mouse/mm10/mm10.fasta
* Prepare the reference genome
```sh
$ tabsat/reference/prepareReference.sh
```
* Prepare the CpG file
```sh
apt-get install p7zip-full
7za e tabsat/tools/ait/all_cpgs_only_pos_hg19.7z
7za e tabsat/tools/ait/all_cpgs_only_pos_mm10.7z
```
* Install Perl modules
  * Cairo.pm
  * Switch.pm
* Run 'install' script in tabsat folder (installs SAMtools, Bedtools)
```./install```
## Run example

#### Command line
* After installation go to *tabsat/tools/zz_test*
* Execute
```sh
./test_tabsat_tmap.sh
```
* Inspect output at *tabsat/tabsat_test_output*


#### Docker
* Build the docker file<br/>
```docker build -t tabsat:v1 . ```

* Run it<br/> 
```docker run -t --name tabsat -d tabsat:v1 ```

* Connect to docker<br/>
```docker exec -ti tabsat /bin/bash ```

* Stop container<br/>
```docker stop tabsat```

* Remove container<br/>
```docker rm tabsat```

* Remove image<br/>
```docker rmi tabsat:v1```




