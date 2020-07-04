# Writen by I. Lagkouvards (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# import libraries
import re
import os
import sys

def open_file_else_exit(filename:str, mode:str):
  try:
    full_path_name = os.path.join(sys.path[0], filename)
    file_handle = open (full_path_name, mode)
    return file_handle
  except Exception as error:
    print("Cannot open file:[" + filename + "].Mode:[" + mode + "]")
    print(error)
    exit()

def read_barcodes(barcodesfilename):
  barcodes_fh = open_file_else_exit(barcodesfilename, 'r')
  barcode_lines = barcodes_fh.readlines()

  barcodes = []
  for barcode_line in barcode_lines:
    barcode_line = re.sub(r"\s+\Z", "", barcode_line)
    barcodes.append(barcode_line)
  
  return barcodes

def write_fastq_entry_to_file(file_handle, entry:list):
  for line in entry:
    file_handle.write('{}\n'.format(line))

# declare variables
I1_filename= "I1.fastq"
R1_filename= "R1.fastq"
R2_filename= "R2.fastq"

pairs_filename = "multiplexing_table.tab"
barcodes_filename = "barcodes.txt"
mappings_filename= "mapping_file.tab"

files_folder= "samples-sequences"

# read barcodes from file
barcodes = read_barcodes(barcodes_filename)

# read pairs from file
pairs_fh = open_file_else_exit(pairs_filename, 'r')
pair_lines = pairs_fh.readlines()

# Open file to write  mappings
mappings_fh = open_file_else_exit(mappings_filename, 'w')
mappings_fh.write("#SampleID\tIndex\n")

# create new Index, R1, R2 files 
I1_fh = open_file_else_exit(I1_filename, 'w')
R1_fh = open_file_else_exit(R1_filename, 'w')
R2_fh = open_file_else_exit(R2_filename, 'w')

pair_counter = 0
for pair_line in pair_lines:

  splits = pair_line.split("\t")

  sample_name = re.sub(r"\s+\Z", "", splits[0])
  forward_filename = re.sub(r"\s+\Z", "", splits[1])
  reverse_filename = re.sub(r"\s+\Z", "", splits[2])

  if sample_name.startswith('#'):
    continue

  forward_full_path_name = './{}/{}'.format(files_folder, forward_filename)
  reverse_full_path_name = './{}/{}'.format(files_folder, reverse_filename)

  forward_fh = open_file_else_exit(forward_full_path_name, 'r')
  reverse_fh = open_file_else_exit(reverse_full_path_name, 'r')

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
        
      write_fastq_entry_to_file(I1_fh, index_entry)
      write_fastq_entry_to_file(R1_fh, forward_entry)
      write_fastq_entry_to_file(R2_fh, reverse_entry)
      
      forward_entry = []
      reverse_entry = []
      line_counter = 0

  mappings_fh.write('{}\t{}\n'.format(sample_name, barcodes[pair_counter]))
  
  forward_fh.close()
  reverse_fh.close()

  pair_counter = pair_counter + 1
  