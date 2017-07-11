#!/bin/bash          
echo Demultiplexing samples from a study
OUT=./Samples
MAP="DH.txt"
I1="DH-I1.fastq"
I2="DH-I2.fastq"
R1="DH-R1.fastq"
R2="DH-R2.fastq"
 
demultiplexor.pl --out $OUT --paired --2index --map $MAP --I1 $I1  --I2 $I2 --R1 $R1 --R2 $R2 --accept 1

