import sys
if len(sys.argv) < 2:
    sys.exit("Usage: python script.py <infile>")
path = sys.argv[1]


file_names = []

for b in range(3):
    curr = []
    for i in range(12):
        curr.append(f'bank{b}_{i}.hex')
    file_names.append(curr)

files = [[open(file_names[j][i], 'w+') for i in range(12)] for j in range(3)]

with open(path, 'r') as f:
    for file in files[0]:
        file.write('0' * 64 + '\n')

    for idx in range(1, 257):
        line = ''
        for i in range(256):
            l = f.readline().strip()
            line += l
        
        for i in range(11, -1, -1):
            files[idx%3][11 - i].write(line[i*64:(i+1)*64] + '\n')
    
    for file in files[2]:
        file.write('0' * 64 + '\n')