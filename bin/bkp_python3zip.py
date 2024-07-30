#!/usr/bin/env python3
# coding: utf-8
# Author: Amal Thomas

import gzip
import sys
import os
from collections import defaultdict
import argparse

def calculate_nucleotide_percentage(seq, nucleotide):
    count = seq.count(nucleotide)
    return (count / len(seq)) * 100

def bin_percentage(percentage, w):
    if percentage == 100:
        return 100 - w
    return int(percentage // w) * w

def process_fastq(file_handle, bins_T, bins_A, t_gte_90, a_gte_90, read_count, bin_width):
    while True:
        header = file_handle.readline().strip()
        if not header:
            break
        if header[0] != "@":
            print(f"Error!!!\nheader line not starting with @")
            print(header, "\n")
            continue
            #sys.exit(1)
        seq = file_handle.readline().strip().upper()
        plus = file_handle.readline().strip()
        qual = file_handle.readline().strip()

        if not seq:
            break

        read_count += 1

        percent_T = calculate_nucleotide_percentage(seq, 'T')
        percent_A = calculate_nucleotide_percentage(seq, 'A')

        bin_T = bin_percentage(percent_T, bin_width)
        bin_A = bin_percentage(percent_A, bin_width)

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
        f.write("sample\ttotal_reads\tNucT_gte_pct_90\tNucA_gte_pct_90\tNucT_gte_num_90\tNucA_gte_num_90")
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
    parser = argparse.ArgumentParser(description='Calculate A and T percentages in fastq files')
    parser.add_argument('-s', '--sample', help='Sample name')
    parser.add_argument('-o', '--output_file', help='Output file name')
    parser.add_argument('-i', '--input', action='append', required=True, help='Input fastq file(s)')

    args = parser.parse_args()

    bin_size = 5
    bins_T = defaultdict(int)
    bins_A = defaultdict(int)
    read_count = 0
    t_gte_90 = 0
    a_gte_90 = 0

    for input_file in args.input:
        if input_file == '-':
            file_handle = sys.stdin
            base_name = 'stdin'
            print("Input provided as STDIN")
        else:
            print(f"Processing input file: {input_file}")
            try:
                file_handle = gzip.open(input_file, 'rt')
                file_handle.read(1)  # Attempt to read to verify if it's gzipped
                file_handle.seek(0)  # Reset the file pointer after the test read
                print("Input file is gzipped")
            except (OSError, gzip.BadGzipFile):
                print("Input file is NOT gzipped")
                file_handle = open(input_file, 'r')
        
        bins_T, bins_A, read_count, t_gte_90, a_gte_90 = process_fastq(
            file_handle, bins_T, bins_A, t_gte_90, a_gte_90, read_count, bin_size
        )
        
        # Close the file if it's not stdin
        if input_file != '-':
            file_handle.close()

    write_output(args.sample, bins_T, bins_A, read_count, t_gte_90, a_gte_90, args.output_file, bin_size)
    print(f"Output written to {args.output_file}")
