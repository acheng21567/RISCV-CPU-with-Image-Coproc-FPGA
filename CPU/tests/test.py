import sys

output_name = sys.argv[1]

file1 = open('registers.txt', 'r')
Lines = file1.readlines()

file_base = output_name + "_expected" + ".hex"
sourceFile = open(file_base, 'w')

for Line in Lines:
  start = Line.find("0x")
  if (start != -1):
    print(Line[start + 2 : ].strip(), file = sourceFile)

sourceFile.close()
