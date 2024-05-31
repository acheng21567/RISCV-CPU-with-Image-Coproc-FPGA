_start:

    # Initialize pairs of registers with different values
    li x1, 1
    li x2, 2
    li x3, 3
    li x4, 4
    li x5, 5
    li x6, 6
    li x7, 7
    li x8, 8
    li x9, 9
    li x10, 10
    li x11, 11
    li x12, 12
    li x13, 13
    li x14, 14
    li x15, 15
    li x16, 16
    li x17, 17
    li x18, 18
    li x19, 19
    li x20, 20
    li x21, 21
    li x22, 22
    li x23, 23
    li x24, 24
    li x25, 25
    li x26, 26
    li x27, 27
    li x28, 28
    li x29, 29
    li x30, 30
    li x31, -31

    # Check if the value in the first register is less than the value in the second register
    bge x1, x2, error
    bge x3, x4, error
    bge x5, x6, error
    bge x7, x8, error
    bge x9, x10, error
    bge x11, x12, error
    bge x13, x14, error
    bge x15, x16, error
    bge x17, x18, error
    bge x19, x20, error
    bge x21, x22, error
    bge x23, x24, error
    bge x25, x26, error
    bge x27, x28, error
    bge x29, x30, error
    bge x31, x0, error

    j done

	error:
	li x31, 0
    j done

done:
    # End of program
    ecall