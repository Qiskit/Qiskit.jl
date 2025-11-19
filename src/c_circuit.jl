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

import .LibQiskit: QkGate, QkCircuit, QkDelayUnit, QkOpCount, QkOpCounts

mutable struct QkCircuitInstruction
    name::Cstring
    qubits::Ptr{UInt32}
    clbits::Ptr{UInt32}
    params::Ptr{Cdouble}
    num_qubits::UInt32
    num_clbits::UInt32
    num_params::UInt32

    QkCircuitInstruction() = new(C_NULL, C_NULL, C_NULL, C_NULL, 0, 0, 0)
end

mutable struct CircuitInstruction
    name::String
    qubits::Vector{Int}
    clbits::Vector{Int}
    params::Vector{Float64}
end

function Base.getproperty(obj::CircuitInstruction, sym::Symbol)
    if sym === :num_qubits
        return length(obj.qubits)
    elseif sym === :num_clbits
        return length(obj.clbits)
    elseif sym === :num_params
        return length(obj.params)
    else
        return getfield(obj, sym)
    end
end

function check_not_null(qc::Ptr{QkCircuit})::Nothing
    if qc == C_NULL
        throw(ArgumentError("Ptr{QkCircuit} is NULL."))
    end
    nothing
end

function qk_circuit_free(qc::Ptr{QkCircuit})
    @ccall libqiskit.qk_circuit_free(qc::Ptr{QkCircuit})::Cvoid
end

function qk_circuit_num_qubits(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    @ccall libqiskit.qk_circuit_num_qubits(qc::Ref{QkCircuit})::UInt32
end

function qk_circuit_num_clbits(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    @ccall libqiskit.qk_circuit_num_clbits(qc::Ref{QkCircuit})::UInt32
end

function qk_circuit_num_instructions(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    @ccall libqiskit.qk_circuit_num_instructions(qc::Ref{QkCircuit})::Csize_t
end

function qk_circuit_get_instruction(qc::Ref{QkCircuit}, index::Integer; offset::Int = 1)::CircuitInstruction
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_instructions(qc)), index)
        throw(ArgumentError("Invalid instruction index"))
    end
    inst = QkCircuitInstruction()
    index0 = index - offset
    @ccall libqiskit.qk_circuit_get_instruction(qc::Ref{QkCircuit}, index0::Csize_t, inst::Ref{QkCircuitInstruction})::Cvoid
    retval = CircuitInstruction(
        unsafe_string(inst.name),
        unsafe_wrap(Array, inst.qubits, inst.num_qubits) .+ offset,
        unsafe_wrap(Array, inst.clbits, inst.num_clbits) .+ offset,
        # We need to copy, otherwise the underlying memory is about to be free'd.
        copy(unsafe_wrap(Array, inst.params, inst.num_params))
    )
    @ccall libqiskit.qk_circuit_instruction_clear(inst::Ref{QkCircuitInstruction})::Cvoid
    return retval
end

function qk_gate_num_qubits(gate::QkGate)::Int
    @ccall libqiskit.qk_gate_num_qubits(gate::QkGate)::UInt32
end

function qk_gate_num_params(gate::QkGate)::Int
    @ccall libqiskit.qk_gate_num_params(gate::QkGate)::UInt32
end

function qk_circuit_gate(qc::Ref{QkCircuit}, gate::QkGate, qubits::AbstractVector{<:Integer}, params::Union{Nothing,AbstractVector{<:Real}} = nothing; offset::Int = 1)::Nothing
    check_not_null(qc)
    if length(qubits) != qk_gate_num_qubits(gate)
        throw(ArgumentError("Unexpected number of qubits for gate."))
    end
    if params !== nothing && length(params) != qk_gate_num_params(gate)
        throw(ArgumentError("Unexpected number of parameters for gate."))
    end
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubits)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubits0 = Vector{UInt32}(qubits .- offset)
    if params === nothing || length(params) == 0
        check_exit_code(@ccall libqiskit.qk_circuit_gate(qc::Ref{QkCircuit}, gate::QkGate, qubits0::Ref{UInt32}, C_NULL::Ptr{Cdouble})::QkExitCode)
    else
        check_exit_code(@ccall libqiskit.qk_circuit_gate(qc::Ref{QkCircuit}, gate::QkGate, qubits0::Ref{UInt32}, params::Ref{Cdouble})::QkExitCode)
    end
    nothing
