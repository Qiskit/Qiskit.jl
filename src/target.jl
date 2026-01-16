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

"""
    TargetEntry

A mapping of qubit arguments and properties representing gate map of the `Target`.

Available properties:

- `num_properties`
"""
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

function Base.propertynames(obj::TargetEntry; private::Bool = false)
    union(fieldnames(typeof(obj)), (:num_properties,))
end

function Base.getproperty(obj::TargetEntry, sym::Symbol)
    if sym === :num_properties
        return qk_target_entry_num_properties(obj)
    else
        return getfield(obj, sym)
    end
end

"""
    Target

A mapping of instructions and properties representing the particular
constraints of a backend. Its purpose is to provide the compiler with
information that allows it to compile an input circuit into another that is
optimized taking in consideration the `Target`'s specifications.

Available properties:

- `num_qubits`
- `num_instructions`
"""
mutable struct Target
    ptr::Ptr{QkTarget}
    @doc"""
         Target(num_qubits)
    """
    function Target(num_qubits::Integer)
        num_qubits >= 0 || throw(ArgumentError("num_qubits must be non-negative."))
        target = new(@ccall(libqiskit.qk_target_new(num_qubits::UInt32)::Ptr{QkTarget}))
        # Take ownership; it's our job to free it eventually
        finalizer(qk_target_free, target)
        target
    end
    function Target(ptr::Ptr{QkTarget})
        check_not_null(ptr)
        target = new(ptr)
        # Take ownership; it's our job to free it eventually
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

function Base.copy(obj::Target)::Target
    check_not_null(obj.ptr)
    Target(@ccall(libqiskit.qk_target_copy(obj.ptr::Ref{QkTarget})::Ptr{QkTarget}))
end

qk_target_num_qubits(obj::Target) =
    qk_target_num_qubits(obj.ptr)

qk_target_num_instructions(obj::Target) =
    qk_target_num_instructions(obj.ptr)

#qk_target_dt

#qk_target_granularity

#qk_target_[...]

function Base.propertynames(obj::Target; private::Bool = false)
    union(fieldnames(typeof(obj)), (:num_qubits, :num_instructions, :dt, :granularity, :min_length, :pulse_alignment, :acquire_alignment))
end

# Base.setproperty!

function Base.getproperty(obj::Target, sym::Symbol)
    if sym === :num_qubits
        return qk_target_num_qubits(obj)
    elseif sym === :num_instructions
        return qk_target_num_instructions(obj)
    else
        return getfield(obj, sym)
    end
end

function qk_target_add_instruction(target::Target, entry::TargetEntry)::Nothing
    qk_target_add_instruction(target.ptr, entry.ptr)
    entry.ptr = C_NULL
    nothing
end

#qk_target_update_property

@compat public Target, target_entry_gate, target_entry_fixed, target_entry_measure, target_entry_reset
