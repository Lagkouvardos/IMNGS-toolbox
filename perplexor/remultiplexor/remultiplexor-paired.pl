#!/usr/bin/perl -w

# Writen by I. Lagkouvards (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

use strict;
use warnings;


#Declare variables
my $barcodesfilename = "barcodes.txt";
my $demultiplexed_pairs = "multiplexing_table.tab";
my $I1_filename= "I1.fastq";
my $R1_filename= "R1.fastq";
my $R2_filename= "R2.fastq";
my $mappingfile= "mapping_file.tab";
my $files_folder= "samples-sequences";

#Open file with the illumina barcodes
open (my $barcodes_fh,"<",$barcodesfilename) || die "Cannot open \"$barcodesfilename\" to read from: $!";

#parse barcodes to barcodes array
my @barcodes;
while(my $barcode_line = <$barcodes_fh>)
{
   chomp $barcode_line;
   push (@barcodes,$barcode_line);
}

#open the files that we will write the merged output
open(my $I1_fh,">", $I1_filename) || die "Cannot open \"$I1_filename\" to write to: $!";
open(my $R1_fh,">", $R1_filename) || die "Cannot open \"$R1_filename\" to write to: $!";
open(my $R2_fh,">", $R2_filename) || die "Cannot open \"$R2_filename\" to write to: $!";

# expected format for the pairs filename
# samplename\tforward_read_filename\treverse_read_filename\n
# sample1  sample1_R1.fastq  sample1_R2.fastq
open (my $pairs_fh,"<",$demultiplexed_pairs) || die "Cannot open \"$demultiplexed_pairs\" to read from: $!";
# Open the file to write the mappings
open (my $mappings_fh,">",$mappingfile) || die "Cannot open \"$mappingfile\" to write to: $!";
print $mappings_fh "#SampleID\tIndex\n";

my $pairnumber=0;
while (my $pair_line= <$pairs_fh>)
{
  chomp $pair_line;
  if ($pair_line=~/^#/) { next;}  
  my ($sample_name,$forward_filename,$reverse_filename) = split (/\t/,$pair_line);
  open (my $forward_fh,"<","./$files_folder/$forward_filename") || die "Cannot open \"$forward_filename\" to read from: $!";
  open (my $reverse_fh,"<","./$files_folder/$reverse_filename") || die "Cannot open \"$reverse_filename\" to read from: $!";
  do
  {
    #read the paired reads from the two read files of one sample
    my @f_read_entry=getfastq($forward_fh);
    my @r_read_entry=getfastq($reverse_fh);

    #create a pseudo index entry for each sequence pair using the same barcode for the whole sample
    my @index_entry=();
    push (@index_entry,"$f_read_entry[0]");
    push (@index_entry,"$barcodes[$pairnumber]");
    push (@index_entry,"+");
    push (@index_entry,"EEEEEEEEEEEE");
    
    printfastq($I1_fh,@index_entry);    
    printfastq($R1_fh,@f_read_entry);
	printfastq($R2_fh,@r_read_entry);
  }
  until eof($forward_fh);
  close ($forward_fh);
  close ($reverse_fh);
  
  print $mappings_fh "$sample_name\t$barcodes[$pairnumber]\n";
  $pairnumber++;    
}

################## SUBS ######################
#get an entry from a fastq file
sub getfastq
{
  my($filehandler)= @_;
  my @entry=();
  for (my $x=0;$x<4;$x++)
  {
    my $line = <$filehandler>;
    chomp $line;
    push (@entry,$line);
  }
  return (@entry);
}

#print a fastq entry
sub printfastq
{
  my($filehandler,@fastq_entry)= @_;
  foreach my $line (@fastq_entry)
  {
    print $filehandler "$line\n";
  }  
}




