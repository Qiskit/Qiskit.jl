# This code is part of Qiskit.
#
# (C) Copyright IBM 2025.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

import .C: qk_circuit_free, qk_circuit_num_qubits, qk_circuit_num_clbits, qk_circuit_num_instructions, qk_circuit_get_instruction, qk_circuit_count_ops, QkCircuit, QkGate, CircuitInstruction, QkDelayUnit, QkDelayUnit_S, QkDelayUnit_MS, QkDelayUnit_US, QkDelayUnit_NS, QkDelayUnit_PS
import .C: qk_circuit_gate, qk_circuit_measure, qk_circuit_reset, qk_circuit_barrier, qk_circuit_unitary, qk_circuit_delay, check_not_null
using .C

"""
    QuantumCircuit

Quantum circuit representation.

Available read-only properties:

- `num_qubits`
- `num_clbits`
- `num_instructions`
- `data` - contains instruction list

The additional properties are methods:

- `count_ops()` - returns a `Dict` of operation counts
- `reset(qubit)`
- `measure(qubit, clbit)`
- `barrier(qubit1, qubit2, ...)`
- `unitary(matrix, [qubit1, qubit2, ...])`
- many [standard gates](https://quantum.cloud.ibm.com/docs/en/api/qiskit/qiskit.circuit.QuantumCircuit#methods-to-add-standard-instructions) corresponding to Qiskit's Python API
- `delay(qubit, duration::Unitful.Time)` - insert a time delay on `qubit` with specified `duration`
"""
mutable struct QuantumCircuit
    ptr::Ptr{QkCircuit}
    offset::Int
    function QuantumCircuit(num_qubits::Integer = 0, num_clbits::Integer = 0; offset::Int = 1)
        num_qubits >= 0 || throw(ArgumentError("Number of qubits must be non-negative."))
        num_clbits >= 0 || throw(ArgumentError("Number of clbits must be non-negative."))
        qc = new(@ccall(libqiskit.qk_circuit_new(num_qubits::UInt32, num_clbits::UInt32)::Ptr{QkCircuit}), offset)
        # Take ownership; it's our job to free it eventually
        finalizer(qk_circuit_free, qc)
        qc
    end
    function QuantumCircuit(ptr::Ptr{QkCircuit}; offset::Int = 1)
        check_not_null(ptr)
        qc = new(ptr, offset)
        # Take ownership; it's our job to free it eventually
        finalizer(qk_circuit_free, qc)
        qc
    end
end

function qk_circuit_free(qc::QuantumCircuit)::Nothing
    if qc.ptr != C_NULL
        qk_circuit_free(qc.ptr)
        qc.ptr = C_NULL
    end
    nothing
end

function Base.copy(qc::QuantumCircuit)::QuantumCircuit
    check_not_null(qc.ptr)
    ptr = @ccall(libqiskit.qk_circuit_copy(qc.ptr::Ref{QkCircuit})::Ptr{QkCircuit})
    QuantumCircuit(ptr; offset=qc.offset)
end

qk_circuit_num_qubits(qc::QuantumCircuit)::Int = qk_circuit_num_qubits(qc.ptr)

qk_circuit_num_clbits(qc::QuantumCircuit)::Int = qk_circuit_num_clbits(qc.ptr)

qk_circuit_num_instructions(qc::QuantumCircuit)::Int = qk_circuit_num_instructions(qc.ptr)

qk_circuit_get_instruction(qc::QuantumCircuit, index::Integer)::CircuitInstruction =
    qk_circuit_get_instruction(qc.ptr, index; offset=qc.offset)

struct GateClosure{GATE}
    qc::QuantumCircuit
    num_qubits::Int32
    num_params::Int32
end

function (gc::GateClosure{GATE})(args...) where {GATE}
    _apply_gate(gc.qc, GATE, Int(gc.num_qubits), Int(gc.num_params), args)
end

# Canonical gate application, shared by the property-style closures and the
# `!`-suffixed functions in the `Operations` submodule. Arguments are ordered
# params-first, then qubits (matching Qiskit's Python signatures, e.g.
# `rz(theta, qubit)`).
function _apply_gate(qc::QuantumCircuit, gate, num_qubits::Int, num_params::Int, args)
    if length(args) != num_qubits + num_params
        throw(ArgumentError("Unexpected number of arguments for gate"))
    end
    params = collect(Float64, args[1:num_params])
    qubits = collect(Int32, args[num_params+1:end])
    qk_circuit_gate(qc, gate, qubits, params)
end

