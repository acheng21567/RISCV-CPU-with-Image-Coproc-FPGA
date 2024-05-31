ADDI x1, x0, 4
ADDI x2, x0, 2
ADDI x3, x0, 3

t0:
SW x3, 0(x1)
LW x5, 0(x1)
blt x2, x5, done

ADDI x5, x0, -1
done:
ecall