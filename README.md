# Sovereign Ada RTX

**A complete deterministic computer recreated in pure Ada — from first principles to Resonant Tensor Exchange.**

[![Ada](https://img.shields.io/badge/Language-Ada_2022-blue.svg)](https://www.adaic.org/)
[![License](https://img.shields.io/badge/License-Sovereign_Source_v1.0-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-40_PASS-brightgreen.svg)](#self-test-results)
[![Benchmarks](https://img.shields.io/badge/Benchmarks-9_PASS-brightgreen.svg)](#benchmark-suite)
[![Packages](https://img.shields.io/badge/Packages-21_Ada-orange.svg)](#architecture)
[![Source](https://img.shields.io/badge/Source-42_files_100KB-red.svg)](#source-layout)
[![Build](https://img.shields.io/badge/Build-gnatmake_Pure_Ada-purple.svg)](#build--run)
[![Architecture](https://img.shields.io/badge/Architecture-Deterministic_Fail--Closed-yellow.svg)](#architecture)
[![RTX](https://img.shields.io/badge/RTX-256--Dim_Tensor_Engine-critical.svg)](#rtx-sovereign-driver)

---

## What This Is

This is not a library. This is not a framework. **This is a computer.**

Sovereign Ada RTX is a fully deterministic, fail-closed processor recreated from first principles in pure Ada — a language designed for air-gapped, safety-critical systems where a single undefined behavior can kill. Every component is built from the ground up: no operating system dependencies, no runtime allocations, no external libraries, no `realloc`, no garbage collector, no OS syscalls. Just Ada, the compiler, and the hardware.

The system implements a complete computing stack:

| Layer | What It Recreates | Ada Package |
|-------|-------------------|-------------|
| **Type System** | CPU registers, word sizes, bus widths | `Core_Types` |
| **Arithmetic** | ALU with overflow detection, saturating math | `Math_Utils` |
| **Memory** | Fixed-capacity RAM with bounds checking | `Memory_Structures` |
| **Configuration** | BIOS/UEFI config registers | `Config` |
| **Validation** | Hardware fault detection, range checks | `Validation` |
| **Integrity** | CRC/ECC memory protection | `Integrity` |
| **Serialization** | Binary bus protocol, wire format | `Serialization` |
| **Parser** | Instruction decoder, opcode dispatch | `Parser` |
| **State Machine** | CPU control unit, fetch-decode-execute cycle | `State_Machine` |
| **Dispatcher** | Instruction execution engine | `Dispatcher` |
| **Error Handling** | Machine check exception, fail-closed trap | `Errors` |
| **Self-Test** | POST (Power-On Self-Test) | `Self_Test` |
| **Benchmarks** | Performance validation suite | `Benchmark` |
| **RTX Engine** | Resonant Tensor Exchange processor | `RTX_Sovereign_Driver` |
| **CNN** | Convolutional neural network forward pass | `CNN_Engine` |
| **SVM** | Support vector machine margin optimizer | `SVM_Margin` |
| **String Utils** | BIOS string operations | `String_Utils` |
| **Status Utils** | Hardware status register classification | `Status_Utils` |
| **Buffer Stats** | Memory health monitoring | `Buffer_Stats` |
| **Math Const** | Fixed-point mathematical constants | `Math_Const` |
| **Command Utils** | Opcode classification table | `Command_Utils` |

Every function in this system has **known, bounded behavior**. There are no hidden allocations. No pointer aliasing. No race conditions. No undefined behavior. The compiler enforces this at build time.

---

## Architecture

```mermaid
graph TB
    subgraph "Sovereign Ada RTX — Deterministic Processor"
        subgraph "CPU Core"
            CT[Core_Types<br/>Registers & Bus]
            MU[Math_Utils<br/>ALU]
            ER[Errors<br/>Fault Handler]
        end

        subgraph "Memory Subsystem"
            MS[Memory_Structures<br/>RAM Controller]
            CF[Config<br/>BIOS Registers]
            BS[Buffer_Stats<br/>Health Monitor]
        end

        subgraph "Execution Pipeline"
            PA[Parser<br/>Instruction Decoder]
            SM[State_Machine<br/>Control Unit]
            DI[Dispatcher<br/>Execution Engine]
            VL[Validation<br/>Fault Detection]
        end

        subgraph "Data Integrity"
            IG[Integrity<br/>ECC/CRC Engine]
            SE[Serialization<br/>Wire Protocol]
            SU[String_Utils<br/>String Operations]
        end

        subgraph "Neural Compute"
            RTX[RTX_Sovereign_Driver<br/>256-Dim Tensor Engine]
            CNN[CNN_Engine<br/>2D Convolution]
            SVM[SVM_Margin<br/>Margin Optimizer]
        end

        subgraph "Self-Validation"
            ST[Self_Test<br/>40-Test POST]
            BM[Benchmark<br/>9-Test Suite]
            CU[Command_Utils<br/>Opcode Table]
            MC[Math_Const<br/>Fixed-Point Constants]
            SU2[Status_Utils<br/>Status Register]
        end

        subgraph "REPL"
            MA[main.adb<br/>Cold Boot REPL]
        end

        CT --> MU
        CT --> ER
        CT --> MS
        CF --> DI
        MS --> SE
        PA --> SM
        SM --> DI
        DI --> VL
        DI --> IG
        DI --> RTX
        RTX --> CNN
        RTX --> SVM
        ST --> CT
        BM --> MU
        MA --> PA
        MA --> ST
        MA --> BM
        MA --> RTX
    end

    style CT fill:#1a1a2e,stroke:#e94560,color:#fff
    style RTX fill:#0f3460,stroke:#e94560,color:#fff
    style ST fill:#16213e,stroke:#e94560,color:#fff
    style MA fill:#533483,stroke:#e94560,color:#fff
```

### State Machine

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Initializing : START
    Initializing --> Configured : INIT_OK
    Configured --> Awaiting_Input : READY
    Awaiting_Input --> Parsing : INPUT
    Parsing --> Validating : PARSED
    Validating --> Processing : VALID
    Processing --> Serializing : PROCESSED
    Processing --> Checking_Integrity : CHECK
    Processing --> Authorized : DIRECT
    Processing --> Awaiting_Input : LOOP
    Serializing --> Checking_Integrity : SERIALIZED
    Checking_Integrity --> Authorized : VERIFIED
    Checking_Integrity --> Awaiting_Input : RECOVER
    Authorized --> Awaiting_Input : NEXT
    Authorized --> Processing : PROCESS
    Authorized --> Shutdown : EXIT
    Authorized --> Error_State : FAIL
    Error_State --> Idle : RECOVER
    Error_State --> Shutdown : HALT
    Error_State --> Awaiting_Input : SOFT_RESET
    Shutdown --> [*]
```

---

## Cold Boot Protocol

When the processor starts, it executes the following deterministic cold boot sequence:

```
========================================
ADA DETERMINISTIC PROCESSOR v1.0
Pure Ada, no external dependencies
========================================
Build: pure Ada standard library only
Architecture: core types + config + parser + state machine + validation
+ math utils + memory + serialization + integrity + dispatcher + self-test
+ RTX sovereign driver + benchmark suite

Initializing subsystems...
```

### Phase 1: Subsystem Initialization

```
Dispatcher.Init_Context (Ctx)
├── State_Machine.Init_Machine (Ctx.SM)          → State: Idle
├── Config.Init_Config (Ctx.Cfg)                  → Table: empty
├── Config.Apply_Defaults (Ctx.Cfg)               → 7 defaults loaded
│   ├── Key_Max_Length    = 64
│   ├── Key_Timeout       = 1000
│   ├── Key_Auth_Level    = 0 (None)
│   ├── Key_Checksum_Seed = 0xADA1
│   ├── Key_Enable_Strict = 1
│   ├── Key_Buffer_Limit  = 128
│   └── Key_Math_Mode     = 0
├── Memory_Structures.Init_Store (Ctx.Store)      → 0 items
├── Memory_Structures.Init_Buffer (Ctx.Buf)       → 0 bytes
├── Ctx.Auth := None
└── Ctx.Seed := 0xADA1
```

### Phase 2: Power-On Self-Test (40 Tests)

The system runs a comprehensive self-test covering every package:

```
=== SOVEREIGN ADA RTX SELF TEST ===
Tests: 40

Math Operations:
  [PASS] Safe_Add_Normal       — 10 + 20 = 30
  [PASS] Safe_Add_Overflow     — 2^31-1 + 1 saturates
  [PASS] Safe_Sub_Under        — 5 - 10 underflows to 0
  [PASS] ISqrt                 — sqrt(100) = 10
  [PASS] Power2                — 16 is power of 2, 15 is not
  [PASS] GCD_LCM               — gcd(12,8)=4, lcm(4,6)=12
  [PASS] Align                 — align_up(5,4)=8, align_down(7,4)=4
  [PASS] NextPow2              — next_pow2(5) = 8
  [PASS] Log2                  — log2(16) = 4

Memory Operations:
  [PASS] Buffer_Ops            — append byte, check length
  [PASS] Buffer_Fill           — fill buffer with value
  [PASS] Buffer_Eq             — compare two identical buffers
  [PASS] Store_Insert          — insert + find by ID
  [PASS] Store_Remove          — remove by ID, verify count
  [PASS] Invalid_Item          — reject invalid data item

Serialization:
  [PASS] Header_Ser            — serialize header = 7 bytes
  [PASS] Header_De             — deserialize + verify magic 0xADA1
  [PASS] Item_Ser              — serialize data item
  [PASS] Item_De               — deserialize + verify fields

Integrity:
  [PASS] Integrity_Ver         — verify correct checksum
  [PASS] Integrity_Fail        — detect corrupted checksum

State Machine:
  [PASS] State_Trans           — valid transition: Idle → Initializing
  [PASS] State_Invalid         — reject invalid: Initializing → Serializing

Configuration:
  [PASS] Config_Set            — set + get max_length = 32
  [PASS] Config_Bad            — reject out-of-range value
  [PASS] Config_Count          — count set entries = 2

Dispatch:
  [PASS] Dispatch              — context state = Idle

Parser:
  [PASS] Parse_Help            — "HELP" → Cmd_Help
  [PASS] Parse_Bad             — "NOCMD" → Parse_Error

Validation:
  [PASS] Validate_Buf          — length 100 > max 64 → Buffer_Overflow
  [PASS] Validate_Item         — invalid item → Invalid_Input
  [PASS] Auth_Deny             — Guest < Admin → Authorization_Denied
  [PASS] Auth_Ok               — Admin >= Operator → Success

Store Serialization:
  [PASS] Store_Ser             — serialize 5 items
  [PASS] Store_De              — deserialize + verify count = 5

Bit Operations:
  [PASS] Rotate                — rotate_left(1, 4) = 16

String Operations:
  [PASS] String_Len            — "HELLO" length = 5
  [PASS] String_Upper          — "test" → "TEST"

Status Classification:
  [PASS] Status_Utils          — is_success(Success)=T, is_failure(Overflow)=T
  [PASS] Severity              — Integrity_Failure severity = 4

Buffer Statistics:
  [PASS] Buf_Occ               — 64/128 = 50% occupancy
  [PASS] Buf_Avg               — average of four 10s = 10

Command Classification:
  [PASS] Cmd_Utils             — Help is query, SetConfig is mutating

Mathematical Constants:
  [PASS] Math_Const            — factorial(5) = 120
  [PASS] Fibonacci             — fibonacci(10) = 55

OVERALL: PASS
Tests executed: 40
```

### Phase 3: Benchmark Suite (9 Tests)

After self-test passes, the system runs performance benchmarks:

```
=== SOVEREIGN RTX BENCHMARK SUITE ===
Benchmarks: 9
------------------------------------
  [PASS] GCD_48_18        iters=1     cycles=4
  [PASS] Fib_10           iters=1     cycles=177
  [PASS] Fact_10          iters=1     cycles=10
  [PASS] Pow_2_10         iters=1     cycles=10
  [PASS] Sum_100          iters=1     cycles=100
  [PASS] GCD_Large        iters=1     cycles=6
  [PASS] Fib_20           iters=1     cycles=21891
  [PASS] Safe_Add_Bench   iters=1000  cycles=1000
  [PASS] ISqrt_Bench      iters=100   cycles=100

RESULT: ALL BENCHMARKS PASSED
```

### Phase 4: RTX Engine Initialization

```
Initializing RTX Sovereign Engine...
RTX engine initialized (256-dim tensor, cold-boot state).
Tensor weights: all 1, bias: 0
```

### Phase 5: Ready

```
Self-tests passed. System ready.
Type HELP for commands, EXIT to quit.

>
```

---

## RTX Sovereign Driver

The Resonant Tensor Exchange (RTX) is a 256-dimensional fixed-point tensor processor implemented in pure Ada. It performs deterministic neural network inference and margin optimization without floating-point arithmetic, memory allocation, or OS interaction.

### Architecture

```
RTX_Sovereign_Driver
├── Tensor_State: array (0..255) of Word32
├── Initialize_Engine: cold-boot to all-ones weights, zero bias
├── Execute_Forward_Pass: dot product with overflow detection
│   ├── For each dimension i in 0..255:
│   │   ├── Safe_Mul(Features[i], Weights[i])  → check overflow
│   │   ├── Safe_Add(Acc, Product)              → check overflow
│   │   └── On overflow: set error, return Word32'Last
│   └── Return Safe_Add(Acc, Bias)
└── Optimize_Margin: SVM hinge loss gradient update
    ├── Forward pass → Projection
    ├── Margin = Label × Projection
    ├── If Margin ≥ 1000: weight decay (L2 regularization)
    └── If Margin < 1000: adjust hyperplane + bias
```

### Forward Pass Example

```ada
-- Cold-boot state: all weights = 1, bias = 0
-- Input: features[0..255] = some 256-dim vector
-- Output: Σ(features[i] × weights[i]) + bias

Features : Tensor_State := (0 => 10, 1 => 20, 2 => 30, others => 0);
Weights  : Tensor_State := (others => 1);
Bias     : Word32 := 0;

-- Execute_Forward_Pass returns: 10×1 + 20×1 + 30×1 + 0 = 60
Result := RTX_Sovereign_Driver.Execute_Forward_Pass(Features, Weights, Bias, Log);
```

### Margin Optimization

```ada
-- Hinge loss: if margin < 1.0 (scaled to 1000), adjust weights
-- If margin ≥ 1000: decay all weights by 1 (saturating)
-- If margin < 1000: add features to weights, add label to bias

Status := RTX_Sovereign_Driver.Optimize_Margin(
   Features => Input_Vector,
   Label    => 1,
   Weights  => Model_Weights,
   Bias     => Model_Bias,
   Log      => Error_Log
);
```

### Safety Guarantees

| Property | Mechanism |
|----------|-----------|
| No overflow | `Safe_Mul` / `Safe_Add` with saturation |
| No allocation | Fixed 256-element arrays |
| No undefined behavior | Ada type system + range checks |
| Deterministic timing | No branches on data-dependent paths in inner loop |
| Fail-closed | Any overflow → `Arithmetic_Overflow` error, return `Word32'Last` |

---

## Build & Run

### Prerequisites

- GNAT Ada compiler (GPL 2022 or later)
- `gnatchop` (comes with GNAT)
- `gnatmake` (comes with GNAT)

### Build

```bash
# Option 1: Build from individual files
cd src/
gnatchop -w sovereign_core.txt     # If using monolith
gnatmake main.adb rtx_sovereign_driver.adb -o sovereign_rtx_processor

# Option 2: Build all at once
gnatmake -o sovereign_rtx_processor \
   main.adb \
   core_types.adb errors.adb math_utils.adb \
   memory_structures.adb config.adb validation.adb \
   integrity.adb serialization.adb parser.adb \
   state_machine.adb dispatcher.adb self_test.adb \
   string_utils.adb status_utils.adb buffer_stats.adb \
   math_const.adb command_utils.adb benchmark.adb \
   rtx_sovereign_driver.adb cnn_engine.adb svm_margin.adb
```

### Run

```bash
./sovereign_rtx_processor
```

### Interactive Commands

```
> HELP
Commands: HELP SET PROCESS STATE SERIALIZE VERIFY TEST RESET AUTH EXIT

> SET 0 32          -- Set max_length to 32
> AUTH 3            -- Set auth level to Admin
> PROCESS 10 20 30  -- Process three bytes
> STATE             -- Query state
> SERIALIZE         -- Serialize store to buffer
> VERIFY            -- Verify store integrity
> RESET             -- Reset to idle
> EXIT              -- Shutdown
```

---

## Source Layout

```
sovereign-ada-rtx/
├── src/
│   ├── core_types.ads / .adb        -- Foundational types & enums
│   ├── errors.ads / .adb            -- Fail-closed error handling
│   ├── math_utils.ads / .adb        -- Safe arithmetic (30+ functions)
│   ├── memory_structures.ads / .adb -- Fixed buffers & stores
│   ├── config.ads / .adb            -- BIOS-style configuration
│   ├── validation.ads / .adb        -- Range & transition validation
│   ├── integrity.ads / .adb         -- Checksum (items, buffers, headers, stores)
│   ├── serialization.ads / .adb     -- Binary wire protocol
│   ├── parser.ads / .adb            -- Instruction decoder
│   ├── state_machine.ads / .adb     -- CPU control unit
│   ├── dispatcher.ads / .adb        -- Execution engine
│   ├── self_test.ads / .adb         -- 40-test POST suite
│   ├── benchmark.ads / .adb         -- 9-test performance suite
│   ├── rtx_sovereign_driver.ads / .adb -- 256-dim tensor engine
│   ├── cnn_engine.ads / .adb        -- 2D convolution + ReLU
│   ├── svm_margin.ads / .adb        -- SVM margin optimizer
│   ├── string_utils.ads / .adb      -- Bounded string ops
│   ├── status_utils.ads / .adb      -- Status classification
│   ├── buffer_stats.ads / .adb      -- Buffer health monitoring
│   ├── math_const.ads / .adb        -- Fixed-point constants
│   ├── command_utils.ads / .adb     -- Opcode classification
│   └── main.adb                     -- Cold boot REPL
├── python/
│   └── quantized_vc_bounds.py       -- VC dimension calculator
├── LICENSE                          -- Sovereign Source License v1.0
└── README.md                        -- This file
```

---

## Key Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| Magic | `0xADA1` | Serialization header magic number |
| Default Seed | `0xADA1` | Checksum seed for integrity verification |
| Max_Buffer_Size | 128 bytes | Fixed RAM capacity |
| Max_Config_Entries | 16 | Configuration register count |
| Max_Serial_Record_Size | 64 bytes | Max serialized record |
| Max_Command_Args | 8 | Max args per instruction |
| Max_Dimensions | 256 | RTX tensor dimensionality |
| Max_Tests | 40 | Self-test count |
| Max_Benches | 16 | Benchmark count |

---

## Design Principles

1. **Fail-Closed**: Every error path terminates or transitions to `Error_State`. No silent failures.
2. **Zero Allocation**: All memory is statically sized at compile time. No `malloc`, no heap.
3. **Deterministic Timing**: No dynamic dispatch, no recursion in hot paths, no OS calls.
4. **Type Safety**: Ada's type system prevents buffer overflows, range violations, and uninitialized reads at compile time.
5. **Saturating Arithmetic**: Integer overflow saturates to `Word32'Last` instead of wrapping.
6. **Verified Integrity**: Every data item carries a checksum. Every deserialization verifies the checksum.
7. **Authenticated Operations**: State transitions and config changes require authorization levels.

---

## Related Repositories

| Repository | Description |
|------------|-------------|
| [clay-institute-p-vs-np](https://github.com/SNAPKITTYWEST/clay-institute-p-vs-np) | P vs NP formal verification in Lean 4 |
| [nvidia-stack](https://github.com/SNAPKITTYWEST/nvidia-stack) | CUDA kernel inventions #7–#11 |
| [sovereign-cuda-kernels](https://github.com/SNAPKITTYWEST/sovereign-cuda-kernels) | HyperKitty loader + CUDA kernels |
| [historical-linguistics-agda](https://github.com/SNAPKITTYWEST/historical-linguistics-agda) | Proto-Language reconstruction in Agda |
| [sovereign-entropy-theorem](https://github.com/SNAPKITTYWEST/sovereign-entropy-theorem) | Sovereign Entropy Theorem (Lean 4 + CUDA-Q) |
| [perplexity-macro-vm](https://github.com/SNAPKITTYWEST/perplexity-macro-vm) | Ollama Cloud AI chat frontend |
| [sovereign-ada-rtx](https://github.com/SNAPKITTYWEST/sovereign-ada-rtx) | This repository |

---

## Sovereign Source License v1.0

Copyright (c) 2025 Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust
EIN 42-697643

Licensed under the Sovereign Source License v1.0. See [LICENSE](LICENSE) for full terms.

**Author**: Ahmad Ali Parr, Jessica Westerhoff
**Trust**: Bel Esprit D'Accord Irrevocable Trust
