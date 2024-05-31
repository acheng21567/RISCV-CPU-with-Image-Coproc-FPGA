addi x1, x0, 5
addi  x5, x0, -16 # x5 <- Base I/O Address
sw x1, 0(x1) # Store to Data Memory
lw x2, 5(x0) # Load from Data Memory
sw x1, 0(x5) # Attempt to Write to LED Array
lw x2, 1(x5) # Attempt to Read from SW Array
lw x2, 2(x5) # Attempt to Read from KEY Array
sw x1, 4(x5) # Attempt to Write to CoProcessor CTL
lw x3, 5(x5) # Attempt to Read from KEY Array
ecall