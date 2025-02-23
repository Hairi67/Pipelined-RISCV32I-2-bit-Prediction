# Pipelined-RISCV32I-2-bit-Prediction
This project implements a pipelined RISC-V 32I processor with an integrated 2-bit branch predictor to enhance instruction flow efficiency. The design follows a five-stage pipeline architecture (Fetch, Decode, Execute, Memory, Writeback) to improve instruction throughput.

The 2-bit branch prediction unit reduces branch misprediction penalties by maintaining a history-based prediction mechanism, improving control hazard handling. It employs a saturating counter to track branch behavior, allowing dynamic adaptation to program execution patterns.

Key features of the design include:

- Five-stage pipelined architecture for efficient instruction execution.

- 2-bit branch predictor for reduced misprediction penalties.

- Forwarding and hazard detection to minimize stalls.

- Fully synthesizable SystemVerilog implementation.

This project aims to demonstrate the effectiveness of branch prediction in pipelined processors and provide an optimized hardware design for performance-critical applications.

![Pipeline_2_bit_predict](https://github.com/user-attachments/assets/122dc048-4ac0-4e1e-8513-9a53ae376d44)

The block diagram above represents a pipelined RISC-V processor with a 2-bit branch predictor, showing different pipeline stages and key components involved in instruction execution. Below is a breakdown of its working flow:
1. Instruction Fetch (IF) Stage:

    - The Program Counter (PC) holds the address of the next instruction.
    - The Branch Predict Table is used to predict the next instruction address for branch handling. If a branch is predicted taken, the PC is updated accordingly; otherwise, it increments by 4.
    - The instruction is fetched from memory and stored in the IF/ID pipeline register for the next stage.

2. Instruction Decode (ID) Stage:

    - The Control Unit decodes the instruction to determine the required control signals.
    - The Register File (Reg_X) reads source registers (rs1 and rs2) and sends data to the execution stage.
    - Immediate values are generated using the Immediate Generator (imm Gen).
    - Hazard detection logic stalls the pipeline if dependencies are detected (e.g., load-use hazard).

3. Execute (EX) Stage:

    - ALU operations are performed based on control signals.
    - Forwarding logic (ForwardA and ForwardB) resolves data hazards by selecting the most recent data from MEM/WB stages instead of waiting for the register write-back.
    - The Branch Comparator (Br_Comp) checks if a branch condition is met, and the Branch Control (Br_control) determines if a misprediction occurred.
    - The computed result is stored in the EX/MEM pipeline register for the next stage.

4. Memory Access (MEM) Stage:

    - If it is a load/store instruction, the Load Store Unit (LSU) accesses memory.
    - The ALU result (or memory-loaded data) is stored in the MEM/WB pipeline register for the final stage.

5. Write-Back (WB) Stage:

    - The Write-Back Multiplexer selects either ALU result or memory-loaded data and writes it back to the Register File (Reg_X).

Branch Prediction & Hazard Handling:

  - If a branch is mis-predicted, the pipeline is flushed, and the correct PC is updated.
  - The Hazard Detection Unit ensures stalls are inserted if needed, preventing incorrect execution.
  - Forwarding logic helps mitigate data hazards by bypassing required values to the execution stage.

This pipelined processor efficiently handles instruction execution, resolving hazards using forwarding, stalling, and branch prediction to improve performance.
