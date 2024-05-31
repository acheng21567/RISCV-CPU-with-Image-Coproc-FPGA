import sys
def print_ln(s):
    print("// " + s)

with open("portlist.txt", "r") as file:
    for _ in range(int(sys.argv[1])):
        module = []
        line = file.readline()
        while line:
            module.append(line.strip("\n").split(";"))
            line = file.readline()
            if line == "\n":
                break
        
        print_ln("/////////////////////////////////////////////////////////////////////////////")
        print_ln("Program: " + module[0][0])
        print_ln("")
        print_ln("Project: ECE 554 COPROC")
        print_ln("")
        print_ln("Author: Team Sachima")
        print_ln("")
        print_ln("Description:")
        print_ln(" - ")
        print_ln("")
        print_ln(" - Inputs:")
        for i in range(2, len(module)):
            if module[i][1] != "Input":
                break
            print_ln("    " + module[i][0] + ": \t" + module[i][2])
        print_ln("")
        print_ln(" - Outputs:")
        for j in range(i, len(module)):
            if module[j][0] != "":
                print_ln("    " + module[j][0] + ": \t" + module[j][2])
        print_ln("/////////////////////////////////////////////////////////////////////////////")

