# This code is part of Qiskit.
#
# (C) Copyright IBM 2026.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

# A Clifford + T/RZ circuit, which is what the Litinski transformation accepts.
function build_clifford_t_circuit()
    qc = QuantumCircuit(3, 3)
    qc.h(1)
    qc.cx(1, 2)
    qc.t(2)
    qc.rz(0.37, 3)
    qc.cx(2, 3)
    qc.t(1)
    qc.measure(1, 1)
    qc.measure(2, 2)
    qc.measure(3, 3)
    qc
end

@testset "PauliProduct" begin
    p = PauliProduct(Bool[0, 1, 1], Bool[1, 0, 1], [1, 2, 3])
    @test pauli_label(p) == "XZY"
    @test p.qubits == [1, 2, 3]
    @test p.num_qubits == 3
    @test length(p) == 3
    @test p.z == Bool[0, 1, 1]
    @test p.x == Bool[1, 0, 1]
    @test pauli_label(PauliProduct(Bool[0], Bool[0], [1])) == "I"
    # The support may be narrower than the circuit the operator came from.
    @test pauli_label(PauliProduct(Bool[1], Bool[0], [3])) == "Z"
    @test_throws ArgumentError PauliProduct(Bool[0, 1], Bool[1], [1, 2])
    @test_throws ArgumentError PauliProduct(Bool[0], Bool[1], [1, 2])
end

@testset "litinski_transformation!" begin
    qc = build_clifford_t_circuit()
    @test litinski_transformation!(qc) === qc
    insts = pauli_product_instructions(qc)
    @test length(insts) == 6
    @test count(i -> i isa PauliProductRotation, insts) == 3
    @test count(i -> i isa PauliProductMeasurement, insts) == 3

    rotations = filter(i -> i isa PauliProductRotation, insts)
    @test pauli_label.(getproperty.(rotations, :pauli)) == ["X", "XZ", "Z"]
    @test getproperty.(rotations, :qubits) == [[1], [1, 2], [3]]
    # The two T gates become pi/4 rotations; the RZ keeps its own angle.
    @test rotations[1].angle ≈ pi / 4
    @test rotations[2].angle ≈ pi / 4
    @test rotations[3].angle ≈ 0.37

    measurements = filter(i -> i isa PauliProductMeasurement, insts)
    @test pauli_label.(getproperty.(measurements, :pauli)) == ["X", "XZ", "XZZ"]
    @test getproperty.(measurements, :clbit) == [1, 2, 3]
    @test all(i -> !i.flip_outcome, measurements)

    # The support size tracks the qubits each instruction acts on.
    @test [i.num_qubits for i in insts] == [1, 2, 1, 1, 2, 3]
    @test all(i -> length(i.pauli.z) == i.num_qubits, insts)
end

@testset "litinski_transformation! with fix_clifford" begin
    qc = QuantumCircuit(2, 0)
    qc.h(1)
    qc.t(1)
    qc.cx(1, 2)
    litinski_transformation!(qc; fix_clifford=true)
    # The Clifford gates are retained, so only the T becomes Pauli-based.
    insts = pauli_product_instructions(qc)
    @test length(insts) == 1
    @test insts[1] isa PauliProductRotation
    @test pauli_label(insts[1].pauli) == "X"
    @test qk_circuit_num_instructions(qc) > length(insts)
end

@testset "convert_to_pauli_rotations!" begin
    qc = QuantumCircuit(2, 1)
    qc.h(1)
    qc.cx(1, 2)
    qc.measure(2, 1)
    @test convert_to_pauli_rotations!(qc) === qc
    insts = pauli_product_instructions(qc)
    @test length(insts) == qk_circuit_num_instructions(qc)
    @test insts[end] isa PauliProductMeasurement
    @test insts[end].clbit == 1
    @test pauli_label(insts[end].pauli) == "Z"
end

@testset "instruction kinds and single-instruction access" begin
    qc = build_clifford_t_circuit()
    litinski_transformation!(qc)
    @test qk_circuit_instruction_kind(qc, 1) ===
          Qiskit.LibQiskit.QkOperationKind_PauliProductRotation
    @test qk_circuit_instruction_kind(qc, 4) ===
          Qiskit.LibQiskit.QkOperationKind_PauliProductMeasurement

    rot = pauli_product_instruction(qc, 2)
    @test rot isa PauliProductRotation
    @test rot == Qiskit.qk_circuit_inst_pauli_product_rotation(qc, 2)
    @test pauli_label(rot.pauli) == "XZ"
    @test rot.qubits == [1, 2]

    meas = pauli_product_instruction(qc, 6)
    @test meas isa PauliProductMeasurement
    @test meas == Qiskit.qk_circuit_inst_pauli_product_measurement(qc, 6)
    @test meas.num_qubits == 3

    # Equal reads of the same instruction compare and hash as values.
    @test hash(rot) == hash(Qiskit.qk_circuit_inst_pauli_product_rotation(qc, 2))
    @test hash(meas) == hash(Qiskit.qk_circuit_inst_pauli_product_measurement(qc, 6))
    @test rot != pauli_product_instruction(qc, 3)
    @test rot.pauli == PauliProduct(Bool[0, 1], Bool[1, 0], [1, 2])

    # Asking for the wrong kind is an error, as is an out-of-range index.
    @test_throws ArgumentError Qiskit.qk_circuit_inst_pauli_product_measurement(qc, 1)
    @test_throws ArgumentError Qiskit.qk_circuit_inst_pauli_product_rotation(qc, 4)
    @test_throws ArgumentError pauli_product_instruction(qc, 0)
    @test_throws ArgumentError pauli_product_instruction(qc, 7)
end

@testset "circuits with no Pauli-based instructions" begin
    qc = QuantumCircuit(1, 0)
    @test isempty(pauli_product_instructions(qc))
    qc.h(1)
    @test isempty(pauli_product_instructions(qc))
    @test_throws ArgumentError pauli_product_instruction(qc, 1)
end

@testset "Base.show" begin
    qc = build_clifford_t_circuit()
    litinski_transformation!(qc)
    @test sprint(show, pauli_product_instruction(qc, 3)) ==
          "PauliProductRotation(\"Z\", [3], 0.37)"
    @test sprint(show, pauli_product_instruction(qc, 6)) ==
          "PauliProductMeasurement(\"XZZ\", [1, 2, 3], clbit=3)"
    @test sprint(show, PauliProduct(Bool[1], Bool[1], [2])) == "PauliProduct(\"Y\", [2])"
end
