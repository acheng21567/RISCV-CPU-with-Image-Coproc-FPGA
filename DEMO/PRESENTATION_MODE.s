###############################################################################
# Secondary Project Application Code for cycling through image processing 
#	outputs to a monitor in a "Presentation Style"
###############################################################################

########################################
# Register Notation:
#	x0: ZERO Register
#	x1: 1 Register
#	x2: Base M-Map I/O Register Address (0xFFFFFFF0)
#	x3: Coproc Bast Control Word (0x80)
#	x4: START/STOP Toggle Register
#	x5: Running CNT Function Register
#	x6: KEY Register
#	x7: TEMP Register
#	x8: Masked Func Register for Control Packet Formation
#	x9: Masked GRAY Register for Control Packet Formation
#	x10: Cooldown Counter Register
#	x11: Cooldown THRESHOLD Register
########################################



########################################
# Initialization of Address Registers,
#	Masks, I/O, and Coprocessor
########################################
INIT:
	addi x1, x0, 1				# Filling x1 with 1
	addi x2, x0, -16 			# Base I/O Address (0xFFFFFFF0)
	addi x3, x0, 0x80 			# Initializing Coproc Base Control Word
	addi x4, x0, 0				# Clearing Toggle Register
	addi x5, x0, 0				# Clearing Function Register
	li x11, 25000000			# Loading of Cooldown Threshold Value (2 Seconds)
	
	# Perform NOP to Initialize Monitor Original Img
	addi x7, x3, 0x7			# ADD NOP Function to Base Control Word
	sw x7, 4(x2)				# Invoke Coprocessor with Control Word
	lw x0, 5(x2) 				# Convert to LWCP to STALL CPU Until Coprocessor DONE
	


########################################
# Main Infinite Loop Calling Polling &
#	Computation Tasks
########################################
MAIN:
	lw x6, 2(x2) 				# Load KEY Status
	bne x6, x1, CHECK_TOGGLE	# Skip Toggle Update if Button NOT pressed
	add x4, x4, x1				# Increment Toggle Register if Button pressed
	
	CHECK_TOGGLE:
		# Check Toggle Register LSB == 1 --> Presentation ON State
		and x7, x4, x1			# Mask LSB of Toggle State
		sw x7, 0(x2)			# Display Presentation State to LED Array
		bne x7, x1, MAIN 		# Return to MAIN for KEY Polling if NOT in Presentation ON state
		
		# Generate Control Packet to Display to Monitor in On State
		andi x8, x5, 0x7		# Mask & Append Function Count
		or x7, x3, x8
		andi x9, x5, 0x8		# Mask & Append Gray Setting
		slli x9, x9, 3
		or x7, x7, x9
		
		sw x7, 4(x2)			# Invoke Coprocessor with Control Word
		lw x0, 5(x2) 			# Convert to LWCP to STALL CPU Until Coprocessor DONE
		add x5, x5, x1			# Increment Function Counter for Next Iteration
		
		# Perform Cooldown to allow for Viewing of Image for at least 2 seconds
		addi x10, x0, 0			# Clear Cooldown counter register
		
		COOLDOWN:
			add x10, x10, x1	# Increment Counter & Compare with Cooldown Threshold
			bne x10, x11, COOLDOWN	
			j MAIN				# Return to MAIN once cooldown period is met