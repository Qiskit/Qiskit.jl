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

import .LibQiskit: QkGate, QkCircuit, QkDelayUnit, QkOpCount, QkOpCounts, QkParam, QkCircuitInstruction

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
    LibQiskit.qk_circuit_free(qc)
end

function qk_circuit_num_qubits(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    Int(LibQiskit.qk_circuit_num_qubits(qc))
end

function qk_circuit_num_clbits(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    Int(LibQiskit.qk_circuit_num_clbits(qc))
end

function qk_circuit_num_instructions(qc::Ref{QkCircuit})::Int
    check_not_null(qc)
    Int(LibQiskit.qk_circuit_num_instructions(qc))
end

function qk_circuit_get_instruction(qc::Ref{QkCircuit}, index::Integer; offset::Int = 1)::CircuitInstruction
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_instructions(qc)), index)
        throw(ArgumentError("Invalid instruction index"))
    end
    inst_ref = Ref(LibQiskit.QkCircuitInstruction(C_NULL, C_NULL, C_NULL, C_NULL, 0, 0, 0))
    index0 = index - offset
    LibQiskit.qk_circuit_get_instruction(qc, index0, inst_ref)
    inst = inst_ref[]
    param_ptrs = unsafe_wrap(Array, inst.params, inst.num_params)
    params = map(param_ptrs) do p
        LibQiskit.qk_param_as_real(p)
    end
    retval = CircuitInstruction(
        unsafe_string(inst.name),
        unsafe_wrap(Array, inst.qubits, inst.num_qubits) .+ offset,
        unsafe_wrap(Array, inst.clbits, inst.num_clbits) .+ offset,
        params
    )
    LibQiskit.qk_circuit_instruction_clear(inst_ref)
    return retval
end

function qk_gate_num_qubits(gate::QkGate)::Int
    Int(LibQiskit.qk_gate_num_qubits(gate))
end

function qk_gate_num_params(gate::QkGate)::Int
    Int(LibQiskit.qk_gate_num_params(gate))
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
        check_exit_code(LibQiskit.qk_circuit_gate(qc, gate, qubits0, C_NULL))
    else
        check_exit_code(LibQiskit.qk_circuit_gate(qc, gate, qubits0, params))
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
    check_exit_code(LibQiskit.qk_circuit_measure(qc, qubit0, clbit0))
    nothing
end

function qk_circuit_reset(qc::Ref{QkCircuit}, qubit::Integer; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubit)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubit0 = qubit - offset
    check_exit_code(LibQiskit.qk_circuit_reset(qc, qubit0))
    nothing
end

function qk_circuit_barrier(qc::Ref{QkCircuit}, qubits::AbstractVector{<:Integer}; offset::Int = 1)::Nothing
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_qubits(qc)), qubits)
        throw(ArgumentError("Invalid qubit index"))
    end
    qubits0 = Vector{UInt32}(qubits .- offset)
    check_exit_code(LibQiskit.qk_circuit_barrier(qc, qubits0, length(qubits)))
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
    check_exit_code(LibQiskit.qk_circuit_unitary(qc, row_major_matrix, qubits0, length(qubits), check_input))
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
    check_exit_code(LibQiskit.qk_circuit_delay(qc, qubit0, Float64(duration), unit))
    nothing
end

function qk_circuit_count_ops(qc::Ref{QkCircuit})
    check_not_null(qc)
    opcounts = Ref(LibQiskit.qk_circuit_count_ops(qc))
    retval = Tuple{String, Int}[]
    try
        sizehint!(retval, opcounts[].len)
        for i in 1:opcounts[].len
            op_count = unsafe_load(opcounts[].data, i)
            push!(retval, (unsafe_string(op_count.name), op_count.count))
        end
    finally
        LibQiskit.qk_opcounts_clear(opcounts)
    end
    return retval
end

export QkGate, QkCircuit, QkDelayUnit, QkParam
export qk_circuit_free, qk_circuit_num_qubits, qk_circuit_num_clbits, qk_circuit_num_instructions, qk_circuit_get_instruction, qk_circuit_count_ops
export qk_circuit_gate, qk_circuit_measure, qk_circuit_reset, qk_circuit_barrier, qk_circuit_unitary, qk_circuit_delay

# Export enum instances
for e in (QkGate, QkDelayUnit)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
