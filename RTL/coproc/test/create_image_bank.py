for i in range(86):
    s = hex(i)[2:].rjust(4, '0')
    print('@'+s, end=' ')
    for j in range(3072//4):
        num = hex(i % 16)[2:]
        print(num, end = '')
    print()