# Register & Mask Initialization
addi x5, x0, -16 # x5 <- Base I/O Address
addi x4, x0, 0x25 # x4 <- CTL Command Sent to Coprocessor {START, GRAY, IMG_IDX, FUNC[2:0]}

# Initiate Coprocessor Operation
sw x4, 4(x5) # Send Command to CTL Register
lw x0, 5(x5) # Convert to LWCP to STALL CPU Until DONE

# Exit Program
DONE:
ecall