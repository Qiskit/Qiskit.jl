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

@testset "Circuit" begin
    qc = QuantumCircuit(4, 1)
    @test qc.num_qubits == 4
    @test qc.num_clbits == 1
    @test qc.num_instructions == 0
    qc.rz(0.25, 4)
    qc.h(2)
    qk_circuit_gate(qc, QkGate_XXPlusYY, [2, 3], [0.3, 0])
    qk_circuit_delay(qc, 1, 1, QkDelayUnit_NS)
    qc.delay(2, 2.5, QkDelayUnit_US)
    qc.unitary([0 -im; im 0], [1])
    qc.barrier()
    qc.measure(4, 1)
    qc.reset(4)
    @test qc.num_instructions == 9
    instructions = [instruction.name for instruction in qc.data]
    @test instructions == [
        "rz",
        "h",
        "xx_plus_yy",
        "delay",
        "delay",
        "unitary",
        "barrier",
        "measure",
        "reset",
    ]
    expected_op_counts = Dict(
        "rz" => 1,
        "h" => 1,
        "xx_plus_yy" => 1,
        "delay" => 2,
        "unitary" => 1,
        "barrier" => 1,
        "measure" => 1,
        "reset" => 1,
    )
    @test Dict(qk_circuit_count_ops(qc)) == expected_op_counts
    @test qc.count_ops() == expected_op_counts
    @test qk_circuit_get_instruction(qc, 1).params == [0.25]
    @test qk_circuit_get_instruction(qc, 3).params == [0.3, 0]
    @test qk_circuit_get_instruction(qc, 3).qubits == [2, 3]
    qc_copy = copy(qc)
    @test qc_copy.num_qubits == qc.num_qubits
    @test qc_copy.num_clbits == qc.num_clbits
    @test qc_copy.num_instructions == qc.num_instructions

    @testset "Qubit and clbit index bounds" begin
        qc = QuantumCircuit(4, 1)
        @test_throws ArgumentError qc.h(0)
        @test_throws ArgumentError qc.h(5)
        @test_throws ArgumentError qk_circuit_unitary(qc, [0 1; 1 0], [5])
        @test_throws ArgumentError qk_circuit_barrier(qc, [2, 3, 4, 5])
        @test_throws ArgumentError qk_circuit_measure(qc, 5, 1)
        @test_throws ArgumentError qk_circuit_measure(qc, 4, 2)
        @test_throws ArgumentError qk_circuit_reset(qc, 5)
        @test_throws ArgumentError qk_circuit_get_instruction(qc, 0)
    end

    @testset "data is a 1-based AbstractVector" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)
        data = qc.data
        @test firstindex(data) == 1
        @test lastindex(data) == 3
        @test eachindex(data) == 1:3
        @test axes(data) == (Base.OneTo(3),)
        # Iteration, `collect` and indexing must agree; they take different
        # paths through the `AbstractArray` interface.
        @test [inst.name for inst in data] == ["h", "cx", "measure"]
        @test [inst.name for inst in collect(data)] == ["h", "cx", "measure"]
        @test [data[i].name for i in eachindex(data)] == ["h", "cx", "measure"]
        @test data[1].qubits == [1]
        @test data[2].qubits == [1, 2]
        @test data[3].clbits == [1]
    end

    @testset "Base.show" begin
        qc = QuantumCircuit(2, 1)

        # Compact form: positional constructor args, instruction count annotated after `;`
        io = IOBuffer()
        show(io, qc)
        output = String(take!(io))
        @test output == "QuantumCircuit(2, 1; 0 instructions)"

        # Compact form reflects current instruction count
        qc.h(1)
        io = IOBuffer()
        show(io, qc)
        @test String(take!(io)) == "QuantumCircuit(2, 1; 1 instructions)"

        # text/plain form for REPL display
        io = IOBuffer()
        show(io, MIME"text/plain"(), qc)
        output = String(take!(io))
        @test startswith(output, "QuantumCircuit with 2 qubits, 1 clbits")
        @test contains(output, "instructions: 1")

        # NULL path (after explicit free)
        qc_freed = QuantumCircuit(3, 0)
        qk_circuit_free(qc_freed)
        io = IOBuffer()
        show(io, qc_freed)
        @test String(take!(io)) == "QuantumCircuit(NULL)"
    end

    @testset "Unitful support" begin
        qc = QuantumCircuit(4, 0)

        # Test supported units
        qc.delay(1, 1.5 * Unitful.s)
        qc.delay(2, 500 * Unitful.ms)
        qc.delay(3, 10 * Unitful.μs)
        qc.delay(4, 5 * Unitful.ns)
        qc.delay(1, 100 * Unitful.ps)

        @test qc.num_instructions == 5
        @test qc.data[1].name == "delay"
        @test qc.data[1].params == [1.5]
        @test qc.data[2].params == [500.0]
        @test qc.data[3].params == [10.0]
        @test qc.data[4].params == [5.0]
        @test qc.data[5].params == [100.0]
        @test_throws ArgumentError qc.delay(1, 1 * Unitful.Ms)
    end

    @testset "Unitary interface" begin
        qc = QuantumCircuit(3, 0)

        # single-qubit via vector
        qc.unitary([0 1; 1 0], [1])
        @test qc.num_instructions == 1
        @test qc.data[1].name == "unitary"
        @test qc.data[1].qubits == [1]

        # single-qubit via scalar
        qc.unitary([0 -im; im 0], 2)
        @test qc.num_instructions == 2
        @test qc.data[2].name == "unitary"
        @test qc.data[2].qubits == [2]

        # two-qubit unitary (CNOT as dense matrix)
        cnot = [1 0 0 0; 0 0 0 1; 0 0 1 0; 0 1 0 0]
        qc.unitary(cnot, [1, 2])
        @test qc.num_instructions == 3
        @test qc.data[3].name == "unitary"
        @test qc.data[3].qubits == [1, 2]

        # check_input keyword forwarded
        non_unitary = [1.0 1.0; 0.0 1.0]
        qc.unitary(non_unitary, [3]; check_input=false)
        @test qc.num_instructions == 4

        # check_input=true enforces unitarity; expects clean error, not panic
        @test_throws ErrorException qc.unitary(non_unitary, [3]; check_input=true)
        @test qc.num_instructions == 4

        # wrong matrix size throws
        @test_throws ArgumentError qk_circuit_unitary(qc, [1 0; 0 1], [1, 2])

        # out-of-range qubit throws
        @test_throws ArgumentError qc.unitary([0 1; 1 0], [4])
        @test_throws ArgumentError qc.unitary([0 1; 1 0], 4)
    end
end
