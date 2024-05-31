start:
auipc x2,0x8
addi x2,x2,-8 # 8000 <__stack_top>
addi x8,x2,0
jal	x1 main
jal	x1 exit


exit:
addi x17,x0,93
ecall


main:
addi x2,x2,-48
sw	x1,44(x2)
sw	x8,40(x2)
addi x8,x2,48
addi x15, x0, 1228
#load array values
addi x16,x0, 64
addi x10,x0, 34
addi x11,x0, 25
addi x12,x0, 12
addi x13,x0, 22
addi x14,x0, 11
addi x15,x0, 90
sw	x16,-48(x8)
sw	x10,-44(x8)
sw	x11,-40(x8)
sw	x12,-36(x8)
sw	x13,-32(x8)
sw	x14,-28(x8)
sw	x15,-24(x8)
addi x15,x0,7
sw	x15,-20(x8)
lw	x15,-20(x8)
addi x14,x15,-1
addi x15,x8,-48
add	x12,x14,x0
addi x11,x0,0
add	x10,x15,x0

addi x15,x0,0
add	x10,x15,x0
lw	x1,44(x2)
lw	x8,40(x2)
addi x2,x2,48
jalr x0, x1, 0