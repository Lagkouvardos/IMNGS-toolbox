# Writen by I. Lagkouvards (ilias.lagkouvardos@tum.de)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

import common

# declare variables
I1_filename= "I1.fastq"
R1_filename= "R1.fastq"

mappings_filename= "mapping_file.tab"
barcodes_filename = "barcodes.txt"
pairs_filename = "multiplexing_table.tab"

files_folder= "samples-sequences"

# read barcodes from file
barcodes = common.read_barcodes(barcodes_filename)

# open the files that we will write the merged output
I1_fh = common.open_file_else_exit(I1_filename, 'w')
R1_fh = common.open_file_else_exit(R1_filename, 'w')

# read pairs
pairs_fh = common.open_file_else_exit(pairs_filename, 'r')
pair_lines = pairs_fh.readlines()

# Open the file to write the mappings
mappings_fh = common.open_file_else_exit(mappings_filename, 'w')
mappings_fh.write("#SampleID\tIndex\n")

pair_counter = 0

for pair_line in pair_lines:

  pair_line = pair_line.rstrip('\n')
  if pair_line.startswith('#'):
    continue
 
  splits = pair_line.split('\t')
  if len(splits) < 2:
    continue

  sample_name = splits[0]
  forward_filename = splits[1]

  forward_full_path_name = './{}/{}'.format(files_folder, forward_filename)
  forward_fh = common.open_file_else_exit(forward_full_path_name, 'r')

  line_counter = 0
  forward_entry = []

  for forward_line in forward_fh:
    
    forward_line = forward_line.rstrip('\n')
    
    line_counter = line_counter + 1
    
    forward_entry.append(forward_line)

    if line_counter == 4:
      
      index_entry = []
      index_entry.append(forward_entry[0])
      index_entry.append(barcodes[pair_counter])
      index_entry.append("+")
      index_entry.append("EEEEEEEEEEEE")

      common.write_fastq_entry_to_file(I1_fh, index_entry)
      common.write_fastq_entry_to_file(R1_fh, forward_entry)

      line_counter = 0
      forward_entry = []

  forward_fh.close()
  
  mappings_fh.write('{}\t{}\n'.format(sample_name, barcodes[pair_counter]))
  pair_counter = pair_counter + 1