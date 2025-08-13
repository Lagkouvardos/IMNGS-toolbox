#!/usr/bin/perl -w

# Copyright (C) 2017  I. Lagkouvardos (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


use strict;
use warnings;

my $path = ".";
my $target_dir = "toTrim";
my $output_dir = "Trimmed";

my $forward_trim=0; # <---- The length from the strat to be trimmed
my $reverse_trim=70; # <---- The length from the end to be trimmed



################################################################### 

my $pathin  ="$path/$target_dir";
my $pathout ="$path/$output_dir";
mkdir "$pathout";

my @dirlist=dir_list($pathin);

print "\nTrimming of fastq files in directory: $pathin\n";
my ($sec,$min,$hour)=gmtime;
print "Operation started at: $hour :$min :$sec\n";

my $count=0;
foreach my $filename (@dirlist)
{
    if ($filename=~/\.fastq$/)
    {
        open (my $inseq_fh,"<","$pathin/$filename") || die "Could not open file $filename to read. $!";
        open (my $out_fh,">","$pathout/$filename") || die "Could not open file $filename to write. $!";
        print "Trimming of file $filename ...";
        while (eof($inseq_fh) ne 1)
        {
            my @entry = getfastq($inseq_fh);
            my $length = length $entry[1];
			
			$entry[1] = substr $entry[1], $forward_trim, $length -$forward_trim -$reverse_trim;
			$entry[3] = substr $entry[3], $forward_trim, $length -$forward_trim -$reverse_trim;
			printfastq($out_fh,@entry);

        }
        print "done.\n";
    }
}
($sec,$min,$hour)=gmtime;
print "\nOperation completed succesfully at: $hour :$min :$sec\n";
print "Trimmed files were saved at:$pathout\n";
print "Press Enter to close the programm.";
<STDIN>;


###################  subroutines  #################

#list the content of a directory
sub dir_list
{
  my ($dir_name)=@_;
  opendir(my $dh, $dir_name) || die "cannot open directory \"$dir_name\": $!";
  my @dir_listing = readdir $dh;
  close $dh;
  return (@dir_listing);
}

#get an entry from a fastq file
sub getfastq
{
  my($filehandler)= @_;
  my @entry=();
  for (my $x=0;$x<4;$x++)
  {
    my $line = <$filehandler>;
    if ($line eq "")
    {
        print "ATTENTION!!! Empty line in file.\n";
		
    }
	else
	{
		$line=~ s/\s+\z//;
		push (@entry,$line);
	}
    
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
