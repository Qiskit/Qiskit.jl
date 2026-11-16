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

@testset "unsupported instructions are rejected rather than aborting" begin
    # Without this guard the pass aborts the whole process
    # (https://github.com/Qiskit/qiskit/issues/17179), so these must throw.
    for (name, build!) in (
        ("u", qc -> u!(qc, 0.1, 0.2, 0.3, 2)),
        ("ccx", qc -> ccx!(qc, 1, 2, 3)),
        ("barrier", qc -> barrier!(qc)),
        ("reset", qc -> reset!(qc, 2)),
        ("delay", qc -> delay!(qc, 2, 100.0, QkDelayUnit_NS)),
    )
        qc = QuantumCircuit(3, 1)
        t!(qc, 1)  # a handled gate, so the pass would not skip the circuit
        build!(qc)
        @test_throws ArgumentError litinski_transformation!(qc)
        # The circuit is left untouched when the guard rejects it.
        @test any(op -> first(op) == name, qk_circuit_count_ops(qc))
    end
end

@testset "supported instruction list matches the pass" begin
    # The guard duplicates the pass's own list of supported instructions, so
    # check that every name in it is genuinely accepted.  If the pass drops
    # support for one of them, this aborts the test process rather than letting
    # the guard wave through a circuit that would abort in a user's session.
    #
    # The reverse direction -- the pass gaining support for an instruction the
    # guard still rejects -- is deliberately not covered here; see the comment
    # on `LITINSKI_SUPPORTED_OPERATIONS`.
    builders = Dict(
        "id" => qc -> id!(qc, 1),
        "x" => qc -> x!(qc, 1),
        "y" => qc -> y!(qc, 1),
        "z" => qc -> z!(qc, 1),
        "h" => qc -> h!(qc, 1),
        "s" => qc -> s!(qc, 1),
        "sdg" => qc -> sdg!(qc, 1),
        "sx" => qc -> sx!(qc, 1),
        "sxdg" => qc -> sxdg!(qc, 1),
        "cx" => qc -> cx!(qc, 1, 2),
        "cz" => qc -> cz!(qc, 1, 2),
        "cy" => qc -> cy!(qc, 1, 2),
        "swap" => qc -> swap!(qc, 1, 2),
        "iswap" => qc -> iswap!(qc, 1, 2),
        "ecr" => qc -> ecr!(qc, 1, 2),
        "dcx" => qc -> dcx!(qc, 1, 2),
        "t" => qc -> t!(qc, 1),
        "tdg" => qc -> tdg!(qc, 1),
        "rz" => qc -> rz!(qc, 0.3, 1),
        "rx" => qc -> rx!(qc, 0.3, 1),
        "ry" => qc -> ry!(qc, 0.3, 1),
        "p" => qc -> p!(qc, 0.3, 1),
        "measure" => qc -> measure!(qc, 1, 1),
    )
    # Every supported name is either covered by a builder above or is produced
    # by the pass itself (`u1` has no `!` function; the Pauli-based kinds are
    # exercised by the round-trip test below).
    uncovered = setdiff(
        Qiskit.LITINSKI_SUPPORTED_OPERATIONS,
        union(
            keys(builders),
            ["u1", "pauli_product_rotation", "pauli_product_measurement"],
        ),
    )
    @test isempty(uncovered)

    for (name, build!) in builders
        qc = QuantumCircuit(2, 1)
        t!(qc, 1)  # ensure the pass does not skip the circuit
        build!(qc)
        # Must not throw, and must not abort: reaching the next line is the test.
        @test litinski_transformation!(qc) === qc
    end

    # A circuit already in Pauli-based form is still accepted, which covers the
    # two `pauli_product_*` names.
    qc = QuantumCircuit(2, 1)
    t!(qc, 1)
    measure!(qc, 1, 1)
    litinski_transformation!(qc)
    @test !isempty(pauli_product_instructions(qc))
    @test litinski_transformation!(qc) === qc
end

# Runs `body` in a fresh Julia process that calls the C pass directly, bypassing
# the guard, and reports how the process ended.  `survived` distinguishes a
# clean run from one killed by the panic, so a test cannot pass merely because
# the subprocess failed to start.
function probe_unguarded_litinski(body::AbstractString)
    project = dirname(Base.active_project())
    code = """
    using Qiskit
    using Qiskit.Operations
    using Qiskit: LibQiskit
    qc = QuantumCircuit(3, 1)
    $body
    LibQiskit.qk_transpiler_pass_standalone_litinski_transformation(
        getfield(qc, :ptr),
        false,
    )
    println("SURVIVED")
    """
    cmd = `$(Base.julia_cmd()) --startup-file=no --project=$project -e $code`
    output = Pipe()
    process = run(pipeline(cmd; stdout=output, stderr=devnull); wait=false)
    close(output.in)
    printed = read(output, String)
    wait(process)
    return (
        survived=occursin("SURVIVED", printed),
        termsignal=process.termsignal,
        exitcode=process.exitcode,
    )
end

@testset "guard is still needed" begin
    # This asserts the upstream behavior the guard exists to work around
    # (https://github.com/Qiskit/qiskit/issues/17179): calling the pass directly
    # with an unsupported instruction kills the process.
    #
    # It is expected to FAIL once that issue is fixed, and that failure is the
    # intended signal that this guard, its duplicated instruction list, and this
    # test can all be deleted.
    unsupported = probe_unguarded_litinski("t!(qc, 1)\n    u!(qc, 0.1, 0.2, 0.3, 2)")
    @test !unsupported.survived
    @test unsupported.termsignal != 0

    # Control: the same call path with only supported instructions runs to
    # completion, so the assertions above are about the unsupported instruction
    # rather than a subprocess that could not start.
    supported = probe_unguarded_litinski("t!(qc, 1)\n    h!(qc, 2)")
    @test supported.survived
    @test supported.termsignal == 0
    @test supported.exitcode == 0
end
