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

import .LibQiskit: QkTargetEntry, QkTarget

function check_not_null(obj::Ptr{QkTargetEntry})::Nothing
    if obj == C_NULL
        throw(ArgumentError("Ptr{QkTargetEntry} is NULL."))
    end
    nothing
end

function qk_target_entry_free(obj::Ptr{QkTargetEntry})
    @ccall libqiskit.qk_target_entry_free(obj::Ptr{QkTargetEntry})::Cvoid
end

function qk_target_entry_num_properties(obj::Ref{QkTargetEntry})::Int
    check_not_null(obj)
    @ccall libqiskit.qk_target_entry_num_properties(obj::Ref{QkTargetEntry})::Csize_t
end

function qk_target_entry_add_property(target_entry::Ref{QkTargetEntry}, qubits::AbstractVector{<:Integer}, duration::Real, error::Real)::Nothing
    qubits0 = Vector{UInt32}(qubits .- 1)
    check_exit_code(@ccall(libqiskit.qk_target_entry_add_property(target_entry::Ref{QkTargetEntry}, qubits0::Ref{UInt32}, length(qubits0)::UInt32, duration::Cdouble, error::Cdouble)::QkExitCode))
end

function check_not_null(obj::Ptr{QkTarget})::Nothing
    if obj == C_NULL
        throw(ArgumentError("Ptr{QkTarget} is NULL."))
    end
    nothing
end

function qk_target_free(obj::Ptr{QkTarget})
    @ccall libqiskit.qk_target_free(obj::Ptr{QkTarget})::Cvoid
end

function qk_target_num_qubits(obj::Ref{QkTarget})::Int
    check_not_null(obj)
    @ccall libqiskit.qk_target_num_qubits(obj::Ref{QkTarget})::UInt32
end

function qk_target_num_instructions(obj::Ref{QkTarget})::Int
    check_not_null(obj)
    @ccall libqiskit.qk_target_num_instructions(obj::Ref{QkTarget})::Csize_t
end

function qk_target_add_instruction(target::Ref{QkTarget}, entry::Ref{QkTargetEntry})::Nothing
    # Note: `entry` is no longer valid after calling this method
    check_not_null(target)
    check_not_null(entry)
    check_exit_code(@ccall libqiskit.qk_target_add_instruction(target::Ref{QkTarget}, entry::Ref{QkTargetEntry})::QkExitCode)
    nothing
end

export QkTargetEntry, qk_target_entry_free, qk_target_entry_num_properties, qk_target_entry_add_property
export QkTarget, qk_target_free, qk_target_num_qubits, qk_target_num_instructions, qk_target_add_instruction