end

function qk_circuit_measure(qc::Ref{QkCircuit}, qubit::Integer, clbit::Integer; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubit)
        throw(ArgumentError("Invalid qubit index"))
    end
    if !checkindex(Bool, range(offset, length=qk_circuit_num_clbits(qc)), clbit)
        throw(ArgumentError("Invalid clbit index"))
    end
    qubit0 = qubit - offset
    clbit0 = clbit - offset
    check_exit_code(@ccall libqiskit.qk_circuit_measure(qc::Ref{QkCircuit}, qubit0::UInt32, clbit0::UInt32)::QkExitCode)
    nothing
end

function qk_circuit_reset(qc::Ref{QkCircuit}, qubit::Integer; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubit)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubit0 = qubit - offset
    check_exit_code(@ccall libqiskit.qk_circuit_reset(qc::Ref{QkCircuit}, qubit0::UInt32)::QkExitCode)
    nothing
end

function qk_circuit_barrier(qc::Ref{QkCircuit}, qubits::AbstractVector{<:Integer}; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubits)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubits0 = Vector{UInt32}(qubits .- offset)
    check_exit_code(@ccall libqiskit.qk_circuit_barrier(qc::Ref{QkCircuit}, qubits0::Ref{UInt32}, length(qubits)::UInt32)::QkExitCode)
    nothing
end

function qk_circuit_unitary(qc::Ref{QkCircuit}, matrix::AbstractMatrix{<:Number}, qubits::AbstractVector{<:Integer}; check_input::Bool = true, offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubits)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubits0 = Vector{UInt32}(qubits .- offset)
    num_qubits = length(qubits)
    if size(matrix) != (2 ^ num_qubits, 2 ^ num_qubits)
        throw(ArgumentError("Matrix must be square and have dimension 2^num_qubits."))
    end
    row_major_matrix = convert(Matrix{ComplexF64}, transpose(matrix))
    check_exit_code(@ccall libqiskit.qk_circuit_unitary(qc::Ref{QkCircuit}, row_major_matrix::Ref{Complex{Cdouble}}, qubits0::Ref{UInt32}, length(qubits)::UInt32, check_input::Cuchar)::QkExitCode)
end

function qk_circuit_delay(qc::Ref{QkCircuit}, qubit::Integer, duration::Real, unit::QkDelayUnit; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !(duration >= 0)
        throw(ArgumentError("Duration must be non-negative."))
    end
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubit)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubit0 = qubit - offset
    check_exit_code(@ccall libqiskit.qk_circuit_delay(qc::Ref{QkCircuit}, qubit0::UInt32, duration::Float64, unit::UInt8)::QkExitCode)
    nothing
end

function qk_circuit_count_ops(qc::Ref{QkCircuit})
    opcounts = @ccall libqiskit.qk_circuit_count_ops(qc::Ref{QkCircuit})::QkOpCounts
    retval = Tuple{String, Int}[]
    sizehint!(retval, opcounts.len)
    for i in 1:opcounts.len
        op_count = unsafe_load(opcounts.data, i)
        push!(retval, (unsafe_string(op_count.name), op_count.count))
    end
    return retval
end

export QkGate, QkCircuit, QkDelayUnit
export qk_circuit_free, qk_circuit_num_qubits, qk_circuit_num_clbits, qk_circuit_num_instructions, qk_circuit_get_instruction, qk_circuit_count_ops
export qk_circuit_gate, qk_circuit_measure, qk_circuit_reset, qk_circuit_barrier, qk_circuit_unitary, qk_circuit_delay

# Export enum instances
for e in (QkGate, QkDelayUnit)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
