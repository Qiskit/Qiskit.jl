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

@enum QkGate::UInt8 begin
    QkGate_GlobalPhase = 0
    QkGate_H = 1
    QkGate_I = 2
    QkGate_X = 3
    QkGate_Y = 4
    QkGate_Z = 5
    QkGate_Phase = 6
    QkGate_R = 7
    QkGate_RX = 8
    QkGate_RY = 9
    QkGate_RZ = 10
    QkGate_S = 11
    QkGate_Sdg = 12
    QkGate_SX = 13
    QkGate_SXdg = 14
    QkGate_T = 15
    QkGate_Tdg = 16
    QkGate_U = 17
    QkGate_U1 = 18
    QkGate_U2 = 19
    QkGate_U3 = 20
    QkGate_CH = 21
    QkGate_CX = 22
    QkGate_CY = 23
    QkGate_CZ = 24
    QkGate_DCX = 25
    QkGate_ECR = 26
    QkGate_Swap = 27
    QkGate_ISwap = 28
    QkGate_CPhase = 29
    QkGate_CRX = 30
    QkGate_CRY = 31
    QkGate_CRZ = 32
    QkGate_CS = 33
    QkGate_CSdg = 34
    QkGate_CSX = 35
    QkGate_CU = 36
    QkGate_CU1 = 37
    QkGate_CU3 = 38
    QkGate_RXX = 39
    QkGate_RYY = 40
    QkGate_RZZ = 41
    QkGate_RZX = 42
    QkGate_XXMinusYY = 43
    QkGate_XXPlusYY = 44
    QkGate_CCX = 45
    QkGate_CCZ = 46
    QkGate_CSwap = 47
    QkGate_RCCX = 48
    QkGate_C3X = 49
    QkGate_C3SX = 50
    QkGate_RC3X = 51
end

mutable struct QkCircuit
end

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

@enum QkDelayUnit::UInt8 begin
    QkDelayUnit_S = 0
    QkDelayUnit_MS = 1
    QkDelayUnit_US = 2
    QkDelayUnit_NS = 3
    QkDelayUnit_PS = 4
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

export QkGate, QkCircuit, QkDelayUnit
export qk_circuit_free, qk_circuit_num_qubits, qk_circuit_num_clbits, qk_circuit_num_instructions, qk_circuit_get_instruction
export qk_circuit_gate, qk_circuit_measure, qk_circuit_reset, qk_circuit_barrier, qk_circuit_unitary, qk_circuit_delay

# Export enum instances
for e in (QkGate, QkDelayUnit)
    for s in instances(e)
        @eval export $(Symbol(s))
    end
end
