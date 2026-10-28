# Elixir and Erlang training

Study exercises and examples from _Elixir in Action_ and Erlang practice.

## Folders

- [`erlang_traiining/`](./erlang_traiining/) contains the Erlang exercises.
- [`elixir_training/`](./elixir_training/) contains Elixir examples and Mix applications.

See each folder's README for details.

## Today's update (2026-10-28)

The Erlang training has been organized into numbered modules. The current
Module 4 lesson covers Erlang processes, message passing, registration, and
small concurrent services:

- `process.erl` starts an anonymous process with `spawn/1`.
- `worker.erl` starts exported functions with `spawn/3`, including passing
  arguments to `greet/1`.
- `bank.erl`, `wallet.erl`, and `payment_server.erl` model stateful processes
  that communicate through messages.
- `registry.erl` demonstrates registering and looking up processes.
- `payment_fraud_detect.erl` demonstrates a process used to inspect payments.
