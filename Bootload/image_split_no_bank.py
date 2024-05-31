import sys
if len(sys.argv) < 2:
    sys.exit("Usage: python script.py <infile>")
path = sys.argv[1]


file_names = []
num_files = 5
WIDTH = 256
HEIGHT = 256

for i in range(num_files):
    file_names.append(f'IMG_PART{i}.hex')

files = [open(file_names[i], 'w+') for i in range(num_files)]

with open(path, 'r') as f:
    for i in range(HEIGHT):
        curr_line = ''
        for _ in range(WIDTH):
            curr_line += f.readline().strip()
        
        r = 640//4
        base = 512//4
        files[0].write(curr_line[:base] + '\n')
        for j in range(1, 5):
            files[j].write(curr_line[base+(j-1)*r:base+(j)*r] + '\n')

        # r = 640//4
        # for j in range(4):
        #     files[j].write(curr_line[j*r : (j + 1)*r] + '\n')
        # files[0].write(curr_line[(j+1)*r:] + '\n')