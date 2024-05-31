onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group GLOBAL /CPU_tb/clk
add wave -noupdate -group GLOBAL /CPU_tb/rst_n
add wave -noupdate -group GLOBAL /CPU_tb/current_test
add wave -noupdate -group GLOBAL /CPU_tb/cycle_count
add wave -noupdate -group GLOBAL /CPU_tb/HLT
add wave -noupdate -group GLOBAL /CPU_tb/error
add wave -noupdate -expand -group CPU -group FETCH -radix hexadecimal /CPU_tb/DUT/CPU/IF/PC
add wave -noupdate -expand -group CPU -group FETCH -radix hexadecimal /CPU_tb/DUT/CPU/IF/Inst
add wave -noupdate -expand -group CPU -group FETCH /CPU_tb/DUT/CPU/IF/PC_EN
add wave -noupdate -expand -group CPU -group FETCH -radix hexadecimal /CPU_tb/DUT/CPU/IF/TARGET_ADDR
add wave -noupdate -expand -group CPU -group FETCH -radix hexadecimal /CPU_tb/DUT/CPU/IF/PC_NEXT
add wave -noupdate -expand -group CPU -group HAZARD_UNIT /CPU_tb/DUT/CPU/HU/load_to_use
add wave -noupdate -expand -group CPU -group HAZARD_UNIT /CPU_tb/DUT/CPU/HU/branch_jumpr
add wave -noupdate -expand -group CPU -group HAZARD_UNIT /CPU_tb/DUT/CPU/HU/load_to_branch_jumpr
add wave -noupdate -expand -group CPU -group HAZARD_UNIT /CPU_tb/DUT/CPU/HU/STALL
add wave -noupdate -expand -group CPU -group HAZARD_UNIT /CPU_tb/DUT/CPU/HU/FLUSH
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/OPCODE
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/FUNC3
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/BIT30
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/R
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/I
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/S
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/B
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/U
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/J
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/IMM_SEL
add wave -noupdate -expand -group CPU -group DECODE -radix hexadecimal /CPU_tb/DUT/CPU/ID/IMM32
add wave -noupdate -expand -group CPU -group DECODE -radix unsigned /CPU_tb/DUT/CPU/ID/ID_RS1
add wave -noupdate -expand -group CPU -group DECODE -radix hexadecimal /CPU_tb/DUT/CPU/ID/SRA
add wave -noupdate -expand -group CPU -group DECODE -radix unsigned /CPU_tb/DUT/CPU/ID/ID_RS2
add wave -noupdate -expand -group CPU -group DECODE -radix hexadecimal /CPU_tb/DUT/CPU/ID/SRB
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/BRANCH_CCC
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/BRANCH
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/branch_en
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/control_unit/jump_en
add wave -noupdate -expand -group CPU -group DECODE /CPU_tb/DUT/CPU/ID/TARGET_SRC_SEL
add wave -noupdate -expand -group CPU -group FORWARDING_UNIT /CPU_tb/DUT/CPU/FU/FORWARD_EXECUTE_A
add wave -noupdate -expand -group CPU -group FORWARDING_UNIT /CPU_tb/DUT/CPU/FU/FORWARD_EXECUTE_B
add wave -noupdate -expand -group CPU -group FORWARDING_UNIT /CPU_tb/DUT/CPU/FU/FORWARD_MEMORY
add wave -noupdate -expand -group CPU -group FORWARDING_UNIT /CPU_tb/DUT/CPU/FU/FORWARD_DECODE_A
add wave -noupdate -expand -group CPU -group FORWARDING_UNIT /CPU_tb/DUT/CPU/FU/FORWARD_DECODE_B
add wave -noupdate -expand -group CPU -group EXECUTE /CPU_tb/DUT/CPU/EX/ID_EX_ALU_OP
add wave -noupdate -expand -group CPU -group EXECUTE -radix unsigned /CPU_tb/DUT/CPU/EX/ID_EX_SHAMT
add wave -noupdate -expand -group CPU -group EXECUTE /CPU_tb/DUT/CPU/EX/ID_EX_ALU_A_SRC
add wave -noupdate -expand -group CPU -group EXECUTE -radix hexadecimal /CPU_tb/DUT/CPU/EX/A_IN
add wave -noupdate -expand -group CPU -group EXECUTE /CPU_tb/DUT/CPU/EX/ID_EX_ALU_B_SRC
add wave -noupdate -expand -group CPU -group EXECUTE -radix hexadecimal /CPU_tb/DUT/CPU/EX/B_IN
add wave -noupdate -expand -group CPU -group EXECUTE /CPU_tb/DUT/CPU/EX/ID_EX_EX_OUT_SEL
add wave -noupdate -expand -group CPU -group EXECUTE -radix hexadecimal /CPU_tb/DUT/CPU/EX/EXECUTE_OUT
add wave -noupdate -expand -group CPU -group MEMORY /CPU_tb/DUT/CPU/MEM/EX_MEM_MEM_TYPE
add wave -noupdate -expand -group CPU -group MEMORY /CPU_tb/DUT/CPU/MEM/EX_MEM_MEM_READ
add wave -noupdate -expand -group CPU -group MEMORY /CPU_tb/DUT/CPU/MEM/EX_MEM_MEM_WRITE
add wave -noupdate -expand -group CPU -group MEMORY -radix hexadecimal /CPU_tb/DUT/CPU/MEM/EX_MEM_EXECUTE_OUT
add wave -noupdate -expand -group CPU -group MEMORY -radix hexadecimal /CPU_tb/DUT/CPU/MEM/MEM_DATA_IN
add wave -noupdate -expand -group CPU -group MEMORY -radix hexadecimal /CPU_tb/DUT/CPU/MEM/MEM_DATA_OUT
add wave -noupdate -expand -group CPU -group {WRITE BACK} /CPU_tb/DUT/CPU/WB/MEM_WB_WB_SRC_SEL
add wave -noupdate -expand -group CPU -group {WRITE BACK} -radix hexadecimal /CPU_tb/DUT/CPU/WB/MEM_WB_MEM_DATA_OUT
add wave -noupdate -expand -group CPU -group {WRITE BACK} -radix hexadecimal /CPU_tb/DUT/CPU/WB/MEM_WB_EXECUTE_OUT
add wave -noupdate -expand -group CPU -group {WRITE BACK} -radix hexadecimal /CPU_tb/DUT/CPU/WB/WB_OUT
add wave -noupdate -expand -group CPU -group {WRITE BACK} -radix unsigned /CPU_tb/DUT/CPU/MEM/MEM_WB_RD
add wave -noupdate -expand -group CPU -group {WRITE BACK} /CPU_tb/DUT/CPU/MEM/MEM_WB_REG_WRITE
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/IO_ADDR
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/IO_WEN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/IO_WDATA
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/IO_RDEN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/IO_RDATA
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/LED_EN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/LEDR
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/SW_EN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/SW
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/KEY_EN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/KEY
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/COPROC_CTL_EN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/COPROC_CTL
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/COPROC_STS_EN
add wave -noupdate -group {I/O Layer} -radix hexadecimal /CPU_tb/DUT/IO/COPROC_STS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {515 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 299
configure wave -valuecolwidth 119
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1313 ps}