# Single source of truth for the standard gates: maps the Julia method name to
# its C enum value, qubit count, and parameter count. Both the property-style
# accessors (`qc.h`) and the `Operations.h!` functions are generated from this.
#
# The arities are hardcoded here (the C API has no way to query them) but are
# validated against the C library by a test that builds one instruction per
# gate and checks the resulting `QkCircuitInstruction` (see test/test_circuit.jl).
const GATE_TABLE = (
    (:h,     QkGate_H,      1, 0),
    (:id,    QkGate_I,      1, 0),
    (:x,     QkGate_X,      1, 0),
    (:y,     QkGate_Y,      1, 0),
    (:z,     QkGate_Z,      1, 0),
    (:p,     QkGate_Phase,  1, 1),
    (:r,     QkGate_R,      1, 2),
    (:rx,    QkGate_RX,     1, 1),
    (:ry,    QkGate_RY,     1, 1),
    (:rz,    QkGate_RZ,     1, 1),
    (:s,     QkGate_S,      1, 0),
    (:sdg,   QkGate_Sdg,    1, 0),
    (:sx,    QkGate_SX,     1, 0),
    (:sxdg,  QkGate_SXdg,   1, 0),
    (:t,     QkGate_T,      1, 0),
    (:tdg,   QkGate_Tdg,    1, 0),
    (:u,     QkGate_U,      1, 3),
    (:ch,    QkGate_CH,     2, 0),
    (:cx,    QkGate_CX,     2, 0),
    (:cy,    QkGate_CY,     2, 0),
    (:cz,    QkGate_CZ,     2, 0),
    (:dcx,   QkGate_DCX,    2, 0),
    (:ecr,   QkGate_ECR,    2, 0),
    (:swap,  QkGate_Swap,   2, 0),
    (:iswap, QkGate_ISwap,  2, 0),
    (:cp,    QkGate_CPhase, 2, 1),
    (:crx,   QkGate_CRX,    2, 1),
    (:cry,   QkGate_CRY,    2, 1),
    (:crz,   QkGate_CRZ,    2, 1),
    (:cs,    QkGate_CS,     2, 0),
    (:csdg,  QkGate_CSdg,   2, 0),
    (:csx,   QkGate_CSX,    2, 0),
    (:cu,    QkGate_CU,     2, 4),
    (:rxx,   QkGate_RXX,    2, 1),
    (:ryy,   QkGate_RYY,    2, 1),
    (:rzz,   QkGate_RZZ,    2, 1),
    (:rzx,   QkGate_RZX,    2, 1),
    (:ccx,   QkGate_CCX,    3, 0),
    (:ccz,   QkGate_CCZ,    3, 0),
    (:cswap, QkGate_CSwap,  3, 0),
    (:rccx,  QkGate_RCCX,   3, 0),
    (:rcccx, QkGate_RC3X,   4, 0),
)

# Compile-time dispatch from a gate symbol to its concrete `GateClosure`. When
# `sym` is a literal (the `qc.h` case), `Val(sym)` is a constant type and this
# resolves to a single concrete method, so the gate stays a type parameter and
# the lookup folds away at compile time — same optimization as a hardcoded
# `sym === :h` branch, but generated from `GATE_TABLE`.
for (name, gate, nq, np) in GATE_TABLE
    @eval _gate_closure(qc::QuantumCircuit, ::Val{$(QuoteNode(name))}) =
        GateClosure{$gate}(qc, $nq, $np)
end
_gate_closure(::QuantumCircuit, ::Val) = nothing  # not a gate symbol

# Generate the `!`-suffixed gate functions (e.g. `h!`, `cx!`, `rz!`) from the
# same table. These are the canonical idiomatic-Julia form; `qc.h(...)` builds a
# `GateClosure` that runs the identical `_apply_gate` path. Arguments are
# params-first, then qubits, matching the property-style call (`rz!(qc, θ, q)`).
for (name, gate, nq, np) in GATE_TABLE
    fname = Symbol(name, "!")
    @eval function $fname(qc::QuantumCircuit, args...)
        _apply_gate(qc, $gate, $nq, $np, args)
    end
end

# The one-off (non-gate) operations are implemented as the canonical `!`
# functions below, with the mutated `QuantumCircuit` as the first argument.
# These are the same functions exported (opt-in) by the `Operations` submodule;
# the property-style closures (`qc.reset(...)`) forward into them, so there is
# exactly one implementation per operation. The Unitful extension adds a
# `delay!` method rather than touching the closure.

"""
    reset!(qc::QuantumCircuit, qubit)

Append a reset of `qubit`. Mutates `qc`. Equivalent to `qc.reset(qubit)`.
"""
function reset!(qc::QuantumCircuit, qubit::Integer)::Nothing
    qk_circuit_reset(qc, qubit)
