******************** demultiplexor.pl ver 4.0 **************************
**************** Illumina fastq file demultiplexer ************************
    Copyright (C) 2015  I. Lagkouvards (ilias.lagkouvardos\@tum.de)
This programs does the demultiplexing of samples that were combined
in the same run. 
Usage:
demultiplexor.pl [--out PATH] [--map FILENAME] [--paired] [--2index]
                    [--I1 FILE] [--I2 FILE] [--R1 FILE]
                    [--R2 FILE] [--accept INDIGER] [--help]
 
Details:
--out       - The path were the demultiplexed files would be stored.
            If directory dont exist would be created (needed).
			
--map       - The tab delimitted file containing the samples and their
            barcodes. If double indexed then sample and two columns of
            barcodes is expected. (needed)
			
--paired    - A flag used to inform the program that paired end files
            were used. The reverse reads are then expected.
			
--2index    - A flag used to inform the program that 2 indexes were used
            in the run. The forward indexes are then expected.
			
--I1        - The illumina fastq reverse index file containing the barcodes
            for each read. (needed)
			
--I2        - The illumina fastq forward index file containing the barcodes
            for each read. (needed if --2index is used)
			
--R1        - The illumina fastq forward read file containing the actual
            sequences. (needed)
			
--R2        - The illumina fastq reverse read file containing the actual
            sequences. (needed if --paired is used)
			
--accept    - The number of mismatches of the index barcode to the original
            ones. it must be a positive integer. (needed)
			
--help      - When used this usage output would be reported. All other commands
            are ignored. (optional)
            
