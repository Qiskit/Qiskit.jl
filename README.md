# Qiskit.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://qiskit.github.io/Qiskit.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://qiskit.github.io/Qiskit.jl/dev/)
[![Build Status](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Qiskit/Qiskit.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://coveralls.io/repos/github.com/Qiskit/Qiskit.jl/badge.svg?branch=main)](https://coveralls.io/github.com/Qiskit/Qiskit.jl?branch=main)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/Q/Qiskit.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

Julia wrapper of [Qiskit's C API](https://docs.quantum.ibm.com/api/qiskit-c)

## Example

```julia
using Qiskit

function build_bell()
    qc = QuantumCircuit(2, 2)
    qc.h(1)
    qc.cx(1, 2)
    qc.measure(1, 1)
    qc.measure(2, 2)
    qc
end
```

More usage examples can be found in the `test/` directory.

## Status

- Partial support for `SparseObservable`
- Nearly complete support for circuits
- Nearly complete support for targets

Currently the only supported platform is Linux x86_64.  Support for other platforms may be added by improving the [Yggdrasil build script for Qiskit](https://github.com/JuliaPackaging/Yggdrasil/blob/master/Q/Qiskit/build_tarballs.jl).

## Installation instructions

### Install Julia

The official install instructions are at https://julialang.org/install/.

If you are a Rust user, you may choose to obtain `juliaup` via `cargo`.

```sh
cargo install juliaup
juliaup add release
```

### Clone this repository

```sh
git clone git@github.com:Qiskit/Qiskit.jl.git
cd Qiskit.jl
```

### Install `Qiskit.jl`

```sh
julia -e 'using Pkg; pkg"dev ."'
```

## Run tests

```sh
julia -e 'using Pkg; Pkg.test("Qiskit")'
```

## License

Apache License 2.0
