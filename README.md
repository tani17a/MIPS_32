# MIPS_32
A 32 bit MIPS Processor with 13 Instructions under controlled conditions , with basic testbench just to check the functioning of the module.
MIPS 32-bit Pipelined Processor
Overview
This project implements a 32-bit 5-stage pipelined MIPS processor using Verilog. The processor follows the MIPS architecture and includes instruction stages such as Instruction Fetch (IF), Instruction Decode (ID), Execution (EX), Memory Access (MEM), and Write Back (WB).

File Description
File Name: MIPS_processor_32bit.v
Module Name: MIPS32_pipe
Author: Tania Choudhary
Purpose: Implements a 32-bit 5-stage pipelined MIPS processor.
Functionality
Pipeline Stages
Instruction Fetch (IF):

Fetches the instruction from memory and increments the Program Counter (PC).
Handles branch instructions by updating the PC if a branch is taken.
Instruction Decode (ID):

Decodes the fetched instruction.
Reads the source registers and sign-extends the immediate values.
Classifies the instruction type for subsequent stages.
Execution (EX):

Executes the arithmetic and logic operations using the ALU.
Computes the branch target address and evaluates the branch condition.
Memory Access (MEM):

For load and store instructions, accesses the data memory.
Stores the computed results into the memory when required.
Write Back (WB):

Writes the results back to the register file.
Handles the HALT instruction to stop the processor.
ALU Operations
The ALU supports the following operations:

Arithmetic: ADD, SUB, ADDI, SUBI, MUL
Logical: AND, OR, SLT, SLTI
Memory Access: LW (Load Word), SW (Store Word)
Branching: BEQZ (Branch if Equal to Zero), BNEQZ (Branch if Not Equal to Zero)
Halt: HLT (Halt the processor)
Registers and Memory
Register File: 32 general-purpose 32-bit registers.
Data Memory: 1024 words of 32-bit memory.
