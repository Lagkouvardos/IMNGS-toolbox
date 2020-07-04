import os
import sys
import re

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
    barcode_line = barcode_line.rstrip('\n')

    if barcode_line:
      barcodes.append(barcode_line)
  
  return barcodes

def write_fastq_entry_to_file(file_handle, entry:list):
  for line in entry:
    file_handle.write('{}\n'.format(line))
