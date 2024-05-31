###############################################################################
# Primary Project Application Code for polling User I/O Registers
# 	and interacting with Coprocessor
###############################################################################

########################################
# Register Notation:
#	x0: ZERO Register
#	x1: Value 1 Register
#	x2: Base M-Map I/O Register Address (0xFFFFFFF0)
#	x3: KEY Status Register
#	x4: NEW SW Status Register
#	x5: Coprocessor NOP Control Packet
#	x6: PREVIOUS SW Status Register
#	x7: TEMP Register
#	x8: Loop iteration max 
#	x9: Loop index register
#	x10: Coprocessor control packet register
#	x11: Gray Bit Register
#	x12: TEMP Register
########################################



########################################
# Initialization of Address Registers,
#	Masks, I/O, and Coprocessor
########################################
INIT:
	addi x1, x0, 1 				# Value 1
	addi x2, x0, -16 			# Base I/O Address (0xFFFFFFF0)
	addi x5, x0, 0x87 			# Initializing Coproc NOP Constant
	addi x8, x0, 0x7			# Loop Max Interation Constant
	
	# All necessary Register Initializations
	addi x6, x0, 0
	addi x9, x0, 0x0
		
	sw x5, 4(x2) 				# Invoke Coprocessor with NOP
	lw x0, 5(x2) 				# Convert to LWCP to STALL CPU Until Coprocessor DONE


	
########################################
# Main Infinite Loop Calling Polling &
#	Computation Tasks
########################################
MAIN:
	lw x3, 2(x2) 				# Load KEY Status
	lw x4, 1(x2)				# Load SW State
	sw x4, 0(x2)				# Display SW State to LED Array
	beq x3, x1, CLEAR			# Clear Screen with NOP if KEY = 0001
	
	# Compare Current & Previous SW State for Posedge Detection
	COMPARE_REGS:
		not x7, x6
		and x7, x7, x4
		addi x6, x4, 0			# Save PREVIOUS = NEW for future comparisons
		bne x7, x0, START 		# Begin Coprocessor Operations if change in SW state
		j MAIN					# Infinitely Loop back to MAIN if NO Change



########################################
# Task for Decoding SW Settings and
#	Invoking Coprocessor for each SW
#	instruction
########################################
START:
	addi x9, x0, 0 				# Clear Intruction Counter Register
	addi x7, x0, 0xA0			# Create CTL Packet with START, IMG_IDX BIT = 1
	
	# Add Gray Bit into CTL Packet
	andi x11, x4, 0x200			# Mask for Gray Bit from SW Array
	srli x11, x11, 3			# Shift Down to Correct Place in CTL Packet
	or x7, x11, x7				# Combine with CTL Packet

	
	# Iterate Though All Switches & Generate Coproc Commands
	SW_LOOP:
		# Mask LSB BIT -> If 1, Perform Operation
		and x12, x4, x1
		beq x12, x1, PERFORM_OP
		
		# Increment Counters & Shift SW Array for next Iteration
		INC_LOOP:
			addi x9, x9, 1
			srli x4, x4, 1
			beq x9, x8, MAIN		# Exit Back to Main if DONE
			j SW_LOOP
	
	# Performing Coprocessor Operation
	PERFORM_OP:	
		# Add FUNC onto packet
		or x10, x7, x9
		
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