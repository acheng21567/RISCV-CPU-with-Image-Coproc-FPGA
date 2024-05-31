# Register & Mask Initialization
addi x5, x0, -16 # x5 <- Base I/O Address
addi x4, x0, 0x20 # x4 <- CTL Command Sent to Coprocessor {START, GRAY, IMG_IDX, FUNC[2:0]}

# Initiate Coprocessor Operation
sw x4, 4(x5) # Send Command to CTL Register

# Poll until DONE is observed
POLL_DONE:
lw x3, 5(x5) # Polling of Coprocessor Status Register
bne x3, x0, DONE
jal x0, POLL_DONE # Continue Polling if NOT Ready

# Exit Program
DONE:
ecall