#!/usr/bin/env python3
# coding: utf-8
# Author: Amal Thomas

import gzip
import sys
import os
from collections import defaultdict

def calculate_nucleotide_percentage(seq, nucleotide):
    count = seq.count(nucleotide)
    return (count / len(seq)) * 100

def bin_percentage(percentage, w):
    if percentage == 100:
        return 100 - w
    return int(percentage // w) * w

def process_fastq(f, bin_width):
    bins_T = defaultdict(int)
    bins_A = defaultdict(int)
    read_count = 0
    t_gte_90 = 0
    a_gte_90 = 0

    while True:
        header = f.readline().strip()
        if not header:
            break
        if header[0] != "@":
            print(f"Error\n{file_path}:header line not starting with @")
            print(header, "\n")
            sys.exit(1)
        seq = f.readline().strip().upper()
        #print(seq)
        plus = f.readline().strip()
        qual = f.readline().strip()

        if not seq:
            break

        read_count += 1

        percent_T = calculate_nucleotide_percentage(seq, 'T')
        percent_A = calculate_nucleotide_percentage(seq, 'A')
        #print("% T", percent_T)
        #print("% T", percent_A)

        bin_T = bin_percentage(percent_T, bin_width)
        bin_A = bin_percentage(percent_A, bin_width)
        #print("bin T", bin_T)
        #print("bin A", bin_A)

        bins_T[bin_T] += 1
        bins_A[bin_A] += 1
        if percent_T >= 90:
            t_gte_90 += 1
        if percent_A >= 90:
            a_gte_90 += 1
    
    return bins_T, bins_A, read_count, t_gte_90, a_gte_90

def write_output(sample, bins_T, bins_A, read_count, t_gte_90, a_gte_90, output_file, w):
    with open(output_file, 'w') as f:
        # Write the header
        f.write("sample\ttotal_reads\tNucT_gte_per_90\tNucA_gte_per_90\tNucT_gte_num_90\tNucA_gte_num_90")
        for i in range(0, 100, w):
            bin_key = i
            bin_key_next = i + w
            f.write(f"\tT_{bin_key}-{bin_key_next}_pct\tT_{bin_key}-{bin_key_next}_num")
            f.write(f"\tA_{bin_key}-{bin_key_next}_pct\tA_{bin_key}-{bin_key_next}_num")

        t_gte_per_90 = (t_gte_90 / read_count) * 100 if read_count > 0 else 0
        a_gte_per_90 = (a_gte_90 / read_count) * 100 if read_count > 0 else 0
        f.write(f"\n{sample}\t{read_count}\t{t_gte_per_90:.2f}\t{a_gte_per_90:.2f}\t{t_gte_90}\t{a_gte_90}")
        for i in range(0, 100, w):
            bin_key = i
            bin_key_next = i + w
            percentage_T = (bins_T[bin_key] / read_count) * 100 if read_count > 0 else 0
            percentage_A = (bins_A[bin_key] / read_count) * 100 if read_count > 0 else 0
            f.write(f"\t{percentage_T:.2f}")
            f.write(f"\t{bins_T[bin_key]}")
            f.write(f"\t{percentage_A:.2f}")
            f.write(f"\t{bins_A[bin_key]}") 
        f.write("\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <output name> <sample>")
        sys.exit(1)
    
    bin_size = 5

    sample_name = sys.argv[1]
    input_file = sys.argv[2]
    
    output_file = "stats_A_T_" + sample_name + ".tsv"
    
    if input_file == '-':
        file_handle = sys.stdin
        base_name = 'stdin'
        print("Input provided as STDIN")		
    else:
        print("Input provided as a file")
        if input_file.endswith('.gz'):
            file_handle = gzip.open(input_file, 'rt')
        else:
            file_handle = open(input_file, 'r')

    bins_T, bins_A, read_count, t_gte_90, a_gte_90 = process_fastq(file_handle, bin_size)
    #print(bins_T)
    #print(bins_A)
    #print(read_count)
    
    # Close the file if it's not stdin
    if input_file != '-':
        file_handle.close()
    
    write_output(sample_name, bins_T, bins_A, read_count, t_gte_90, a_gte_90, output_file, bin_size)
    print(f"Output written to {output_file}") 
