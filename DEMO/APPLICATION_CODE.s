###############################################################################
# Primary Project Application Code for polling User I/O Registers
# 	and interacting with Coprocessor
###############################################################################

########################################
# Register Notation:
#	x0: ZERO Register
#	x1: Return Address Register
#	x2: Base M-Map I/O Register Address (0xFFFFFFF0)
#	x3: 
#	x4: Gray & IMG_IDX Mask
#	x5: Coproc NOP Control Word (0x80)
#	x6: KEY Status
#	x7: SW Status
#	x8: Constant Value 8 for Exiting Loop
#	x9: TEMP bit for Masking
#	x10: Coproc Control Packet
#	x11: Key TOGGLE THRESH Mask
#	x12: Key START Mask
#	x13: Key CLEAR Mask
#	x14: TEMP Register for Intermediate Ops
#	x15: Loop Counter Register
#	x16: TEMP CTL Packet Register
########################################



########################################
# Initialization of Address Registers,
#	Masks, I/O, and Coprocessor
########################################
INIT:
	addi x2, x0, -16 	# Base I/O Address (0xFFFFFFF0)
	addi x5, x0, 0x87 	# Initializing Coproc NOP Constant
	addi x8, x0, 0x7 	# Initializing Loop Max Variable
	
	# Mask Defaults
	addi x4, x0, 0x300
	addi x11, x0, 0x1
	addi x12, x0, 0x2
	addi x13, x0, 0x4
	
	sw x5, 4(x2) 		# Invoke Coprocessor with NOP
	lw x0, 5(x2) 		# Convert to LWCP to STALL CPU Until Coprocessor DONE


	
########################################
# Main Infinite Loop Calling Polling &
#	Computation Tasks
########################################
MAIN:
	lw x7, 1(x2)				# Load SW State
	lw x6, 2(x2) 				# Load KEY Status
	sw x7, 0(x2)				# Display SW State to LED Array
	beq x6, x12, START			# Start Coprocessor Transmission if KEY = 0010
	beq x6, x13, CLEAR			# Clear Screen with NOP if KEY = 0100
	j MAIN						# Infinitely Loop back to MAIN if NO Change



########################################
# Task for Decoding SW Settings and
#	Invoking Coprocessor for each SW
#	instruction
########################################
START:
	addi x15, x0, 0 		# Clear Intruction Counter Register
	addi x16, x0, 0x80		# Create CTL Packet with START BIT
	
	# Add Gray, IMG_IDX into CTL Packet
	and x14, x7, x4 	# Mask for Gray, IMG_IDX Bits
	srli x14, x14, 3	# Shift Down to Correct Place in CTL Packet
	or x16, x16, x14	# Combine with CTL Packet
	
	# Iterate Though All Switches & Generate Coproc Commands
	SW_LOOP:
		and x9, x7, x11		# Mask LSB BIT -> If 1, Perform Operation
		beq x9, x11, PERFORM_OP
		
		# Increment Counters & Shift SW Array for next Iteration
		INC_LOOP:
			addi x15, x15, 1
			srli x7, x7, 1
			beq x15, x8, MAIN		# Exit Back to Main if DONE
			j SW_LOOP
	
	# Performing Coprocessor Operation
	PERFORM_OP:	
		# Add FUNC onto packet
		or x10, x16, x15
		
		# Invoke Coprocessor
		sw x10, 4(x2)
		
		# Convert to LWCP to STALL CPU Until Coprocessor DONE
		lw x0, 5(x2)
		
		# Return Back to Loop
		j INC_LOOP



########################################
# Task for Clearing Recent Img on Display
#	Simple Invoking of Coprocessor NOP
#	to replace current Recent Img with 
#	Original Img
########################################
CLEAR:
	sw x5, 4(x2) 	# Invoke Coprocessor with NOP
	lw x0, 5(x2)	# Convert to LWCP to STALL CPU Until Coprocessor DONE
	j MAIN			# Return to MAIN After Toggle Completion