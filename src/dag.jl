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

import .C: qk_circuit_to_dag, qk_dag_to_circuit, qk_dag_free,
    qk_dag_num_qubits, qk_dag_num_clbits, qk_dag_num_op_nodes,
    qk_dag_topological_op_nodes, qk_dag_get_instruction,
    QkDag

"""
    DAGCircuit

Directed Acyclic Graph representation of a quantum circuit.

This is the internal representation used by the Qiskit transpiler. A `DAGCircuit`
can be constructed from a [`QuantumCircuit`](@ref) and converted back. It supports
querying basic circuit information and iterating over operation nodes in
topological order.

Available properties:

- `num_qubits` - number of qubits
- `num_clbits` - number of classical bits
- `num_op_nodes` - number of operation nodes

Iterating over a `DAGCircuit` yields [`DAGNode`](@ref) objects in topological
order.
"""
mutable struct DAGCircuit
    ptr::Ptr{QkDag}
    function DAGCircuit(qc::QuantumCircuit)
        ptr = qk_circuit_to_dag(qc.ptr)
        dag = new(ptr)
        finalizer(qk_dag_free, dag)
        dag
    end
end

function qk_dag_free(dag::DAGCircuit)::Nothing
    if dag.ptr != C_NULL
        qk_dag_free(dag.ptr)
        dag.ptr = C_NULL
    end
    nothing
end

qk_dag_num_qubits(dag::DAGCircuit)::Int = qk_dag_num_qubits(dag.ptr)

qk_dag_num_clbits(dag::DAGCircuit)::Int = qk_dag_num_clbits(dag.ptr)

qk_dag_num_op_nodes(dag::DAGCircuit)::Int = qk_dag_num_op_nodes(dag.ptr)

qk_dag_get_instruction(dag::DAGCircuit, index::Integer)::CircuitInstruction =
    qk_dag_get_instruction(dag.ptr, index)

qk_dag_topological_op_nodes(dag::DAGCircuit)::Vector{UInt32} =
    qk_dag_topological_op_nodes(dag.ptr)

"""
    QuantumCircuit(dag::DAGCircuit)

Convert a `DAGCircuit` back to a `QuantumCircuit`.
"""
function QuantumCircuit(dag::DAGCircuit)
    ptr = qk_dag_to_circuit(dag.ptr)
    QuantumCircuit(ptr)
end

"""
    DAGNode

A node in a [`DAGCircuit`](@ref), representing a single quantum operation.

Available properties:

- `name` - operation name (e.g. `"h"`, `"cx"`, `"measure"`)
- `qubits` - qubit indices
- `clbits` - classical bit indices
- `params` - gate parameters (empty for non-parametric operations)
"""
struct DAGNode
    dag::DAGCircuit
    id::UInt32
    name::String
    qubits::Vector{Int}
    clbits::Vector{Int}
    params::Vector{Float64}
end

function Base.getproperty(node::DAGNode, sym::Symbol)
    if sym === :num_qubits
        return length(getfield(node, :qubits))
    elseif sym === :num_clbits
        return length(getfield(node, :clbits))
    elseif sym === :num_params
        return length(getfield(node, :params))
    else
        return getfield(node, sym)
    end
end

function Base.propertynames(::DAGNode; private::Bool = false)
    (:name, :qubits, :clbits, :params, :num_qubits, :num_clbits, :num_params)
end

function _make_dag_node(dag::DAGCircuit, id::UInt32)::DAGNode
    inst = qk_dag_get_instruction(dag, id)
    DAGNode(dag, id, inst.name, inst.qubits, inst.clbits, inst.params)
end

function Base.iterate(dag::DAGCircuit)
    order = qk_dag_topological_op_nodes(dag.ptr)
    if isempty(order)
        return nothing
    end
    return (_make_dag_node(dag, order[1]), (order, 2))
end

function Base.iterate(dag::DAGCircuit, state)
    order, i = state
    if i > length(order)
        return nothing
    end
    return (_make_dag_node(dag, order[i]), (order, i + 1))
end

function Base.length(dag::DAGCircuit)
    qk_dag_num_op_nodes(dag)
end

function Base.isempty(dag::DAGCircuit)
    qk_dag_num_op_nodes(dag) == 0
end

function Base.show(io::IO, dag::DAGCircuit)
    if dag.ptr == C_NULL
        print(io, "DAGCircuit(NULL)")
    else
        print(io, "DAGCircuit($(dag.num_qubits), $(dag.num_clbits); $(dag.num_op_nodes) nodes)")
    end
end

function Base.show(io::IO, ::MIME"text/plain", dag::DAGCircuit)
    if dag.ptr == C_NULL
        print(io, "DAGCircuit(NULL)")
    else
        print(io, "DAGCircuit with $(dag.num_qubits) qubits, $(dag.num_clbits) clbits\n  nodes: $(dag.num_op_nodes)")
    end
end

function Base.show(io::IO, node::DAGNode)
    print(io, "DAGNode($(node.name)")
    if !isempty(node.qubits)
        print(io, ", qubits=$(node.qubits)")
    end
    if !isempty(node.clbits)
        print(io, ", clbits=$(node.clbits)")
    end
    if !isempty(node.params)
        print(io, ", params=$(node.params)")
    end
    print(io, ")")
end

function Base.getproperty(dag::DAGCircuit, sym::Symbol)
    if sym === :num_qubits
        return qk_dag_num_qubits(dag)
    elseif sym === :num_clbits
        return qk_dag_num_clbits(dag)
    elseif sym === :num_op_nodes
        return qk_dag_num_op_nodes(dag)
    else
        return getfield(dag, sym)
    end
end

function Base.propertynames(::DAGCircuit; private::Bool = false)
    (:num_qubits, :num_clbits, :num_op_nodes)
end

export DAGCircuit, DAGNode
