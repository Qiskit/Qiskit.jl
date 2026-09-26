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

using Qiskit.C: LibQiskit

function _dag_find_node_by_name(dag_ptr, name)
    order = qk_dag_topological_op_nodes(dag_ptr)
    for i in order
        inst_ref = Ref(LibQiskit.QkCircuitInstruction(C_NULL, C_NULL, C_NULL, C_NULL, 0, 0, 0))
        LibQiskit.qk_dag_get_instruction(dag_ptr, i, inst_ref)
        n = unsafe_string(inst_ref[].name)
        LibQiskit.qk_circuit_instruction_clear(inst_ref)
        n == name && return i
    end
    return nothing
end

@testset "DAGCircuit" begin
    @testset "Construction from QuantumCircuit" begin
        qc = QuantumCircuit(3, 2)
        qc.h(1)
        qc.cx(1, 2)
        qc.rz(0.5, 3)
        qc.measure(1, 1)
        qc.measure(2, 2)
        qc.barrier()

        dag = DAGCircuit(qc)
        @test dag.num_qubits == 3
        @test dag.num_clbits == 2
        @test dag.num_op_nodes == 6
        @test length(dag) == 6
        @test !isempty(dag)
    end

    @testset "Empty circuit" begin
        qc = QuantumCircuit(2, 1)
        dag = DAGCircuit(qc)
        @test dag.num_qubits == 2
        @test dag.num_clbits == 1
        @test dag.num_op_nodes == 0
        @test isempty(dag)
        @test length(dag) == 0
    end

    @testset "Round-trip circuit -> dag -> circuit" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.rz(0.25, 3)
        qc.measure(3, 1)

        dag = DAGCircuit(qc)
        qc2 = QuantumCircuit(dag)
        @test qc2.num_qubits == qc.num_qubits
        @test qc2.num_clbits == qc.num_clbits
        @test qc2.num_instructions == qc.num_instructions

        names1 = [inst.name for inst in qc.data]
        names2 = [inst.name for inst in qc2.data]
        @test names1 == names2
    end

    @testset "Iteration and node properties" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)

        dag = DAGCircuit(qc)
        nodes = collect(dag)
        @test length(nodes) == 3

        names = [n.name for n in nodes]
        @test "h" in names
        @test "cx" in names
        @test "measure" in names

        for node in nodes
            @test node isa DAGNode
            @test !isempty(node.name)
            @test node.num_qubits >= 0
            @test node.num_clbits >= 0
            @test node.num_params >= 0
        end

        h_node = nodes[findfirst(n -> n.name == "h", nodes)]
        @test h_node.num_qubits == 1
        @test h_node.num_params == 0

        cx_node = nodes[findfirst(n -> n.name == "cx", nodes)]
        @test cx_node.num_qubits == 2
        @test cx_node.num_params == 0

        m_node = nodes[findfirst(n -> n.name == "measure", nodes)]
        @test m_node.num_qubits == 1
        @test m_node.num_clbits == 1
    end

    @testset "Node with parameters" begin
        qc = QuantumCircuit(2)
        qc.rz(0.75, 1)
        qc.rx(1.5, 2)

        dag = DAGCircuit(qc)
        nodes = collect(dag)

        rz_node = nodes[findfirst(n -> n.name == "rz", nodes)]
        @test rz_node.params == [0.75]
        @test rz_node.num_params == 1

        rx_node = nodes[findfirst(n -> n.name == "rx", nodes)]
        @test rx_node.params == [1.5]
        @test rx_node.num_params == 1
    end

    @testset "Base.show" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.measure(1, 1)

        dag = DAGCircuit(qc)

        io = IOBuffer()
        show(io, dag)
        output = String(take!(io))
        @test output == "DAGCircuit(2, 1; 2 nodes)"

        io = IOBuffer()
        show(io, MIME"text/plain"(), dag)
        output = String(take!(io))
        @test startswith(output, "DAGCircuit with 2 qubits, 1 clbits")
        @test contains(output, "nodes: 2")

        qk_dag_free(dag)
        io = IOBuffer()
        show(io, dag)
        @test String(take!(io)) == "DAGCircuit(NULL)"
    end

    @testset "Base.show text/plain NULL" begin
        qc = QuantumCircuit(2)
        dag = DAGCircuit(qc)
        qk_dag_free(dag)

        io = IOBuffer()
        show(io, MIME"text/plain"(), dag)
        @test String(take!(io)) == "DAGCircuit(NULL)"
    end

    @testset "Node show" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)

        dag = DAGCircuit(qc)
        nodes = collect(dag)

        h_node = nodes[findfirst(n -> n.name == "h", nodes)]
        io = IOBuffer()
        show(io, h_node)
        @test contains(String(take!(io)), "h")

        cx_node = nodes[findfirst(n -> n.name == "cx", nodes)]
        io = IOBuffer()
        show(io, cx_node)
        output = String(take!(io))
        @test contains(output, "cx")
        @test contains(output, "qubits")

        m_node = nodes[findfirst(n -> n.name == "measure", nodes)]
        io = IOBuffer()
        show(io, m_node)
        output = String(take!(io))
        @test contains(output, "measure")
        @test contains(output, "clbits")
    end

    @testset "propertynames" begin
        qc = QuantumCircuit(2)
        dag = DAGCircuit(qc)
        @test :num_qubits in propertynames(dag)
        @test :num_clbits in propertynames(dag)
        @test :num_op_nodes in propertynames(dag)

        nodes = collect(dag)
        if !isempty(nodes)
            @test :name in propertynames(nodes[1])
            @test :qubits in propertynames(nodes[1])
            @test :clbits in propertynames(nodes[1])
            @test :params in propertynames(nodes[1])
        end
    end

    @testset "DAGCircuit getfield fallback" begin
        qc = QuantumCircuit(2)
        dag = DAGCircuit(qc)
        @test dag.ptr isa Ptr
    end

    @testset "Low-level C API" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(1, 1)

        dag_ptr = qk_circuit_to_dag(qc.ptr)
        @test dag_ptr != C_NULL
        @test qk_dag_num_qubits(dag_ptr) == 2
        @test qk_dag_num_clbits(dag_ptr) == 1
        @test qk_dag_num_op_nodes(dag_ptr) == 3

        order = qk_dag_topological_op_nodes(dag_ptr)
        @test length(order) == 3

        qc2_ptr = qk_dag_to_circuit(dag_ptr)
        @test qc2_ptr != C_NULL

        qk_dag_free(dag_ptr)
    end

    @testset "qk_dag_new creates empty DAG" begin
        dag_ptr = qk_dag_new()
        @test dag_ptr != C_NULL
        @test qk_dag_num_qubits(dag_ptr) == 0
        @test qk_dag_num_clbits(dag_ptr) == 0
        @test qk_dag_num_op_nodes(dag_ptr) == 0
        qk_dag_free(dag_ptr)
    end

    @testset "Node type and operation kind" begin
        qc = QuantumCircuit(2)
        qc.h(1)
        qc.cx(1, 2)

        dag_ptr = qk_circuit_to_dag(qc.ptr)
        h_id = _dag_find_node_by_name(dag_ptr, "h")

        @test qk_dag_node_type(dag_ptr, h_id) == QkDagNodeType_Operation
        @test qk_dag_op_node_kind(dag_ptr, h_id) == QkOperationKind_Gate
        qk_dag_free(dag_ptr)
    end

    @testset "Node inspection functions" begin
        qc = QuantumCircuit(3, 2)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)
        qc.rz(0.5, 3)

        dag_ptr = qk_circuit_to_dag(qc.ptr)

        h_id = _dag_find_node_by_name(dag_ptr, "h")
        @test qk_dag_op_node_num_qubits(dag_ptr, h_id) == 1
        @test qk_dag_op_node_num_clbits(dag_ptr, h_id) == 0
        @test qk_dag_op_node_num_params(dag_ptr, h_id) == 0
        qubits = qk_dag_op_node_qubits(dag_ptr, h_id)
        @test length(qubits) == 1
        clbits = qk_dag_op_node_clbits(dag_ptr, h_id)
        @test isempty(clbits)

        rz_id = _dag_find_node_by_name(dag_ptr, "rz")
        @test qk_dag_op_node_num_qubits(dag_ptr, rz_id) == 1
        @test qk_dag_op_node_num_params(dag_ptr, rz_id) == 1

        m_id = _dag_find_node_by_name(dag_ptr, "measure")
        @test qk_dag_op_node_num_qubits(dag_ptr, m_id) == 1
        @test qk_dag_op_node_num_clbits(dag_ptr, m_id) == 1

        qk_dag_free(dag_ptr)
    end

    @testset "Gate operation" begin
        qc = QuantumCircuit(2)
        qc.h(1)
        qc.cx(1, 2)

        dag_ptr = qk_circuit_to_dag(qc.ptr)

        h_id = _dag_find_node_by_name(dag_ptr, "h")
        out_params = Vector{Float64}(undef, 8)
        gate = qk_dag_op_node_gate_op(dag_ptr, h_id, pointer(out_params))
        @test gate == QkGate_H

        qk_dag_free(dag_ptr)
    end

    @testset "Graph traversal" begin
        qc = QuantumCircuit(3)
        qc.h(1)
        qc.cx(1, 2)
        qc.cx(2, 3)

        dag_ptr = qk_circuit_to_dag(qc.ptr)

        h_id = _dag_find_node_by_name(dag_ptr, "h")
        succ = qk_dag_successors(dag_ptr, h_id)
        @test succ.num_neighbors > 0

        cx_id = _dag_find_node_by_name(dag_ptr, "cx")
        pred = qk_dag_predecessors(dag_ptr, cx_id)
        @test pred.num_neighbors > 0

        qk_dag_free(dag_ptr)
    end

    @testset "Wire node queries" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.measure(1, 1)

        dag_ptr = qk_circuit_to_dag(qc.ptr)

        qin = qk_dag_qubit_in_node(dag_ptr, UInt32(0))
        qout = qk_dag_qubit_out_node(dag_ptr, UInt32(0))
        @test qin isa UInt32
        @test qout isa UInt32
        @test qin != qout

        qk_dag_free(dag_ptr)
    end

    @testset "Wire node queries with clbits" begin
        qc = QuantumCircuit(2, 2)
        qc.measure(1, 1)
        qc.measure(2, 2)

        dag_ptr = qk_circuit_to_dag(qc.ptr)

        qin = qk_dag_qubit_in_node(dag_ptr, UInt32(0))
        qout = qk_dag_qubit_out_node(dag_ptr, UInt32(0))
        @test qin != qout

        cin = qk_dag_clbit_in_node(dag_ptr, UInt32(0))
        cout = qk_dag_clbit_out_node(dag_ptr, UInt32(0))
        @test cin != cout

        wire_val = qk_dag_wire_node_value(dag_ptr, qin)
        @test wire_val >= 0

        qk_dag_free(dag_ptr)
    end

    @testset "DAG mutation: apply operations" begin
        qc = QuantumCircuit(3, 2)
        dag_ptr = qk_circuit_to_dag(qc.ptr)

        h_id = qk_dag_apply_gate(dag_ptr, QkGate_H, UInt32[0], nothing, false)
        @test h_id isa UInt32
        @test qk_dag_num_op_nodes(dag_ptr) == 1

        cx_id = qk_dag_apply_gate(dag_ptr, QkGate_CX, UInt32[0, 1], nothing, false)
        @test qk_dag_num_op_nodes(dag_ptr) == 2

        rz_id = qk_dag_apply_gate(dag_ptr, QkGate_RZ, UInt32[2], Float64[0.5], false)
        @test qk_dag_num_op_nodes(dag_ptr) == 3

        meas_id = qk_dag_apply_measure(dag_ptr, UInt32(0), UInt32(0), false)
        @test qk_dag_num_op_nodes(dag_ptr) == 4

        reset_id = qk_dag_apply_reset(dag_ptr, UInt32(1), false)
        @test qk_dag_num_op_nodes(dag_ptr) == 5

        bar_id = qk_dag_apply_barrier(dag_ptr, UInt32[0, 1, 2], false)
        @test qk_dag_num_op_nodes(dag_ptr) == 6

        H_mat = ComplexF64[1 1; 1 -1] / sqrt(2)
        uid_id = qk_dag_apply_unitary(dag_ptr, H_mat, UInt32[0], false)
        @test qk_dag_num_op_nodes(dag_ptr) == 7

        order = qk_dag_topological_op_nodes(dag_ptr)
        @test length(order) == 7

        qk_dag_free(dag_ptr)
    end

    @testset "DAG mutation: apply_gate front" begin
        qc = QuantumCircuit(1)
        dag_ptr = qk_circuit_to_dag(qc.ptr)

        qk_dag_apply_gate(dag_ptr, QkGate_X, UInt32[0], nothing, false)
        qk_dag_apply_gate(dag_ptr, QkGate_H, UInt32[0], nothing, true)
        @test qk_dag_num_op_nodes(dag_ptr) == 2

        order = qk_dag_topological_op_nodes(dag_ptr)
        inst_ref = Ref(LibQiskit.QkCircuitInstruction(C_NULL, C_NULL, C_NULL, C_NULL, 0, 0, 0))
        LibQiskit.qk_dag_get_instruction(dag_ptr, order[1], inst_ref)
        first_name = unsafe_string(inst_ref[].name)
        LibQiskit.qk_circuit_instruction_clear(inst_ref)
        @test first_name == "h"

        qk_dag_free(dag_ptr)
    end

    @testset "DAG compose" begin
        qc1 = QuantumCircuit(2)
        qc1.h(1)

        qc2 = QuantumCircuit(2)
        qc2.cx(1, 2)

        dag1 = qk_circuit_to_dag(qc1.ptr)
        dag2 = qk_circuit_to_dag(qc2.ptr)

        qk_dag_compose(dag1, dag2, UInt32[0, 1], UInt32[])
        @test qk_dag_num_op_nodes(dag1) == 2

        qk_dag_free(dag1)
        qk_dag_free(dag2)
    end

    @testset "DAG substitute_node_with_unitary" begin
        qc = QuantumCircuit(1)
        qc.h(1)

        dag_ptr = qk_circuit_to_dag(qc.ptr)
        order = qk_dag_topological_op_nodes(dag_ptr)
        node_id = order[1]

        H = ComplexF64[1 1; 1 -1] / sqrt(2)
        qk_dag_substitute_node_with_unitary(dag_ptr, node_id, H, 1)
        @test qk_dag_num_op_nodes(dag_ptr) == 1

        qk_dag_free(dag_ptr)
    end

    @testset "DAG substitute_node_with_dag" begin
        qc = QuantumCircuit(1)
        qc.h(1)

        dag_ptr = qk_circuit_to_dag(qc.ptr)
        order = qk_dag_topological_op_nodes(dag_ptr)
        node_id = order[1]

        qc2 = QuantumCircuit(1)
        qc2.x(1)
        replacement = qk_circuit_to_dag(qc2.ptr)

        qk_dag_substitute_node_with_dag(dag_ptr, node_id, replacement)
        @test qk_dag_num_op_nodes(dag_ptr) == 1

        x_id = _dag_find_node_by_name(dag_ptr, "x")
        @test x_id !== nothing

        qk_dag_free(dag_ptr)
    end
end
