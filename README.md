# Qiskit.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://qiskit.github.io/Qiskit.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://qiskit.github.io/Qiskit.jl/dev/)
[![Qiskit Ecosystem](https://qisk.it/e-50b8eb33)](https://qisk.it/ecosystem)
[![Build Status](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://coveralls.io/repos/github/Qiskit/Qiskit.jl/badge.svg?branch=main)](https://coveralls.io/github/Qiskit/Qiskit.jl?branch=main)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

This package contains a [Julia](https://julialang.org/) wrapper of the [Qiskit C API](https://docs.quantum.ibm.com/api/qiskit-c).

If Julia is already installed, then this package can be installed in one step, by typing `] add Qiskit` at the Julia REPL.

Supported operating systems: macOS and Linux.

## Recent news

- [Qiskit beyond Python: Fortran, C++, and Julia](https://www.ibm.com/quantum/blog/qiskit-beyond-python) introduces this package alongside the Fortran and C++ bindings, all of which share the Qiskit C API and its Rust core.
- [Simulate time evolution of the transverse-field Ising model](https://quantum.cloud.ibm.com/docs/tutorials/time-evolution) is the first Julia tutorial on the IBM Quantum Platform.  It builds Trotterized circuits, runs them on hardware, and compares against classical references, entirely in Julia.
- [QiskitOpt.jl](https://github.com/JuliaQUBO/QiskitOpt.jl), the [JuliaQUBO](https://github.com/JuliaQUBO) ecosystem's JuMP interface to Qiskit optimization algorithms, now builds on Qiskit.jl and QiskitIBMRuntime.jl instead of calling Python.  See its [v0.8.0 release notes](https://github.com/JuliaQUBO/QiskitOpt.jl/releases/tag/v0.8.0) ([announcement](https://www.linkedin.com/posts/bernalde_julialang-qiskit-quantumcomputing-share-7520311774940774400-Kjqj/)).

## Example

The following example generates a circuit that constructs a [Bell state](https://en.wikipedia.org/wiki/Bell_state), specifies a synthetic hardware device, and transpiles the circuit to run on that hardware device.  To transpile to and run on an actual hardware backend, see the [more succinct example](https://github.com/Qiskit/QiskitIBMRuntime.jl?tab=readme-ov-file#example) in the [QiskitIBMRuntime.jl](https://github.com/Qiskit/QiskitIBMRuntime.jl) README.

```julia
using Qiskit
using Qiskit.Operations

function build_bell()
    qc = QuantumCircuit(2, 2) # 2 qubits, 2 clbits
    h!(qc, 1)
    cx!(qc, 1, 2)
    measure!(qc, 1, 1)
    measure!(qc, 2, 2)
    qc
end

function build_chain_target(num_qubits)
    target = Qiskit.Target(num_qubits)

    # Add 1q basis gates
    for gate in (Qiskit.QkGate_X, Qiskit.QkGate_SX, Qiskit.QkGate_RZ)
        entry = Qiskit.target_entry_gate(gate)
        for i in 1:num_qubits
            error = 0.8e-6 * i
            duration = 1.8e-9 * i
            Qiskit.add_property!(entry, [i], duration, error)
        end
        Qiskit.add_instruction!(target, entry)
    end

    # Add 2q basis gate (ECR)
    ecr_entry = Qiskit.target_entry_gate(Qiskit.QkGate_ECR)
    for i in 1:num_qubits-1
        inst_error = 0.0090393 * (num_qubits - i + 1)
        inst_duration = 0.020039
        Qiskit.add_property!(ecr_entry, [i, i + 1], inst_duration, inst_error)
    end
    Qiskit.add_instruction!(target, ecr_entry)

    # Add measurement instruction
    meas_entry = Qiskit.target_entry_measure()
    for i in 1:num_qubits
        error = 0.0
        duration = 0.0
        Qiskit.add_property!(meas_entry, [i], duration, error)
    end
    Qiskit.add_instruction!(target, meas_entry)

    return target
end

qc = build_bell()
@show qc.num_instructions

target = build_chain_target(qc.num_qubits)

result = transpile(qc, target)
@show result.circuit.num_instructions
```

Operations are added to a `QuantumCircuit` using the `!`-suffixed functions in
`Qiskit.Operations`, which take the circuit as their first argument.  These
names are not exported from `Qiskit` itself — you opt in with `using
Qiskit.Operations` — because generic verbs such as `measure!` and `reset!`
should only enter your namespace if you ask for them.  They can also be
referenced fully-qualified, e.g. `Qiskit.h!`.  Most of Qiskit's [standard
instructions](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.circuit.QuantumCircuit#methods-to-add-standard-instructions)
are available.  A `QuantumCircuit` object also provides the following
properties: `num_qubits`, `num_clbits`, and `num_instructions`.

Qubits and clbits are indexed starting with one rather than zero, since that is
the norm in Julia.  This is a crucial difference from Qiskit's Python API.

Each operation is also available in a property-style form that mirrors Qiskit's
Python API, e.g. `qc.h(1)` appends the same instruction as `h!(qc, 1)`.
Following Julia convention, the `!` function returns `qc`, whereas the
property-style form returns `nothing`.

More usage examples can be found in the `test/` directory.

## Status

The following features of the Qiskit C API are supported by this wrapper:

- Construction and manipulation of a `QuantumCircuit`
- Construction and manipulation of a `Target`
- Transpilation, given a circuit and target

Currently only Linux and macOS are supported, on both x86_64 and aarch64 instruction set architectures.

## Installation instructions

### Install Julia

The official install instructions are at https://julialang.org/install/.

If you are a Rust user, you may choose to obtain `juliaup` via `cargo`.

```sh
cargo install juliaup
juliaup add release
```

### Install `Qiskit.jl`

#### Latest stable release

Type `] add Qiskit` in the Julia REPL, or run the following command:

```sh
julia -e 'using Pkg; pkg"add Qiskit"'
```

#### Development version

Type `] dev Qiskit` in the Julia REPL, or run the following command:

```sh
julia -e 'using Pkg; pkg"dev Qiskit"'
```

Afterward, the repository will be cloned to `~/.julia/dev/Qiskit`.

## Run tests

Type `] test Qiskit` in the Julia REPL, or run the following command:

```sh
julia -e 'using Pkg; Pkg.test("Qiskit")'
```

## Code formatting

This repository is formatted using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl), and CI checks that the code is formatted.  To format the code in place:

```sh
make format
```

The `format/` environment pins the JuliaFormatter version so that local runs and CI agree.

## License

Apache License 2.0
