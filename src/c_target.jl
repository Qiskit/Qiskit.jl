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
    LibQiskit.qk_target_entry_free(obj)
end

function qk_target_entry_num_properties(obj::Ref{QkTargetEntry})::Int
    check_not_null(obj)
    Int(LibQiskit.qk_target_entry_num_properties(obj))
end

function qk_target_entry_add_property(target_entry::Ref{QkTargetEntry}, qubits::AbstractVector{<:Integer}, duration::Real, error::Real)::Nothing
    qubits0 = Vector{UInt32}(qubits .- 1)
    check_exit_code(LibQiskit.qk_target_entry_add_property(target_entry, qubits0, length(qubits0), duration, error))
end

function check_not_null(obj::Ptr{QkTarget})::Nothing
    if obj == C_NULL
        throw(ArgumentError("Ptr{QkTarget} is NULL."))
    end
    nothing
end

function qk_target_free(obj::Ptr{QkTarget})
    LibQiskit.qk_target_free(obj)
end

function qk_target_num_qubits(obj::Ref{QkTarget})::Int
    check_not_null(obj)
    Int(LibQiskit.qk_target_num_qubits(obj))
end

function qk_target_num_instructions(obj::Ref{QkTarget})::Int
    check_not_null(obj)
    Int(LibQiskit.qk_target_num_instructions(obj))
end

function qk_target_add_instruction(target::Ref{QkTarget}, entry::Ref{QkTargetEntry})::Nothing
    check_not_null(target)
    check_not_null(entry)
    check_exit_code(LibQiskit.qk_target_add_instruction(target, entry))
    nothing
end

export QkTargetEntry, qk_target_entry_free, qk_target_entry_num_properties, qk_target_entry_add_property
export QkTarget, qk_target_free, qk_target_num_qubits, qk_target_num_instructions, qk_target_add_instruction
