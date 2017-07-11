REM Demultiplexing Samples from a study
REM Please select the apropriate values for the variables MAP, I1, I2, R1 and R2.
REM If your study was sequenced using one barcode then delete the line SET I2 = ""
REM Also remove the command that doesnot corespond to the settings.

SET OUT=./Samples
SET MAP="mapping.txt"
SET I1="I1.fastq"
SET I2="I2.fastq"
SET R1="R1.fastq"
SET R2="R2.fastq"

REM Use this for single barcode runs (Delete the other command)
demultiplexor_v4.pl --out %OUT% --paired --map %MAP% --I1 %I1%  --R1 %R1% --R2 %R2% --accept 2

REM Use this for double barcoded runs (Delete the other command)
demultiplexor_v4.pl --out %OUT% --paired --2index --map %MAP% --I1 %I1%  --I2 %I2% --R1 %R1% --R2 %R2% --accept 2
