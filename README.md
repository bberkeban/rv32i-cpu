# RV32I RISC-V CPU Core

## Microarchitecture Specifications

* **ISA:** RISC-V 32-bit Base Integer Architecture (RV32I)
* **Execution Model:** Multi-Cycle FSM (Baseline) $\rightarrow$ 5-Stage In-Order Pipeline (Target)
* **Arithmetic Core:** Custom Radix-4 Carry-Lookahead Adder (`CLU.v`)
* **Memory Subsystem:** Split Harvard Architecture (Synchronous BRAM-compatible, Byte-addressable LSU)
* **Toolchain & EDA:** Yosys, Berkeley ABC, Icarus Verilog, SymbiYosys, GTKWave

## Repository Structure

```bash
rv32i/
├── src/                        # Synthesizable RTL source codes
├── verif/                      # Verification environment
│   ├── formal/                 # SystemVerilog assertions (SVA) and SymbiYosys (SBY) proof configurations
│   ├── sec/                    # Sequential Equivalence Checking (SEC) scripts and golden models
│   └── tb/                     # Simulation testbenches
└── scripts/                    # EDA automation scripts (Yosys and ABC flow)
```


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

- [x] **Phase 2: Submodule Formal Verification**
  - [x] ALU Formal Verification
  - [x] Register File Formal Verification
  - [x] Carry-Lookahead Unit Formal Verification
---
- [x] **Phase 3: ISA Validation (`riscv-tests`)**
  - [x] Setting up the official `riscv-tests` environment
  - [x] Running the basic `rv32ui-p-*` test suite
  - [x] Passed `rv32ui-p-*` tests
---
- [ ] **Phase 4: 5-Stage Pipelined Microarchitecture Implementation**
  - [ ] Pipeline stage registers
  - [ ] Hazard Detection Unit (load-use stalls)
  - [ ] Data Forwarding Unit 
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
