import sys
import os

def convert_bmp_to_hex(infile):
    # Attempt to open the input file
    try:
        with open(infile, 'rb') as f:
            data = f.read()
    except IOError:
        sys.exit(f"ERROR: Can't open {infile} for read")

    numbytes = len(data)
    print(f"read {numbytes} bytes from file")

    # Extracting image dimensions and start of image data from BMP header
    size_encoded = int.from_bytes(data[2:6], byteorder='little')
    if size_encoded == numbytes:
        print("Good size encoded equals size read")
    else:
        print("ERR: size encoded does not match size read")
        sys.exit(1)

    image_start = int.from_bytes(data[10:14], byteorder='little')
    print(f"image data starts at hex location {image_start:x}")

    xdim = int.from_bytes(data[18:22], byteorder='little')
    ydim = int.from_bytes(data[22:26], byteorder='little')
    print(f"image dimensions are {xdim} x {ydim}")

    basename = os.path.splitext(os.path.basename(infile))[0]
    PGMname = os.path.join("images", f"{basename}.pgm")
    HEXname = os.path.join("images", f"{basename}.hex")

    # Generating the .hex files
    with open(PGMname, 'w') as pgm, open(HEXname, 'w') as hexf:
        ln = 0

        pgm.write(f"P2\n{xdim} {ydim}\n63\n")
        # Process each pixel
        for y in range(ydim-1, -1, -1):
            for x in range(xdim):
                img_index = image_start + y * xdim * 3 + x * 3
                blue, green, red = data[img_index:img_index+3]

                is_transparent = (blue == 32 and green == 64 and red == 128)
                pixel = 0xFFF
                red &= 0xF0
                pixel = red << 4
                green &= 0xF0
                pixel |= (green)
                blue >>= 4
                pixel |= blue

                # if pixel == 36 and not is_transparent:
                #     pixel = 37
                #     print("it ", end="")

                pgm.write(f"{pixel} ")
                # hexf.write(f"@{ln:04x} {pixel:03x}\n")
                hexf.write(f"{pixel:03x}\n")
                ln += 1
            pgm.write("\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("Usage: python script.py <infile>")
    convert_bmp_to_hex(sys.argv[1])