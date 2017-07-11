#!/usr/bin/perl -w

# Copyright (C) 2015  I. Lagkouvards (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# The script need total rewrite for the unified cases

use strict;
use warnings;
use Getopt::Long;

# forward declarations
sub parse_command_line;
sub load_map_file;
sub demultiplex;

#typical usage 
#system "$perl_path/demultiplexor.pl --out $pathout --paired --2index --map $mapfilename --I1 $reverseIndexFilename  --I2 $forwardIndexFilename --R1 $forwardReadFilename --R2 $reverseReadFilename --accept $allow_error";

################################################################################
##############################  VARIABLES  #####################################
################################################################################

my $barcode_mapfile;

my $index_I1_filename;
my $index_I2_filename;

my $read_R1_filename;
my $read_R2_filename;

my $error_tolerance;

my $ispair;
my $has2Index;

my $outputpath;

my %barcodes_hash=();

my %barcodes_assignments=();

my %studies_hash=();

my %studiesFH=();

#small fix for line ending issue
#$variable =~ s/\s+\z//;

################################################################################
###########################   MAIN PROGRAM  ####################################
################################################################################

parse_command_line();

my ($sec,$min,$hour)=gmtime;
print "Operation started at: $hour :$min :$sec\n";

load_map_file($barcode_mapfile);

print "Demultiplexing studies\n";
demultiplex ();

print "Summarizing output\n";
output_stats();

($sec,$min,$hour)=gmtime;
print "Operation completed succesfully at: $hour :$min :$sec .\n";
print "Thank you for your patience.\n";

################################################################################
############################## SUBROUTINES #####################################
################################################################################

#subroutine for parsing the command line
sub parse_command_line
{
    my $help;

    usage() if (scalar @ARGV==0);

    my $result = GetOptions (   "map=s"		=> \$barcode_mapfile, # string
								"I1=s"		=> \$index_I1_filename, # string
								"I2=s"		=> \$index_I2_filename, # string
								"R1=s"		=> \$read_R1_filename, # string
								"R2=s"		=> \$read_R2_filename, # string
								"accept=i"	=> \$error_tolerance, # integer
								"paired"	=> \$ispair, #flag
								"2index"	=> \$has2Index, #flag
								"out=s"		=> \$outputpath, #string	
                                "help"		=> \$help #flag
                            );
    
    usage() if ($help);
    
    die "Error: Barcodes map file not specified (use '--map [FILENAME]')\n" unless defined $barcode_mapfile;
    
    die "Error: Forward fastq filename not specified (use '--R1 [FILENAME]')\n" unless defined $read_R1_filename;
    die "Error: Reverse index filename not specified (use '--I1 [FILENAME]')\n" unless defined $index_I1_filename;
	
    if ($ispair)
    {
		die "Error: Reverse fastq filename not specified (use '--R2 [FILENAME]')\n" unless defined $read_R2_filename;
		if ($has2Index)
		{
			die "Error: Forward index filename not specified (use '--I2 [FILENAME]')\n" unless defined $index_I2_filename;		     
		}
		else
		{
			die "Error: Use of second index filename without declaring the run as double indexed (use '--2index')\n" unless (!defined $index_I2_filename);
		}	
    }
    else
    {
		die "Error: Use of a second read filename without declaring the run as paired (use '--paired')\n" unless (!defined $read_R2_filename);
    }
    
    $outputpath="." unless defined $outputpath;
    unless(-d $outputpath)
    {
		mkdir $outputpath or die "Couldnt create the path $outputpath\n";
    }
	
    die "Error: no number of accepted barcode missmatches is specified (use '--accept [number]')\n" unless defined $error_tolerance;
	
    exit unless $result;    
}

