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

import .LibQiskit: QkDag, QkDagNodeType, QkOperationKind, QkDagNeighbors, QkGate, QkComplex64

function check_not_null(ptr::Ptr{QkDag})::Nothing
    if ptr == C_NULL
        throw(ArgumentError("Ptr{QkDag} is NULL."))
    end
    nothing
end

function qk_dag_free(dag::Ptr{QkDag})::Nothing
    LibQiskit.qk_dag_free(dag)
end

function qk_dag_new()::Ptr{QkDag}
    LibQiskit.qk_dag_new()
end

function qk_circuit_to_dag(qc::Ptr{QkCircuit})::Ptr{QkDag}
    check_not_null(qc)
    dag = LibQiskit.qk_circuit_to_dag(qc)
    check_not_null(dag)
    dag
end

function qk_dag_to_circuit(dag::Ptr{QkDag})::Ptr{QkCircuit}
    check_not_null(dag)
    circuit = LibQiskit.qk_dag_to_circuit(dag)
    check_not_null(circuit)
    circuit
end

function qk_dag_num_qubits(dag::Ptr{QkDag})::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_num_qubits(dag))
end

function qk_dag_num_clbits(dag::Ptr{QkDag})::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_num_clbits(dag))
end

function qk_dag_num_op_nodes(dag::Ptr{QkDag})::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_num_op_nodes(dag))
end

function qk_dag_topological_op_nodes(dag::Ptr{QkDag})::Vector{UInt32}
    check_not_null(dag)
    n = qk_dag_num_op_nodes(dag)
    if n == 0
        return UInt32[]
    end
    out = Vector{UInt32}(undef, n)
    LibQiskit.qk_dag_topological_op_nodes(dag, out)
    out
end

function qk_dag_get_instruction(dag::Ptr{QkDag}, index::Integer)::CircuitInstruction
    check_not_null(dag)
    index0 = UInt32(index)
    inst_ref = Ref(LibQiskit.QkCircuitInstruction(C_NULL, C_NULL, C_NULL, C_NULL, 0, 0, 0))
    LibQiskit.qk_dag_get_instruction(dag, index0, inst_ref)
    inst = inst_ref[]
    param_ptrs = unsafe_wrap(Array, inst.params, inst.num_params)
    params = map(param_ptrs) do p
        LibQiskit.qk_param_as_real(p)
    end
    retval = CircuitInstruction(
        unsafe_string(inst.name),
        collect(Int, unsafe_wrap(Array, inst.qubits, inst.num_qubits)),
        collect(Int, unsafe_wrap(Array, inst.clbits, inst.num_clbits)),
        params
    )
    LibQiskit.qk_circuit_instruction_clear(inst_ref)
    return retval
end

function qk_dag_node_type(dag::Ptr{QkDag}, node::UInt32)::QkDagNodeType
    check_not_null(dag)
    LibQiskit.qk_dag_node_type(dag, node)
end

function qk_dag_op_node_kind(dag::Ptr{QkDag}, node::UInt32)::QkOperationKind
    check_not_null(dag)
    LibQiskit.qk_dag_op_node_kind(dag, node)
end

function qk_dag_op_node_num_qubits(dag::Ptr{QkDag}, node::UInt32)::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_op_node_num_qubits(dag, node))
end

function qk_dag_op_node_num_clbits(dag::Ptr{QkDag}, node::UInt32)::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_op_node_num_clbits(dag, node))
end

function qk_dag_op_node_num_params(dag::Ptr{QkDag}, node::UInt32)::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_op_node_num_params(dag, node))
end

function qk_dag_op_node_qubits(dag::Ptr{QkDag}, node::UInt32)::Vector{Int}
    check_not_null(dag)
    n = qk_dag_op_node_num_qubits(dag, node)
    if n == 0
        return Int[]
    end
    ptr = LibQiskit.qk_dag_op_node_qubits(dag, node)
    collect(Int, unsafe_wrap(Array, ptr, n))
end

function qk_dag_op_node_clbits(dag::Ptr{QkDag}, node::UInt32)::Vector{Int}
    check_not_null(dag)
    n = qk_dag_op_node_num_clbits(dag, node)
    if n == 0
        return Int[]
    end
    ptr = LibQiskit.qk_dag_op_node_clbits(dag, node)
    collect(Int, unsafe_wrap(Array, ptr, n))
end

function qk_dag_op_node_gate_op(dag::Ptr{QkDag}, node::UInt32, out_params::Ptr{Cdouble})::QkGate
    check_not_null(dag)
    LibQiskit.qk_dag_op_node_gate_op(dag, node, out_params)
end

function qk_dag_op_node_unitary(dag::Ptr{QkDag}, node::UInt32, out::Ptr{QkComplex64})::Nothing
    check_not_null(dag)
    LibQiskit.qk_dag_op_node_unitary(dag, node, out)
end

function qk_dag_successors(dag::Ptr{QkDag}, node::UInt32)::QkDagNeighbors
    check_not_null(dag)
    LibQiskit.qk_dag_successors(dag, node)
end

function qk_dag_predecessors(dag::Ptr{QkDag}, node::UInt32)::QkDagNeighbors
    check_not_null(dag)
    LibQiskit.qk_dag_predecessors(dag, node)
end

