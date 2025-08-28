# MIPS Processor with Interrupt Handling

## 📖 Overview
This project implements a **MIPS-like pipelined processor** in Verilog, with:
- 5 pipeline stages (IF, ID, EX, MEM, WB)
- Interrupt handling mechanism (using `Cause_IP`)
- Flag register updates (Zero, Sign, Parity, Carry)
- Stack mechanism for saving/restoring registers during interrupts

## ⚡ Features
- **Instruction Set:** Supports arithmetic, logical, load/store, and branch instructions.
- **Flags:** 
  - Zero (Z)  
  - Sign (S)  
  - Carry (C)  
  - Parity (P)  
- **Interrupt Handling:** 
  - Multiple interrupts with priority encoding
  - Saving PC and flags on interrupt
  - Restoring state on return
- **Stack:** Registers pushed/popped on interrupt entry/exit.

 # Pipeline Stages
Instruction Fetch (IF)
Instruction Decode (ID)
Execution (EX)
Memory Access (MEM)
Write Back (WB)

# Registers and Memory
Register File: 32 general-purpose 32-bit registers.
Data Memory: 1024 words of 32-bit memory.
