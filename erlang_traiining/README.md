# Erlang training

This folder contains the Erlang training exercises:

- `Module1/` contains introductory Erlang modules and data-processing examples.
- `Module2/` contains functions, guards, recursion, conditions, and processor examples.
- `Module3/` contains maps, records, and binary-processing examples.
- `Module4/` contains process and worker examples.

The `.erl` files are the source code. Compiled `.beam` files and crash dumps are
local build/runtime artifacts and are ignored by Git.

## Today's lesson (2026-10-28)

Module 4 builds on process creation and message passing. For example,
`Module4/worker.erl` demonstrates `spawn/3`. Its third argument is a list of
arguments passed to the exported function named by the second argument:

```erlang
spawn(worker, start, []).
spawn(worker, greet, ["Jaefer"]).
```

The remaining examples cover receive loops, selective receive, process
registration, stateful bank and wallet processes, payment handling, and fraud
detection.
