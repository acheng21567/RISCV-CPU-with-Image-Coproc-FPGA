from PIL import Image
import numpy as np

with open('C:/Users/asus/Desktop/test.mem', 'r') as file, open('mem_res.hex', 'w+') as res_file:
    for _ in range(3):
        file.readline()
    lines = file.readlines()

    for l in lines:
        for e in l.split():
            if e == 'xxx':
                res_file.write('000\n')
            else:
                res_file.write(e + '\n')



def hex_to_rgb(hex_value):
    """Convert a 12-bit hexadecimal value to an (R, G, B) tuple."""
    # Extract the RGB components from the 12-bit hexadecimal value
    r = (hex_value >> 8) & 0xF
    g = (hex_value >> 4) & 0xF
    b = hex_value & 0xF
    
    # Extend 4 bits to 8 bits by repeating the bits (shift left by 4 and add the original value)
    r = (r << 4) | r
    g = (g << 4) | g
    b = (b << 4) | b
    
    return (r, g, b)

def hex_file_to_image(file_path, width, height):
    """Convert a file containing hexadecimal values to an image."""
    # Read the hex data from the file
    with open(file_path, 'r') as file:
        hex_data = file.read().split()
    
    # Create an array to hold the pixel data
    pixels = np.zeros((height, width, 3), dtype=np.uint8)
    
    # Process each hex value and fill the pixel array
    for i in range(height):
        for j in range(width):
            index = i * width + j
            if index < len(hex_data):
                hex_value = int(hex_data[index], 16)
                pixels[i, j] = hex_to_rgb(hex_value)
    
    # Create an image from the pixel array
    image = Image.fromarray(pixels, 'RGB')
    image.show()
    return image


# Example usage
file_path = 'mem_res.hex'  # Path to the file containing the hex data
width = 512  # Width of the image
height = 256  # Height of the image
image = hex_file_to_image(file_path, width, height)
image.save('output_image.png')  # Save the image to a file
