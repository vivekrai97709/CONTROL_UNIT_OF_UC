# 8-Bit Custom Mini CPU (VHDL)

A custom, accumulator-based 8-bit microcontroller implemented in VHDL. This project features a custom Instruction Set Architecture (ISA), an integrated Arithmetic Logic Unit (ALU), and a 4-state Finite State Machine (FSM) control unit. 

The design was synthesized for a Xilinx Spartan-6 FPGA and simulated using Xilinx ISim.

## ⚙️ Architecture Overview
* **Program Counter (PC):** 4-bit register allowing up to 16 addressable memory locations.
* **Accumulator (Reg A):** 8-bit general-purpose data register.
* **Program Memory (ROM):** 16x8-bit Distributed RAM containing hardcoded instructions.
* **Control Unit:** A Moore-style FSM driving a 4-stage execution pipeline:
  1. `ST_FETCH`: Latches the instruction from ROM.
  2. `ST_DECODE`: Combinatorially decodes the opcode.
  3. `ST_EXECUTE`: Triggers ALU operations or branching.
  4. `ST_WRITEBACK`: Cycles back to fetch.

## 📝 Instruction Set Architecture (ISA)
The CPU uses an 8-bit instruction word: the upper 4 bits are the **Opcode**, and the lower 4 bits are the **Immediate Operand**.

| Opcode (Binary) | Mnemonic | Description |
| :--- | :--- | :--- |
| `0001` | **LOAD** | Loads the 4-bit immediate value into the Accumulator. |
| `0010` | **ADD** | Adds the 4-bit immediate value to the Accumulator. |
| `0011` | **SUB** | Subtracts the 4-bit immediate value from the Accumulator. |
| `0100` | **JUMP** | Unconditionally sets the PC to the 4-bit immediate address. |

### Test Program Execution
The internal ROM is pre-loaded with a test program that creates an infinite loop:
1. `LOAD 5` (0001 0101) - Reg A becomes 5
2. `ADD 3`  (0010 0011) - Reg A becomes 8
3. `SUB 2`  (0011 0010) - Reg A becomes 6
4. `JUMP 1` (0100 0001) - PC jumps back to Address 1 (`ADD 3`)

## 📊 Synthesis Results
Synthesized using Xilinx ISE 14.7.
* **Target Device:** Xilinx Spartan-6 (`xc6slx9-2-csg324`)
* **Maximum Clock Frequency:** 173.400 MHz (Minimum period: 5.767ns)
* **Logic Utilization:**
  * Slice Registers (Flip-Flops): 47
  * Slice LUTs: 78
  * Distributed RAM: 1 (16x8-bit)

## 💻 Simulation Waveforms
The logic was verified using an ISim testbench simulating a 100ns reset followed by standard clock cycles. 