# Read the barcode map file
sub load_map_file ()
{
    my $filename = shift or die "Missing map file name. Usage load_map_file([filename])";

	open (my $mapfile_fh ,"<", $filename) or die "Error: failed to open map file ($filename):$!\n";
	while (my $string = <$mapfile_fh>)
	{
		if ($string=~/\A#/ || $string=~/^\s*$/)
		{	        
			next;
		}
		$string =~ s/\s+\z//;
		if ($has2Index)
		{
			my ($id,$barcodeF,$barcodeR)=split (/\t/,$string);
			my $full_barcode="$barcodeF"."-$barcodeR";
			$barcodes_hash{$full_barcode}=$id;
			$barcodes_assignments{$full_barcode}=0;
			
			my $new_f_filename = "$outputpath/$id\@F.fastq";
			my $new_r_filename = "$outputpath/$id\@R.fastq";
	
				
			open my $R1_fh, ">$new_f_filename" or die "Error: failed to create output file ($new_f_filename)\n";
			open my $R2_fh, ">$new_r_filename" or die "Error: failed to create output file ($new_r_filename)\n";
			
			@{$studiesFH{$id}}=($R1_fh,$R2_fh);
		}
		elsif ($ispair)
		{
	

            my ($id,$barcodeR)=split (/\t/,$string);
  
			my $full_barcode="$barcodeR"."-";
			$barcodes_hash{$full_barcode}=$id;
			$barcodes_assignments{$full_barcode}=0;
			
			my $new_f_filename = "$outputpath/$id\@F.fastq";
			my $new_r_filename = "$outputpath/$id\@R.fastq";
	
				
			open my $R1_fh, ">$new_f_filename" or die "Error: failed to create output file ($new_f_filename)\n";
			open my $R2_fh, ">$new_r_filename" or die "Error: failed to create output file ($new_r_filename)\n";
			
			@{$studiesFH{$id}}=($R1_fh,$R2_fh);
	
		}
		else
		{
			my ($id,$barcodeR)=split (/\t/,$string);
			my $full_barcode="$barcodeR"."-";
			$barcodes_hash{$full_barcode}=$id;
			$barcodes_assignments{$full_barcode}=0;
	
			my $new_f_filename = "$outputpath/$id\@F.fastq";
	
				
			open my $R1_fh, ">$new_f_filename" or die "Error: failed to create output file ($new_f_filename)\n";
			
			@{$studiesFH{$id}}=($R1_fh);
				
		}
		
	}
    close $mapfile_fh;    
}


# Read the barcode index and reads files and extract those that match the barcodes 
sub demultiplex
{
    my $R1_fh;
    my $R2_fh;

    my $I1_fh;
    my $I2_fh;
	
    #open the run index I1 file to read
    open($I1_fh, '<', $index_I1_filename) or die "Error: failed to open indexes file $index_I1_filename to read:$!\n";
    
    #open the run R1 file to read
    open ($R1_fh, '<', $read_R1_filename) or die "Error: failed to open reads file ($read_R1_filename):$!\n";
    
    if ($ispair)
    {
		#open the run R2 file to read
		open ($R2_fh,"<",$read_R2_filename) or die "Error: failed to open reads file ($read_R2_filename):$!\n";
		if ($has2Index)
		{
		    #open the run I2 file to read
		    open ($I2_fh ,"<", $index_I2_filename) or die "Error: failed to open indexes file ($index_I2_filename):$!\n";
		}
    }

    #go through all entries in the I1 file and check the match to barcodes
    do
    {
		my $I1_barcode;
		my $I2_barcode="";
		my $full_index;
		
		my @R1_entry;
		my @R2_entry;
		my @I1_entry;
		my @I2_entry;
			
		@I1_entry=getfastq($I1_fh);
		$I1_barcode=$I1_entry[1];
			
		@R1_entry=getfastq($R1_fh);
			
		if ($ispair)
		{
			@R2_entry=getfastq($R2_fh);
					
			if ($has2Index)
			{
			@I2_entry=getfastq($I2_fh);
			$I2_barcode=$I2_entry[1];  
			}
		}
		$full_index="$I1_barcode"."-$I2_barcode";
			
			
		if (exists $barcodes_hash{$full_index})
		{
			my $study = $barcodes_hash{$full_index};
	
				
			if ($has2Index)
			{
				printfastq($studiesFH{$study}[0],@R1_entry);
				printfastq($studiesFH{$study}[1],@R2_entry);
			}
			elsif ($ispair)
			{
				printfastq($studiesFH{$study}[0],@R1_entry);
				printfastq($studiesFH{$study}[1],@R2_entry);		
			}
			else
			{
				printfastq($studiesFH{$study}[0],@R1_entry);
			}

			$barcodes_assignments{$full_index}++;

		}
		else
		{
			my $mismatch_1=0;
			my $mismatch_2=0;
			my $max_mismatch=0;

			my $study;
			my $exact_barcode;
			my $min_dif = 100;			
			
		    foreach my $barcode (keys %barcodes_hash)
		    {
				my ($exact1,$exact2)=split (/-/,$barcode);
				
				$mismatch_1= mismatch_count($I1_barcode,$exact1);
				if ($exact2 ne "")
				{
					$mismatch_2= mismatch_count($I2_barcode,$exact2);
				}
				
				$max_mismatch=pair_max($mismatch_1,$mismatch_2);
				
				if ($max_mismatch<=$min_dif)
				{
					$study = $barcodes_hash{$barcode};
					$exact_barcode = $barcode;
					$min_dif = $max_mismatch;
				}		
		    }

			if ($min_dif>$error_tolerance)
			{
				$study = "Unassigned";
				$exact_barcode = "NNNNNNNN-";
			}	
			else
			{
				if ($has2Index)
				{
					printfastq($studiesFH{$study}[0],@R1_entry);
					printfastq($studiesFH{$study}[1],@R2_entry);
				}
				elsif ($ispair)
				{
					printfastq($studiesFH{$study}[0],@R1_entry);
					printfastq($studiesFH{$study}[1],@R2_entry);		
				}
				else
				{
					printfastq($studiesFH{$study}[0],@R1_entry);
				}
			}
			
			if (exists $barcodes_assignments{$exact_barcode})
			{
				$barcodes_assignments{$exact_barcode}++;
			}
			else
			{
				$barcodes_assignments{$exact_barcode}=1;
			}			
		}
    }
    until eof($I1_fh); 
}


# write the demultiplexing stats of the run in a new file 
sub output_stats
{
	# define the output stat file
	my $output_stats_filename = "$outputpath/Studies_stats.tab";
	
	#Open file with the illumina barcodes
	open (my $output_stats_fh,">",$output_stats_filename) || die "Cannot open \"$output_stats_filename\" to read from: $!";
	
	# write the header of the columns
	print $output_stats_fh ("Sample\tBarcode\tReads\n");
	
	foreach my $barcode (keys %barcodes_hash)
	{
		print $output_stats_fh ("$barcodes_hash{$barcode}\t$barcode\t$barcodes_assignments{$barcode}\n");
	}
}

# Quickly calculate hamming distance between two strings
#
# NOTE:	Strings must be same length.
#     	returns number of different characters.
#	see  http://www.perlmonks.org/?node_id=500235
sub mismatch_count($$)
{
    length($_[0])-(($_[0]^$_[1]) =~ tr[\0][\0]);
}

# find the max between two numbers
sub pair_max
{
    $_[$_[0] < $_[1]];
}

#find the min between two numbers
sub pair_min
{
    $_[$_[0] > $_[1]];
}


#get the path one level below the path string entered.
sub getpath
{
    my ($fullpath)=@_;
    my $proximal_path = "";
    my $terminal_path = "";
    if ($fullpath=~ /(.*)\/([^\/]*?)\z/)
    {
	$proximal_path = $1;
	$terminal_path = $2;
    }
    else
    {
	$proximal_path=".";
	$terminal_path = $fullpath;
    }
    return ($proximal_path,$terminal_path);
}

#get an entry from a fastq file
sub getfastq
{
  my($filehandler)= @_;
  my @entry=();
  for (my $x=0;$x<4;$x++)
  {
    my $line = <$filehandler>;
    $line=~ s/\s+\z//;
    if ($line eq "")
    {
        print "ALAAARMMM";
    }
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

#subroutine for printing the correct usage of the script
sub usage()
{
print<<EOF;

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

EOF

exit 1;
}

