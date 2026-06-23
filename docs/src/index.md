```@meta
CurrentModule = Qiskit
```

# Qiskit.jl

Documentation for [Qiskit.jl](https://github.com/Qiskit/Qiskit.jl).

The documentation of [Qiskit's C API](https://quantum.cloud.ibm.com/docs/en/api/qiskit-c) may also be useful to reference when using this library.

## Building circuits

Operations can be added to a [`QuantumCircuit`](@ref) in either of two
equivalent styles. The first mirrors Qiskit's Python API, using property-style
accessors on the circuit:

```julia
qc = QuantumCircuit(2, 2)
qc.h(1)
qc.cx(1, 2)
qc.measure(1, 1)
qc.measure(2, 2)
```

The second is the more idiomatic-Julia [`Qiskit.Operations`](@ref) interface, in
which each operation is a `!`-suffixed function taking the circuit as its first
argument:

```julia
using Qiskit.Operations

qc = QuantumCircuit(2, 2)
h!(qc, 1)
cx!(qc, 1, 2)
measure!(qc, 1, 1)
measure!(qc, 2, 2)
```

`h!(qc, 1)` and `qc.h(1)` append the same instruction; following Julia
convention, the `!` function returns `qc` whereas the property-style form
returns `nothing`. The `Operations` names are not exported from `Qiskit` itself
— you opt in with `using Qiskit.Operations` — so generic verbs such as
`measure!` and `reset!` only enter your namespace if you ask for them. They can
also be referenced fully-qualified, e.g. `Qiskit.h!`.

Indexing of qubits and clbits starts at one rather than zero, following Julia
convention.

## API Reference

```@index
```

```@autodocs
Modules = [Qiskit, Qiskit.Operations]
```
