#!/bin/bash

# Check if arguments are provided
if [ -z "$1" ]; then
    echo "Error: Missing required arguments."
    echo "Usage: ./myscript.sh <input_png>"
    exit 1
fi

# Run the first Python script to generate the hex file
input_png="$1"
python ./png2bmp.py "$input_png"

# Get the base name of the input bitmap
base_name=$(basename "$input_png" .png)

# Construct the name of the bmp file
bmp_file="${base_name}.bmp"

# Check if the bmp file was generated
if [ ! -f "$bmp_file" ]; then
    echo "Error: The bmp file was not generated."
    exit 1
fi

python ./bmp2hex.py "${base_name}.bmp"

# Construct the name of the hex file
hex_file="${base_name}.hex"

# Check if the hex file was generated
if [ ! -f "$hex_file" ]; then
    echo "Error: The hex file was not generated."
    exit 1
fi

# Run bootloader to instruction memory
# python Bootloader.py 0 ../CPU/simulation/wiscv.hex

python combine_row.py "$hex_file"
combined_hex_file="${hex_file%.*}_combined.hex"

# Run bootloader to image buffer
python Bootloader.py 2 "$combined_hex_file"