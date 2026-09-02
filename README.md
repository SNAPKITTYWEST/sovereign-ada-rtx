# Sovereign Ada RTX

Deterministic Ada runtime with fail-closed error handling.

## Architecture

```
Core_Types        -- Foundational types, status codes, data structures
Errors            -- Error logging with context (code, hint, message)
Math_Utils        -- Safe arithmetic, checksums (Simple, Fletcher16), bit ops
Memory_Structures -- Fixed-capacity buffers and data stores
Config            -- Key-value configuration with validation
Validation        -- Range checks, state transition rules, auth gates
Integrity         -- Checksum computation and verification for items/buffers/headers/stores
Serialization     -- Binary serialize/deserialize for headers, items, stores
Parser            -- Command-line parser with tokenization and argument extraction
State_Machine     -- Finite state machine with validated transitions
Dispatcher        -- Command dispatch with auth enforcement and state management
Self_Test         -- 30-test verification suite covering all packages
```

## State Machine

```
Idle -> Initializing -> Configured -> Awaiting_Input -> Parsing -> Validating
  -> Processing -> Serializing -> Checking_Integrity -> Authorized
  -> Awaiting_Input (loop)
  -> Error_State -> Idle (recovery)
  -> Shutdown (terminal)
```

## Commands

| Command | Args | Auth | Description |
|---------|------|------|-------------|
| HELP | -- | -- | List commands |
| SET | key value | Operator | Set config entry |
| PROCESS | bytes... | -- | Process data into store |
| STATE | -- | -- | Query current state |
| SERIALIZE | -- | -- | Serialize store to buffer |
| VERIFY | -- | -- | Verify store integrity |
| TEST | -- | -- | Run self-test suite |
| RESET | -- | -- | Reset to idle |
| AUTH | level | -- | Set auth level (0=None,1=Guest,2=Operator,3=Admin) |
| EXIT | -- | -- | Shutdown |

## Constants

- Magic: `0xADA1`
- Default seed: `0xADA1`
- Max buffer: 128 bytes
- Max config entries: 16
- Max serial record: 64 bytes
- Max command args: 8

## Sovereign Source License v1.0

Copyright (c) 2025 Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust

Licensed under the Sovereign Source License v1.0. See [LICENSE](LICENSE) for terms.
