ADDI x1, x0, 4
ADDI x2, x0, 2
ADD x3, x1, x2
SW x3, 0(x1)
LW x3, 0(x1)
ADD x6, x3, x3
ADD x0, x0, x0
ecall