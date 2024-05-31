with open('Miku.hex', 'r') as f, open('Bank0.hex', 'w+') as b0, open('Bank1.hex', 'w+') as b1, open('Bank2.hex', 'w+') as b2:
    file_list = [b0, b1, b2]
    b0.write('0' * 256 * 3 + '\n')
    for idx in range(1, 257):
        line = ''
        for i in range(256):
            l = f.readline().strip()
            line += l

        file_list[idx % 3].write(line + '\n')
    
    b2.write('0' * 256 * 3 + '\n')