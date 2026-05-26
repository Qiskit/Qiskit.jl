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
    @test instructions == ["rz", "h", "xx_plus_yy", "delay", "delay", "unitary", "barrier", "measure", "reset"]
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
    @testset "Zero-based indexing" begin
        qc = QuantumCircuit(4, 1, offset=0)
        @test qc.num_qubits == 4
        qc.rz(0.25, 0)
        qc.cx(0, 3)
        qc.delay(1, 4.0, QkDelayUnit_S)
        qc.unitary([0 -im; im 0], [0])
        qc.barrier(0, 1, 2, 3)
        qc.measure(3, 0)
        qc.reset(0)
        @test_throws ArgumentError qc.h(4)
        @test_throws ArgumentError qk_circuit_unitary(qc, [0 1; 1 0], [4])
        @test_throws ArgumentError qk_circuit_barrier(qc, [1, 2, 3, 4])
        @test_throws ArgumentError qk_circuit_measure(qc, 4, 0)
        @test_throws ArgumentError qk_circuit_measure(qc, 3, 1)
        @test_throws ArgumentError qk_circuit_reset(qc, 4)
        instructions = [instruction.name for instruction in qc.data]
        @test instructions == ["rz", "cx", "delay", "unitary", "barrier", "measure", "reset"]
        @test qk_circuit_get_instruction(qc, 0).params == [0.25]
        @test qk_circuit_get_instruction(qc, 1).qubits == [0, 3]
        @test qk_circuit_get_instruction(qc, 2).params == [4.0]
        @test qk_circuit_get_instruction(qc, 5).clbits == [0]
    end

    @testset "Base.show method" begin
        qc = QuantumCircuit(2, 1)
        io = IOBuffer()
        show(io, qc)
        output = String(take!(io))
        @test contains(output, "QuantumCircuit")
        @test contains(output, "num_qubits=2")
        @test contains(output, "num_clbits=1")
        @test contains(output, "num_instructions=0")

        # Test with instructions
        qc.h(1)
        io = IOBuffer()
        show(io, qc)
        output = String(take!(io))
        @test contains(output, "num_instructions=1")

        # Test with empty circuit (offset=0)
        qc_zero = QuantumCircuit(3, 0, offset=0)
        io = IOBuffer()
        show(io, qc_zero)
        output = String(take!(io))
        @test contains(output, "QuantumCircuit")
        @test contains(output, "num_qubits=3")
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
        @test_throws ArgumentError qc.delay(1, 1 * Unitful.m)
    end
end
