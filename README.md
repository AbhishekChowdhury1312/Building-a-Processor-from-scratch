# Building-a-Processor-from-scratch
Welcome to my 16-bit processor project! This repository contains the Verilog code for a 16-bit processor that I've designed and built entirely from scratch using verilog hardware description language. The goal of this project was to deepen my understanding of computer architecture and digital logic design along with implementing verilog efficiently.

# Key features
- 16 bit processor
- Instruction Set Architecture (ISA): The processor supports custom ISA with logical, arithmetic and control operations. These include basic operations like addition, subtraction and multiplication. It supports logical operations like AND, OR, XOR and shift operations. 
- General Purpose Registers (GPRs): The processor uses 32 general purpose registers to store immediate data. A special purpose register (SGPR) is also used to store higher bits of results obtained during multiplication operations. 
- Conditional operations: The processor supports various conditional jump instructions based on different flags such as carry, zero, sign and overflow flags.
- Control Logic: The control logic is implemented using a finite state machine (FSM) that transitions through different states such as fetch, decode_exec, next_inst, and sense_halt. This FSM controls the overall operation of the processor.

- Maintaining flags: The processor maintains flags for carry, zero, sign and overflow, which are set during arithmetic operations.
  
- Multicycle execution: The processor is designed to execute instructions over multiple clock cycles, allowing complex operations like multiplication to be handled efficiently.

- Reading from memory file: The processor is able to read from external memory files, where the instructions are stored in the form of binary with the help of `$readmemb` command.
  
- Data memory and Instruction memory: The processor also has allocated memory for storing and manipulating data bits.