function qk_dag_neighbors_clear(neighbors::Ptr{QkDagNeighbors})::Nothing
    LibQiskit.qk_dag_neighbors_clear(neighbors)
    nothing
end

function qk_dag_wire_node_value(dag::Ptr{QkDag}, node::UInt32)::Int
    check_not_null(dag)
    Int(LibQiskit.qk_dag_wire_node_value(dag, node))
end

function qk_dag_qubit_in_node(dag::Ptr{QkDag}, qubit::UInt32)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_qubit_in_node(dag, qubit)
end

function qk_dag_qubit_out_node(dag::Ptr{QkDag}, qubit::UInt32)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_qubit_out_node(dag, qubit)
end

function qk_dag_clbit_in_node(dag::Ptr{QkDag}, clbit::UInt32)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_clbit_in_node(dag, clbit)
end

function qk_dag_clbit_out_node(dag::Ptr{QkDag}, clbit::UInt32)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_clbit_out_node(dag, clbit)
end

function qk_dag_apply_gate(dag::Ptr{QkDag}, gate::QkGate, qubits::AbstractVector{<:Integer}, params::Union{Nothing,AbstractVector{<:Real}}, front::Bool)::UInt32
    check_not_null(dag)
    qubits0 = UInt32.(qubits)
    if params === nothing || length(params) == 0
        LibQiskit.qk_dag_apply_gate(dag, gate, qubits0, C_NULL, front)
    else
        p = collect(Float64, params)
        LibQiskit.qk_dag_apply_gate(dag, gate, qubits0, p, front)
    end
end

function qk_dag_apply_measure(dag::Ptr{QkDag}, qubit::Integer, clbit::Integer, front::Bool)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_apply_measure(dag, UInt32(qubit), UInt32(clbit), front)
end

function qk_dag_apply_reset(dag::Ptr{QkDag}, qubit::Integer, front::Bool)::UInt32
    check_not_null(dag)
    LibQiskit.qk_dag_apply_reset(dag, UInt32(qubit), front)
end

function qk_dag_apply_barrier(dag::Ptr{QkDag}, qubits::AbstractVector{<:Integer}, front::Bool)::UInt32
    check_not_null(dag)
    qubits0 = UInt32.(qubits)
    LibQiskit.qk_dag_apply_barrier(dag, qubits0, UInt32(length(qubits0)), front)
end

function qk_dag_apply_unitary(dag::Ptr{QkDag}, matrix::AbstractMatrix{<:Number}, qubits::AbstractVector{<:Integer}, front::Bool)::UInt32
    check_not_null(dag)
    num_qubits = length(qubits)
    qubits0 = UInt32.(qubits)
    row_major_matrix = convert(Matrix{ComplexF64}, transpose(matrix))
    LibQiskit.qk_dag_apply_unitary(dag, row_major_matrix, qubits0, UInt32(num_qubits), front)
end

function qk_dag_compose(dag::Ptr{QkDag}, other::Ptr{QkDag}, qubits::AbstractVector{<:Integer}, clbits::AbstractVector{<:Integer})::Nothing
    check_not_null(dag)
    check_not_null(other)
    qubits0 = UInt32.(qubits)
    clbits0 = UInt32.(clbits)
    check_exit_code(LibQiskit.qk_dag_compose(dag, other, qubits0, clbits0))
    nothing
end

function qk_dag_substitute_node_with_dag(dag::Ptr{QkDag}, node::UInt32, replacement::Ptr{QkDag})::Nothing
    check_not_null(dag)
    check_not_null(replacement)
    LibQiskit.qk_dag_substitute_node_with_dag(dag, node, replacement)
    nothing
end

function qk_dag_substitute_node_with_unitary(dag::Ptr{QkDag}, node::UInt32, matrix::AbstractMatrix{<:Number}, num_qubits::Integer)::Nothing
    check_not_null(dag)
    row_major_matrix = convert(Matrix{ComplexF64}, transpose(matrix))
    LibQiskit.qk_dag_substitute_node_with_unitary(dag, node, row_major_matrix, UInt32(num_qubits))
    nothing
end

export QkDag, QkDagNodeType, QkOperationKind
export qk_dag_free, qk_dag_new, qk_circuit_to_dag, qk_dag_to_circuit
export qk_dag_num_qubits, qk_dag_num_clbits, qk_dag_num_op_nodes
export qk_dag_topological_op_nodes, qk_dag_get_instruction
export qk_dag_node_type, qk_dag_op_node_kind
export qk_dag_op_node_num_qubits, qk_dag_op_node_num_clbits, qk_dag_op_node_num_params
export qk_dag_op_node_qubits, qk_dag_op_node_clbits
export qk_dag_op_node_gate_op, qk_dag_op_node_unitary
export qk_dag_successors, qk_dag_predecessors, qk_dag_neighbors_clear
export qk_dag_wire_node_value
export qk_dag_qubit_in_node, qk_dag_qubit_out_node
export qk_dag_clbit_in_node, qk_dag_clbit_out_node
export qk_dag_apply_gate, qk_dag_apply_measure, qk_dag_apply_reset
export qk_dag_apply_barrier, qk_dag_apply_unitary
export qk_dag_compose
export qk_dag_substitute_node_with_dag, qk_dag_substitute_node_with_unitary

for e in (QkDagNodeType, QkOperationKind)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
