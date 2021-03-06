# Writen by I. Lagkouvards (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# import libraries
import re
import os
import sys
import common

# declare variables
I1_filename= "I1.fastq"
R1_filename= "R1.fastq"
R2_filename= "R2.fastq"

pairs_filename = "multiplexing_table.tab"
barcodes_filename = "barcodes.txt"
mappings_filename= "mapping_file.tab"

files_folder= "samples-sequences"

# read barcodes from file
barcodes = common.read_barcodes(barcodes_filename)

# read pairs from file
pairs_fh = common.open_file_else_exit(pairs_filename, 'r')
pair_lines = pairs_fh.readlines()

# Open file to write  mappings
mappings_fh = common.open_file_else_exit(mappings_filename, 'w')
mappings_fh.write("#SampleID\tIndex\n")

# create new Index, R1, R2 files 
I1_fh = common.open_file_else_exit(I1_filename, 'w')
R1_fh = common.open_file_else_exit(R1_filename, 'w')
R2_fh = common.open_file_else_exit(R2_filename, 'w')

pair_counter = 0
for pair_line in pair_lines:

  pair_line = pair_line.rstrip('\n')
  if pair_line.startswith('#'):
    continue
  
  if not pair_line:
    continue
  
  splits = pair_line.split("\t")
  if len(splits) < 3:
    continue

  sample_name = splits[0]
  forward_filename = splits[1]
  reverse_filename = splits[2]

  forward_full_path_name = './{}/{}'.format(files_folder, forward_filename)
  reverse_full_path_name = './{}/{}'.format(files_folder, reverse_filename)

  forward_fh = common.open_file_else_exit(forward_full_path_name, 'r')
  reverse_fh = common.open_file_else_exit(reverse_full_path_name, 'r')

  forward_entry = []
  reverse_entry = []
  line_counter = 0

  for forward_line in forward_fh:

    forward_line = forward_line.rstrip('\n')
    reverse_line = reverse_fh.readline().rstrip('\n')

    line_counter = line_counter + 1
      
    forward_entry.append(forward_line)
    reverse_entry.append(reverse_line)

    if line_counter == 4:
      index_entry = []
      index_entry.append(forward_entry[0])
      index_entry.append(barcodes[pair_counter])
      index_entry.append("+")
      index_entry.append("EEEEEEEEEEEE")
        
      common.write_fastq_entry_to_file(I1_fh, index_entry)
      common.write_fastq_entry_to_file(R1_fh, forward_entry)
      common.write_fastq_entry_to_file(R2_fh, reverse_entry)
      
      forward_entry = []
      reverse_entry = []
      line_counter = 0

  mappings_fh.write('{}\t{}\n'.format(sample_name, barcodes[pair_counter]))
  
  forward_fh.close()
  reverse_fh.close()

  pair_counter = pair_counter + 1
  