end

"""
    measure!(qc::QuantumCircuit, qubit, clbit)

Append a measurement of `qubit` into `clbit`. Mutates `qc`. Equivalent to
`qc.measure(qubit, clbit)`.
"""
function measure!(qc::QuantumCircuit, qubit::Integer, clbit::Integer)::Nothing
    qk_circuit_measure(qc, qubit, clbit)
end

"""
    barrier!(qc::QuantumCircuit, qubits...)

Append a barrier across `qubits` (or all qubits if none given). Mutates `qc`.
Equivalent to `qc.barrier(qubits...)`.
"""
function barrier!(qc::QuantumCircuit, qubits::Integer...)::Nothing
    if isempty(qubits)
        qubits_vector = collect(Int32, qc.offset:qc.num_qubits+qc.offset-1)
    else
        qubits_vector = collect(Int32, qubits)
    end
    qk_circuit_barrier(qc, qubits_vector)
end

"""
    unitary!(qc::QuantumCircuit, matrix, qubits; check_input=true)

Append a unitary `matrix` acting on `qubits`. Mutates `qc`. Equivalent to
`qc.unitary(matrix, qubits)`.
"""
function unitary!(qc::QuantumCircuit, matrix::AbstractMatrix{<:Number}, qubits::AbstractVector{<:Integer}; check_input::Bool = true)::Nothing
    qk_circuit_unitary(qc, matrix, qubits; check_input)
end

function unitary!(qc::QuantumCircuit, matrix::AbstractMatrix{<:Number}, qubits::Int...; check_input::Bool = true)::Nothing
    qk_circuit_unitary(qc, matrix, collect(qubits); check_input)
end

"""
    delay!(qc::QuantumCircuit, qubit, duration, unit)

Append a `delay` of `duration` (in `unit`) on `qubit`. Mutates `qc`. Equivalent
to `qc.delay(qubit, duration, unit)`. With Unitful loaded, `delay!(qc, qubit,
duration::Unitful.Time)` is also available.
"""
function delay!(qc::QuantumCircuit, qubit::Integer, duration::Real, unit::QkDelayUnit)::Nothing
    qk_circuit_delay(qc, qubit, duration, unit)
end

struct ResetInstructionClosure
    qc::QuantumCircuit
end

(cl::ResetInstructionClosure)(qubit::Integer)::Nothing = reset!(cl.qc, qubit)

struct MeasureInstructionClosure
    qc::QuantumCircuit
end

(cl::MeasureInstructionClosure)(qubit::Integer, clbit::Integer)::Nothing =
    measure!(cl.qc, qubit, clbit)

struct BarrierInstructionClosure
    qc::QuantumCircuit
end

(cl::BarrierInstructionClosure)(qubits::Integer...)::Nothing = barrier!(cl.qc, qubits...)

struct UnitaryInstructionClosure
    qc::QuantumCircuit
end

(cl::UnitaryInstructionClosure)(matrix::AbstractMatrix{<:Number}, qubits::AbstractVector{<:Integer}; check_input::Bool = true)::Nothing =
    unitary!(cl.qc, matrix, qubits; check_input)

(cl::UnitaryInstructionClosure)(matrix::AbstractMatrix{<:Number}, qubits::Int...; check_input::Bool = true)::Nothing =
    unitary!(cl.qc, matrix, qubits...; check_input)

struct DelayInstructionClosure
    qc::QuantumCircuit
end

(cl::DelayInstructionClosure)(qubit::Integer, duration::Real, unit::QkDelayUnit)::Nothing =
    delay!(cl.qc, qubit, duration, unit)

struct CountOpsClosure
    qc::QuantumCircuit
end

"""
    count_ops() -> Dict{String, Int}

Return operation counts for the circuit.

Each call to this function performs O(n) work to traverse the circuit.
If you need to access counts for multiple operations, store the result in a variable.
"""
function (cl::CountOpsClosure)()::Dict{String, Int}
    Dict(qk_circuit_count_ops(cl.qc))
end

struct QuantumCircuitData <: AbstractVector{CircuitInstruction}
    circuit::QuantumCircuit
end

Base.IndexStyle(::Type{QuantumCircuitData}) = IndexLinear()
Base.size(qcdata::QuantumCircuitData) = (qcdata.circuit.num_instructions,)
Base.firstindex(qcdata::QuantumCircuitData) = qcdata.circuit.offset
Base.lastindex(qcdata::QuantumCircuitData) = firstindex(qcdata) + qcdata.circuit.num_instructions - 1

