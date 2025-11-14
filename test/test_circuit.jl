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
    qc.unitary([0 -im; im 0], [1])
    qc.barrier()
    qc.measure(4, 1)
    qc.reset(4)
    @test qc.num_instructions == 8
    instructions = [instruction.name for instruction in qc.data]
    @test instructions == ["rz", "h", "xx_plus_yy", "delay", "unitary", "barrier", "measure", "reset"]
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
        @test instructions == ["rz", "cx", "unitary", "barrier", "measure", "reset"]
        @test qk_circuit_get_instruction(qc, 0).params == [0.25]
        @test qk_circuit_get_instruction(qc, 1).qubits == [0, 3]
        @test qk_circuit_get_instruction(qc, 4).clbits == [0]
    end
end
