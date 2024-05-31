ADDI x1, x0, 1
ADDI x2, x0, 2

t0:
ADDI x5, x0, 5
blt x2, x5, done

ADDI x5, x0, -1
done:
ecall