function Base.getindex(qcdata::QuantumCircuitData, i::Integer)
    @boundscheck checkbounds(qcdata, i - qcdata.circuit.offset + 1)
    qk_circuit_get_instruction(qcdata.circuit, i)
end

function Base.iterate(qcdata::QuantumCircuitData)
    if isempty(qcdata)
        return nothing
    else
        i = firstindex(qcdata)
        return (qcdata[i], i + 1)
    end
end

function Base.iterate(qcdata::QuantumCircuitData, state)
    qc = qcdata.circuit
    if state >= qc.num_instructions + qc.offset
        return nothing
    else
        return (qcdata[state], state + 1)
    end
end

# Non-gate properties and pseudo-method accessors, kept as an explicit tuple so
# `propertynames` can advertise them. Gate names are appended from `GATE_TABLE`.
const _NONGATE_PROPERTIES =
    (:data, :num_qubits, :num_clbits, :num_instructions, :count_ops,
     :reset, :measure, :barrier, :delay, :unitary)

function Base.propertynames(obj::QuantumCircuit; private::Bool = false)
    union(fieldnames(typeof(obj)), _NONGATE_PROPERTIES, map(first, GATE_TABLE))
end

function Base.getproperty(qc::QuantumCircuit, sym::Symbol)
    if sym === :data
        return QuantumCircuitData(qc)
    elseif sym === :num_qubits
        return qk_circuit_num_qubits(qc)
    elseif sym === :num_clbits
        return qk_circuit_num_clbits(qc)
    elseif sym === :num_instructions
        return qk_circuit_num_instructions(qc)
    elseif sym === :count_ops
        return CountOpsClosure(qc)
    elseif sym === :reset
        return ResetInstructionClosure(qc)
    elseif sym === :measure
        return MeasureInstructionClosure(qc)
    elseif sym === :barrier
        return BarrierInstructionClosure(qc)
    elseif sym === :delay
        return DelayInstructionClosure(qc)
    elseif sym === :unitary
        return UnitaryInstructionClosure(qc)
    else
        gate = _gate_closure(qc, Val(sym))
        return gate === nothing ? getfield(qc, sym) : gate
    end
end

qk_circuit_gate(qc::QuantumCircuit, args...)::Nothing =
    qk_circuit_gate(qc.ptr, args...; offset=qc.offset)

qk_circuit_measure(qc::QuantumCircuit, qubit::Integer, clbit::Integer)::Nothing =
    qk_circuit_measure(qc.ptr, qubit, clbit; offset=qc.offset)

qk_circuit_reset(qc::QuantumCircuit, qubit::Integer)::Nothing =
    qk_circuit_reset(qc.ptr, qubit; offset=qc.offset)

qk_circuit_barrier(qc::QuantumCircuit, qubits)::Nothing =
    qk_circuit_barrier(qc.ptr, qubits; offset=qc.offset)

qk_circuit_unitary(qc::QuantumCircuit, matrix, qubits; check_input::Bool = true)::Nothing =
    qk_circuit_unitary(qc.ptr, matrix, qubits; check_input, offset=qc.offset)

qk_circuit_delay(qc::QuantumCircuit, args...) = qk_circuit_delay(qc.ptr, args...; offset=qc.offset)

qk_circuit_count_ops(qc::QuantumCircuit) = qk_circuit_count_ops(qc.ptr)

export QuantumCircuit, CircuitInstruction
@compat public QuantumCircuitData

"""
    Qiskit.Operations

Opt-in, idiomatic-Julia interface for building circuits. Every operation is a
`!`-suffixed function whose first argument is the `QuantumCircuit` it mutates:

```julia
using Qiskit
using Qiskit.Operations   # brings h!, cx!, measure!, reset!, ... into scope

qc = QuantumCircuit(2, 2)
h!(qc, 1)
cx!(qc, 1, 2)
measure!(qc, 1, 1)
measure!(qc, 2, 2)
```

These names are *not* re-exported from `Qiskit` itself — generic verbs like
`measure!` and `reset!` are kept behind this submodule so they only enter your
namespace if you ask for them. Each function is the same code path as the
corresponding property-style accessor (`qc.h(1)` ≡ `h!(qc, 1)`).
"""
module Operations

import ..Qiskit: reset!, measure!, barrier!, unitary!, delay!, GATE_TABLE

# Re-export the one-offs and every generated gate function from the parent.
export reset!, measure!, barrier!, unitary!, delay!
for (name, _, _, _) in GATE_TABLE
    fname = Symbol(name, "!")
    @eval import ..Qiskit: $fname
    @eval export $fname
end

end # module Operations
