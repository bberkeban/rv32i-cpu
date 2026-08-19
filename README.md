# RV32I RISC-V CPU Core

## Microarchitecture Specifications

* **ISA:** RISC-V 32-bit Base Integer Architecture (RV32I)
* **Execution Model:** Multi-Cycle FSM (Baseline) $\rightarrow$ 5-Stage In-Order Pipeline (Target)
* **Arithmetic Core:** Custom Radix-4 Carry-Lookahead Adder (`CLU.v`)
* **Memory Subsystem:** Split Harvard Architecture (Synchronous BRAM-compatible, Byte-addressable LSU)
* **Toolchain & EDA:** Yosys, Berkeley ABC, Icarus Verilog, SymbiYosys, GTKWave

---

## Project Roadmap

---
- [x] **Phase 1: Multi-Cycle Datapath & Control Architecture**
  - [x] Radix-4 32-bit Carry-Lookahead Adder (`CLU.v`)
  - [x] Register File ($x0$ hardwired to zero, dual-read, single-write)
  - [x] Byte-addressable Load/Store Unit (`Load_Store_Unit.v`) with sign/zero extension
  - [x] Branch target generation and condition evaluation logic
  - [x] Multi-Cycle FSM Control Unit (`Control_Unit.v`)

---

- [ ] **Phase 2: Simulation & Integration Testing**
  - [ ] Top-level multi-cycle testbench using Icarus Verilog
  - [ ] Waveform verification and signal tracing with GTKWave
  - [ ] Testing basic instruction execution and corner cases (branch/jump offsets, memory access)
---
- [ ] **Phase 3: Architectural Compliance & ISA Validation (`riscv-tests`)**
  - [ ] Setting up the official `riscv-tests` environment
  - [ ] Running the basic `rv32ui-p-*` test suite
  - [ ] Pass/fail status monitoring via test signature (`gp` / `tohost`)
---
- [ ] **Phase 4: 5-Stage Pipelined Microarchitecture Implementation**
  - [ ] Pipeline stage registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`)
  - [ ] Hazard Detection Unit (load-use stalls)
  - [ ] Data Forwarding Unit (`EX $\rightarrow$ EX`, `MEM $\rightarrow$ EX`)
  - [ ] Branch handling and pipeline flush logic
---
- [ ] **Phase 5: Formal Verification via `riscv-formal` (RVFI)**
  - [ ] RVFI (RISC-V Formal Interface) integration
  - [ ] ISA compliance verification
  - [ ] Bounded Model Checking (BMC) using SMT solvers (Z3 / Yices2 / Boolector)
---
- [ ] **Phase 6: SystemVerilog Assertions (SVA)**
  - [ ] Assertions for pipeline hazards and forwarding paths
  - [ ] Memory/BRAM bus protocol verification
  - [ ] FSM reachability and state safety properties
---
- [ ] **Phase 7: L1 Cache Implementation (I-Cache & D-Cache)**
  - [ ] L1 Instruction Cache
  - [ ] L1 Data Cache
  - [ ] Cache controller and memory interface FSM
