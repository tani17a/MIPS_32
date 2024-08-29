# MIPS_32
A 32 bit MIPS Processor with 13 Instructions under controlled conditions , with basic testbench just to check the functioning of the module.
MIPS 32-bit Pipelined Processor

# Overview
This project implements a 32-bit 5-stage pipelined MIPS processor using Verilog. The processor follows the MIPS architecture and includes instruction stages such as Instruction Fetch (IF), Instruction Decode (ID), Execution (EX), Memory Access (MEM), and Write Back (WB).

 # Pipeline Stages
Instruction Fetch (IF)
Instruction Decode (ID)
Execution (EX)
Memory Access (MEM)
Write Back (WB)

# ALU Operations
The ALU supports the following operations:
Arithmetic: ADD, SUB, ADDI, SUBI, MUL
Logical: AND, OR, SLT, SLTI
Memory Access: LW (Load Word), SW (Store Word)
Branching: BEQZ (Branch if Equal to Zero), BNEQZ (Branch if Not Equal to Zero)
Halt: HLT (Halt the processor)

# Registers and Memory
Register File: 32 general-purpose 32-bit registers.
Data Memory: 1024 words of 32-bit memory.
