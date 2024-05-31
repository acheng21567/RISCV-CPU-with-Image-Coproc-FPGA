#!/bin/bash

# Check if arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required arguments."
    echo "Usage: ./Bootload.sh <program select, 0: default, 1: presentation> <input_png>"
    exit 1
fi

program_select=$1
input_png="images/$2"

# Run the first Python script to generate the hex file
python ./png2bmp.py "$input_png"

# Get the base name of the input bitmap
base_name=$(basename "$input_png" .png)
mkdir -p images

# Construct the name of the bmp file
bmp_file="images/${base_name}.bmp"

# Check if the bmp file was generated
if [ ! -f "$bmp_file" ]; then
    echo "Error: The bmp file was not generated."
    exit 1
fi

python ./bmp2hex.py "$bmp_file"

# Construct the name of the hex file
hex_file="images/${base_name}.hex"

# Check if the hex file was generated
if [ ! -f "$hex_file" ]; then
    echo "Error: The hex file was not generated."
    exit 1
fi

python combine_row.py "$hex_file"
combined_hex_file="images/${base_name}_combined.hex"

# Determine which hex file to use based on program select
if [ "$program_select" -eq 1 ]; then
    hex_to_load="../hex_files/wiscv1.hex"
else
    hex_to_load="../hex_files/wiscv.hex"
fi

# Run bootloader to instruction memory
python Bootloader.py 0 "$hex_to_load"

# Run bootloader to image buffer
python Bootloader.py 2 "$combined_hex_file"
