# Pipelined-RISCV32I-2-bit-Prediction
This project implements a pipelined RISC-V 32I processor with an integrated 2-bit branch predictor to enhance instruction flow efficiency. The design follows a five-stage pipeline architecture (Fetch, Decode, Execute, Memory, Writeback) to improve instruction throughput.

The 2-bit branch prediction unit reduces branch misprediction penalties by maintaining a history-based prediction mechanism, improving control hazard handling. It employs a saturating counter to track branch behavior, allowing dynamic adaptation to program execution patterns.

Key features of the design include:

Five-stage pipelined architecture for efficient instruction execution.
2-bit branch predictor for reduced misprediction penalties.
Forwarding and hazard detection to minimize stalls.
Fully synthesizable SystemVerilog implementation.

This project aims to demonstrate the effectiveness of branch prediction in pipelined processors and provide an optimized hardware design for performance-critical applications.

![Pipeline_2_bit_predict](https://github.com/user-attachments/assets/122dc048-4ac0-4e1e-8513-9a53ae376d44)


