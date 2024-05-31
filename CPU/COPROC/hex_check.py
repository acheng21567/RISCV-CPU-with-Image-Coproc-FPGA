# from PIL import Image
# import numpy as np

# def hex_to_rgb(hex_value):
#     """Convert a 12-bit hexadecimal value to an (R, G, B) tuple."""
#     # Extract the RGB components from the 12-bit hexadecimal value
#     r = (hex_value >> 8) & 0xF
#     g = (hex_value >> 4) & 0xF
#     b = hex_value & 0xF
    
#     # Extend 4 bits to 8 bits by repeating the bits (shift left by 4 and add the original value)
#     r = (r << 4) | r
#     g = (g << 4) | g
#     b = (b << 4) | b
    
#     return (r, g, b)

# def hex_file_to_image(file_path, width, height):
#     """Convert a file containing hexadecimal values to an image."""
#     # Read the hex data from the file
#     with open("Bank0.hex", 'r') as b0, open("Bank1.hex", 'r') as b1, open("Bank2.hex", 'r') as b2:
#         b0_data = b0.read().splitlines()
#         b1_data = b1.read().splitlines()
#         b2_data = b2.read().splitlines()
#         datas = [b0_data, b1_data, b2_data]
#         hex_data = []
#         for i in range(1, height - 1):
#             hex_data.append(datas[i % 3][i // 3])
    
#     # Create an array to hold the pixel data
#     pixels = np.zeros((height, width, 3), dtype=np.uint8)

#     print(hex_data[1][0:3])
#     for i in range(height - 2):
#         curr = hex_data[i]
#         # print(len(hex_data), i)

#         # print()
#         for j in range(0, width - 2, 2):
#             pixels[i, j] = hex_to_rgb(int(curr[j:j+3], 16))
    
#     # Create an image from the pixel array
#     image = Image.fromarray(pixels, 'RGB')
#     image.show()
#     return image

# # Example usage
# file_path = 'Bank2.hex'  # Path to the file containing the hex data
# width = 256  # Width of the image
# height = 258  # Height of the image
# image = hex_file_to_image(file_path, width, height)
# image.save('output_image.png')  # Save the image to a file


from PIL import Image
import numpy as np
import sys

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
