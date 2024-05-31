import sys
import os
from PIL import Image

# Check if a PNG file was provided as an argument
if len(sys.argv) < 2:
    print("Error: No PNG file provided.")
    print("Usage: python script_name.py <input_png>")
    sys.exit(1)

# Get the input PNG file from the command line argument
input_png = sys.argv[1]
os.makedirs("images", exist_ok=True)
# Move the input PNG file to the "images" folder
input_png_filename = os.path.basename(input_png)
new_input_png = os.path.join("images", input_png_filename)
os.rename(input_png, new_input_png)
input_png = new_input_png

# Open the PNG file
try:
    img = Image.open(input_png)
except FileNotFoundError:
    print(f"Error: Could not find file '{input_png}'")
    sys.exit(1)

# Convert and save it as BMP
output_bmp = os.path.join("images", f"{os.path.splitext(os.path.basename(input_png))[0]}.bmp") # Generate BMP file name from PNG
img.save(output_bmp)
print(f"Converted '{input_png}' to '{output_bmp}'")