#!/bin/bash          
echo Hello World
OUT=./Samples
MAP="DH.txt"
I1="DH-I1.fastq"

R1="DH-R1.fastq"
R2="DH-R2.fastq"
 
demultiplexor_v4.pl --out $OUT --paired --map $MAP --I1 $I1  --R1 $R1 --R2 $R2 --accept 1

