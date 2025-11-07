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

import .C: QkTargetEntry, qk_target_entry_free, qk_target_entry_num_properties, qk_target_entry_add_property
import .C: QkTarget, qk_target_free, qk_target_add_instruction

mutable struct TargetEntry
    ptr::Ptr{QkTargetEntry}
    function TargetEntry(entry::Ptr{QkTargetEntry})
        check_not_null(entry)
        target_entry = new(entry)
        finalizer(qk_target_entry_free, target_entry)
        target_entry
    end
end

function qk_target_entry_free(obj::TargetEntry)::Nothing
    if obj.ptr != C_NULL
        qk_target_entry_free(obj.ptr)
        obj.ptr = C_NULL
    end
    nothing
end

target_entry_gate(operation::QkGate)::TargetEntry =
    TargetEntry(@ccall(libqiskit.qk_target_entry_new(operation::QkGate)::Ptr{QkTargetEntry}))

target_entry_measure()::TargetEntry =
    TargetEntry(@ccall(libqiskit.qk_target_entry_new_measure()::Ptr{QkTargetEntry}))

target_entry_reset()::TargetEntry =
    TargetEntry(@ccall(libqiskit.qk_target_entry_new_reset()::Ptr{QkTargetEntry}))

function target_entry_fixed(operation::QkGate, params::AbstractVector{<:Real})::TargetEntry
    if length(params) != qk_gate_num_params(gate)
        throw(ArgumentError("Unexpected number of parameters for gate."))
    end
    TargetEntry(@ccall(libqiskit.qk_target_entry_new_fixed(operation::QkGate, params::Ref{Cdouble})::Ptr{QkTargetEntry}))
end

qk_target_entry_num_properties(obj::TargetEntry)::Int = qk_target_entry_num_properties(obj.ptr)

qk_target_entry_add_property(target_entry::TargetEntry, args...) = qk_target_entry_add_property(target_entry.ptr, args...)

function Base.getproperty(obj::TargetEntry, sym::Symbol)
    if sym === :num_properties
        return qk_target_entry_num_properties(obj)
    else
        return getfield(obj, sym)
    end
end

mutable struct Target
    ptr::Ptr{QkTarget}
    function Target(num_qubits::Integer)
        num_qubits >= 0 || throw(ArgumentError("num_qubits must be non-negative."))
        target = new(@ccall(libqiskit.qk_target_new(num_qubits::UInt32)::Ptr{QkTarget}))
        finalizer(qk_target_free, target)
        target
    end
    function Target(src::Ref{QkTarget})
        check_not_null(src)
        target = new(@ccall(libqiskit.qk_target_copy(src::Ref{QkTarget})::Ptr{QkTarget}))
        finalizer(qk_target_free, target)
        target
    end
end

function qk_target_free(obj::Target)::Nothing
    if obj.ptr != C_NULL
        qk_target_free(obj.ptr)
        obj.ptr = C_NULL
    end
    nothing
end

Base.copy(obj::Target)::Target = Target(obj.ptr)

qk_target_num_qubits(obj::Target) =
    qk_target_num_qubits(obj.ptr)

qk_target_num_instructions(obj::Target) =
    qk_target_num_instructions(obj.ptr)

function qk_target_add_instruction(target::Target, entry::TargetEntry)::Nothing
    qk_target_add_instruction(target.ptr, entry.ptr)
    entry.ptr = C_NULL
    nothing
end

#qk_target_dt

#qk_target_granularity

#qk_target_[...]

@compat public Target, target_entry_gate, target_entry_fixed, target_entry_measure, target_entry_reset
