import sys
import os

def combine_rows(input_filename):
    # Generate output filename based on input filename, keeping the .hex extension
    base_name, ext = os.path.splitext(input_filename)
    output_filename = f"{base_name}_combined{ext}"

    # Read all lines from the input file
    with open(input_filename, 'r') as file:
        lines = file.readlines()

    # Process lines in blocks of 256 and combine them
    combined_lines = []
    for i in range(0, len(lines), 256):
        block = lines[i:i+256]
        combined_line = ''.join(line.strip() for line in block)
        combined_lines.append(combined_line)

    # Write all combined lines to the output file
    with open(output_filename, 'w') as file:
        for line in combined_lines:
            file.write(line + '\n')

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python combine_rows.py <inputfile>")
    
    input_filepath = sys.argv[1]
    combine_rows(input_filepath)
