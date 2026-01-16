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

import .C: qk_circuit_free, qk_circuit_num_qubits, qk_circuit_num_clbits, qk_circuit_num_instructions, qk_circuit_get_instruction, qk_circuit_count_ops, QkCircuit, QkGate, CircuitInstruction
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

- `reset(qubit)`
- `measure(qubit, clbit)`
- `barrier(qubit1, qubit2, ...)`
- `unitary(matrix, [qubit1, qubit2, ...])`
- many standard gates corresponding to Qiskit's Python API
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
    if length(args) != gc.num_qubits + gc.num_params
        throw(ArgumentError("Unexpected number of arguments for gate"))
    end
    params = collect(Float64, args[1:gc.num_params])
    qubits = collect(Int32, args[gc.num_params+1:end])
    qk_circuit_gate(gc.qc, GATE, qubits, params)
end

struct ResetInstructionClosure
    qc::QuantumCircuit
end

function (cl::ResetInstructionClosure)(qubit::Integer)::Nothing
    qk_circuit_reset(cl.qc, qubit)
end

struct MeasureInstructionClosure
    qc::QuantumCircuit
end

function (cl::MeasureInstructionClosure)(qubit::Integer, clbit::Integer)::Nothing
    qk_circuit_measure(cl.qc, qubit, clbit)
end

struct BarrierInstructionClosure
    qc::QuantumCircuit
end

function (cl::BarrierInstructionClosure)(qubits::Integer...)::Nothing
    qc = cl.qc
    if isempty(qubits)
        qubits_vector = collect(Int32, qc.offset:qc.num_qubits+qc.offset-1)
    else
        qubits_vector = collect(Int32, qubits)
    end
    qk_circuit_barrier(qc, qubits_vector)
end

struct UnitaryInstructionClosure
    qc::QuantumCircuit
end

function (cl::UnitaryInstructionClosure)(matrix::AbstractMatrix{<:Number}, qubits::AbstractVector{<:Integer})::Nothing
    qk_circuit_unitary(cl.qc, matrix, qubits)
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

function Base.propertynames(obj::QuantumCircuit; private::Bool = false)
    union(fieldnames(typeof(obj)), (:data, :num_qubits, :num_clbits, :num_instructions, :reset, :measure, :barrier, :unitary, :h, :id, :x, :y, :z, :p, :r, :rx, :ry, :rz, :s, :sdg, :sx, :sxdg, :t, :tdg, :u, :ch, :cx, :cy, :cz, :dcx, :ecr, :swap, :iswap, :cp, :crx, :cry, :crz, :cs, :csdg, :csx, :cu, :rxx, :ryy, :rzz, :rzx, :ccx, :ccz, :cswap, :rccx, :unitary, :rcccx))
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
    elseif sym === :reset
        return ResetInstructionClosure(qc)
    elseif sym === :measure
        return MeasureInstructionClosure(qc)
    elseif sym === :barrier
        return BarrierInstructionClosure(qc)
    elseif sym === :unitary
        return UnitaryInstructionClosure(qc)
    elseif sym === :h
        return GateClosure{QkGate_H}(qc, 1, 0)
    elseif sym === :id
        return GateClosure{QkGate_I}(qc, 1, 0)
    elseif sym === :x
        return GateClosure{QkGate_X}(qc, 1, 0)
    elseif sym === :y
        return GateClosure{QkGate_Y}(qc, 1, 0)
    elseif sym === :z
        return GateClosure{QkGate_Z}(qc, 1, 0)
    elseif sym === :p
        return GateClosure{QkGate_Phase}(qc, 1, 1)
    elseif sym === :r
        return GateClosure{QkGate_R}(qc, 1, 2)
    elseif sym === :rx
        return GateClosure{QkGate_RX}(qc, 1, 1)
    elseif sym === :ry
        return GateClosure{QkGate_RY}(qc, 1, 1)
    elseif sym === :rz
        return GateClosure{QkGate_RZ}(qc, 1, 1)
    elseif sym === :s
        return GateClosure{QkGate_S}(qc, 1, 0)
    elseif sym === :sdg
        return GateClosure{QkGate_Sdg}(qc, 1, 0)
    elseif sym === :sx
        return GateClosure{QkGate_SX}(qc, 1, 0)
    elseif sym === :sxdg
        return GateClosure{QkGate_SXdg}(qc, 1, 0)
    elseif sym === :t
        return GateClosure{QkGate_T}(qc, 1, 0)
    elseif sym === :tdg
        return GateClosure{QkGate_Tdg}(qc, 1, 0)
    elseif sym === :u
        return GateClosure{QkGate_U}(qc, 1, 3)
    elseif sym === :ch
        return GateClosure{QkGate_CH}(qc, 2, 0)
    elseif sym === :cx
        return GateClosure{QkGate_CX}(qc, 2, 0)
    elseif sym === :cy
        return GateClosure{QkGate_CY}(qc, 2, 0)
    elseif sym === :cz
        return GateClosure{QkGate_CZ}(qc, 2, 0)
    elseif sym === :dcx
        return GateClosure{QkGate_DCX}(qc, 2, 0)
    elseif sym === :ecr
        return GateClosure{QkGate_ECR}(qc, 2, 0)
    elseif sym === :swap
        return GateClosure{QkGate_Swap}(qc, 2, 0)
    elseif sym === :iswap
        return GateClosure{QkGate_ISwap}(qc, 2, 0)
    elseif sym === :cp
        return GateClosure{QkGate_CPhase}(qc, 2, 1)
    elseif sym === :crx
        return GateClosure{QkGate_CRX}(qc, 2, 1)
    elseif sym === :cry
        return GateClosure{QkGate_CRY}(qc, 2, 1)
    elseif sym === :crz
        return GateClosure{QkGate_CRZ}(qc, 2, 1)
    elseif sym === :cs
        return GateClosure{QkGate_CS}(qc, 2, 0)
    elseif sym === :csdg
        return GateClosure{QkGate_CSdg}(qc, 2, 0)
    elseif sym === :csx
        return GateClosure{QkGate_CSX}(qc, 2, 0)
    elseif sym === :cu
        return GateClosure{QkGate_CU}(qc, 2, 3)
    elseif sym === :rxx
        return GateClosure{QkGate_RXX}(qc, 2, 1)
    elseif sym === :ryy
        return GateClosure{QkGate_RYY}(qc, 2, 1)
    elseif sym === :rzz
        return GateClosure{QkGate_RZZ}(qc, 2, 1)
    elseif sym === :rzx
        return GateClosure{QkGate_RZX}(qc, 2, 1)
        #=
    elseif sym === :
        return GateClosure{QkGate_XXMinusYY}(qc, 2, 2)
    elseif sym === :
        return GateClosure{QkGate_XXPlusYY}(qc, 2, 2)
        =#
    elseif sym === :ccx
        return GateClosure{QkGate_CCX}(qc, 3, 0)
    elseif sym === :ccz
        return GateClosure{QkGate_CCZ}(qc, 3, 0)
    elseif sym === :cswap
        return GateClosure{QkGate_CSwap}(qc, 3, 0)
    elseif sym === :rccx
        return GateClosure{QkGate_RCCX}(qc, 3, 0)
        #=
    elseif sym === :
        return GateClosure{QkGate_C3X}(qc, , )
    elseif sym === :
        return GateClosure{QkGate_C3SX}(qc, , )
        =#
    elseif sym === :unitary
        throw(NotImplementedError())
    elseif sym === :rcccx
        return GateClosure{QkGate_RC3X}(qc, 4, 0)
    else
        return getfield(qc, sym)
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
