# AGENTS.md

Guidance for AI agents and contributors working in this repository.

## What this package is

Qiskit.jl is a Julia wrapper around the [Qiskit C API](https://docs.quantum.ibm.com/api/qiskit-c).
The underlying C library is provided by the `Qiskit_jll` binary artifact. This package
exposes both a low-level C binding layer and a higher-level, Pythonic Julia interface.

A crucial convention: everything is **1-indexed**, not 0-indexed as in Python Qiskit,
because 1-based indexing is the Julia norm.

## Repository layout

- `lib/LibQiskit.jl` — **AUTO-GENERATED. Do not edit by hand.** This file is produced by
  the code in `gen/` (via Clang.jl) from the Qiskit C headers shipped in `Qiskit_jll`.
  Any manual change here will be lost the next time the bindings are regenerated.
- `gen/` — the binding generator. `gen/generator.jl` runs Clang.jl over the C headers
  to regenerate `lib/LibQiskit.jl`; `gen/generator.toml` holds the generator config
  (export prefixes `Qk`/`qk_`/`QISKIT_`, ignorelist, etc.); `gen/Project.toml` pins the
  generator's own deps (Clang, Qiskit_jll).
- `src/` — the hand-written Julia package.
  - `Qiskit.jl` — top-level module. Defines an inner `module C` that `include`s the
    generated `lib/LibQiskit.jl` plus the `c_*.jl` thin wrappers, then includes the
    high-level files.
  - `c_*.jl` (`c_circuit.jl`, `c_target.jl`, `c_transpile.jl`, `c_observable.jl`,
    `c_exit_code.jl`) — thin wrappers over the generated C bindings.
  - `circuit.jl`, `target.jl`, `transpile.jl`, `observable.jl` — the high-level,
    Pythonic Julia API (e.g. `QuantumCircuit`, `Target`, `transpile`).
- `test/` — test suite, entry point `test/runtests.jl`. Also a good source of usage examples.
- `ext/` — package extensions (e.g. `QiskitUnitfulExt` for `Unitful`).
- `docs/` — documentation source.
- `format/` — a self-contained environment that pins the exact `JuliaFormatter` version
  used to format this repo (see **Formatting** below). Like `gen/`, it has its own
  `Project.toml`/`Manifest.toml` and is invoked with `julia --project=format`.

## Regenerating the C bindings

When the `Qiskit_jll` version changes (or the C API changes), regenerate `lib/LibQiskit.jl`:

```sh
julia --project=gen -e 'import Pkg; Pkg.instantiate()'
julia --project=gen gen/generator.jl
```

Then review the diff and run the formatter and tests. Never edit `lib/LibQiskit.jl` directly.

## Running tests

```sh
julia --project=. -e 'import Pkg; Pkg.test()'
```

The test target also pulls in `Aqua` (quality checks) and `Unitful` (extension testing);
see `Project.toml` `[targets]`.

## Formatting

This repo uses [JuliaFormatter.jl](https://domluna.github.io/JuliaFormatter.jl/) per
`.JuliaFormatter.toml`. The exact formatter version is pinned in its own environment
under `format/` (so the result does not depend on whatever JuliaFormatter happens to be
in your global environment). Format before committing:

```sh
make format
```

which runs:

```sh
julia --project=format -e 'import Pkg; Pkg.instantiate(); using JuliaFormatter; format(".")'
```

Use `make format-check` in CI to fail (non-zero exit) when files are unformatted.

To bump the pinned version, edit the `[compat]` bound in `format/Project.toml`, then run
`julia --project=format -e 'import Pkg; Pkg.update()'` and commit the updated
`format/Manifest.toml`.

## Conventions

- **1-based indexing** everywhere in the public API (qubits, clbits, etc.).
- The high-level API mirrors Python Qiskit's `QuantumCircuit` method names where practical.
- Keep new code consistent with the existing style in the surrounding file.
- Supported platforms: Linux and macOS (x86_64 and aarch64).
