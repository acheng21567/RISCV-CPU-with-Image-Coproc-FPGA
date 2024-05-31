import sys
from PIL import Image

# Check if a PNG file was provided as an argument
if len(sys.argv) < 2:
    print("Error: No PNG file provided.")
    print("Usage: python script_name.py <input_png>")
    sys.exit(1)

# Get the input PNG file from the command line argument
input_png = sys.argv[1]

# Open the PNG file
try:
    img = Image.open(input_png)
except FileNotFoundError:
    print(f"Error: Could not find file '{input_png}'")
    sys.exit(1)

# Convert and save it as BMP
output_bmp = f"{input_png.split('.')[0]}.bmp"  # Generate BMP file name from PNG
img.save(output_bmp)
print(f"Converted '{input_png}' to '{output_bmp}'")