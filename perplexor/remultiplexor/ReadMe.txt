Remultiplexor is a Perl script for merging various already demultiplexed samples in one study for processing through the IMNGS analysis pipeline.
Although samples prepared with the same protocol but from different runs can be merged to a study we recommend to do it with caution.
This is due to biases related to each run that then act as confounding factors in the subsequent analysis.

Users of this script should first make sure that Perl is installed in their computers and that they follow the described instructions:  

- Place all the sequence files (*.fastq) from the samples you want to merge in a study in the folder "samples-sequences"
- Make sure that the files are decompressed. If your files extension is .tar.gz or .gz or .zip you need to decompress them first so they end up in .fastq.
- Open the multiplexing_table.tab file with Excel and modify the content accordingly
- Clear the table from any previous multiplexed entries (Leave header line)
- If you are multiplexing paired end Illumina sequences then for each sample write a name for the sample, the filename of R1 output and the filename of the R2 output.
- If you are multiplexing single end Illumina sequences then for each sample write a name for the sample and the filename of R1 output.
- Make sure that you DO NOT use spaces and special characters for the names of samples
- Make sure that the file names match the corresponding sample and are in the correct order
- Save the file in a tab delimited format
- Execute the appropriate script	
   
The output of the script are two or three files depending on the usage of single or paired end sequencing respectively.
In more details you will get:

The I1.fastq that contains indexes that were given to your samples from a pool of standard barcodes
The R1.fastq that contains all the concatenated R1 files
The R2.fastq that contains all the concatenated R2 files (if paired data are used)
And the mapping_file.tab that track the index used for each sample so that it can then demultiplexed by IMNGS again.

These are all you need to run your custom study through IMNGS. 
If you have a slow connection, we recommend to independently compress each sequence file first and then upload it to IMNGS.
