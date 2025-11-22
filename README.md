# Qiskit.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://qiskit.github.io/Qiskit.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://qiskit.github.io/Qiskit.jl/dev/)
[![Build Status](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://coveralls.io/repos/github/Qiskit/Qiskit.jl/badge.svg?branch=main)](https://coveralls.io/github/Qiskit/Qiskit.jl?branch=main)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Julia wrapper of [Qiskit's C API](https://docs.quantum.ibm.com/api/qiskit-c)

## Example

```julia
using Qiskit
using Qiskit.C # lower-level C API functions

function build_bell()
    qc = QuantumCircuit(2, 2) # 2 qubits, 2 clbits
    qc.h(1)
    qc.cx(1, 2)
    qc.measure(1, 1)
    qc.measure(2, 2)
    qc
end

function build_chain_target(num_qubits)
    target = Qiskit.Target(num_qubits)

    # Add 1q basis gates
    for gate in (QkGate_X, QkGate_SX, QkGate_RZ)
        entry = Qiskit.target_entry_gate(gate)
        for i in 1:num_qubits
            error = 0.8e-6 * i
            duration = 1.8e-9 * i
            qk_target_entry_add_property(entry, [i], duration, error)
        end
        qk_target_add_instruction(target, entry)
    end

    # Add 2q basis gate (ECR)
    ecr_entry = Qiskit.target_entry_gate(QkGate_ECR)
    for i in 1:num_qubits-1
        inst_error = 0.0090393 * (num_qubits - i + 1)
        inst_duration = 0.020039
        qk_target_entry_add_property(ecr_entry, [i, i + 1], inst_duration, inst_error)
    end
    qk_target_add_instruction(target, ecr_entry)

    # Add measurement instruction
    meas_entry = Qiskit.target_entry_measure()
    for i in 1:num_qubits
        error = 0.0
        duration = 0.0
        qk_target_entry_add_property(meas_entry, [i], duration, error)
    end
    qk_target_add_instruction(target, meas_entry)

    return target
end

qc = build_bell()
@show qc.num_instructions

target = build_chain_target(qc.num_qubits)

result = transpile(qc, target)
@show result.circuit.num_instructions
```

The `QuantumCircuit` type provides a similar interface to Qiskit's Python API, including most [methods to add standard instructions](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.circuit.QuantumCircuit#methods-to-add-standard-instructions).  A `QuantumCircuit` object also provides the following properties: `num_qubits`, `num_clbits`, and `num_instructions`.

One crucial difference between this package and the Python API is that in this package, everything is indexed starting with one rather than zero, since that is the norm in Julia.

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

## License

Apache License 2.0
