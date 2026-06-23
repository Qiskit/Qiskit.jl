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

using Qiskit.Operations

@testset "Operations (`!` interface)" begin
    @testset "Bell state matches property style" begin
        # Property-style (Python-like) construction.
        qc_prop = QuantumCircuit(2, 2)
        qc_prop.h(1)
        qc_prop.cx(1, 2)
        qc_prop.measure(1, 1)
        qc_prop.measure(2, 2)

        # Operations-style (`!`) construction.
        qc_ops = QuantumCircuit(2, 2)
        h!(qc_ops, 1)
        cx!(qc_ops, 1, 2)
        measure!(qc_ops, 1, 1)
        measure!(qc_ops, 2, 2)

        @test [i.name for i in qc_ops.data] == [i.name for i in qc_prop.data]
        @test qc_ops.num_instructions == qc_prop.num_instructions
    end

    @testset "qualified Qiskit.* access without `using Qiskit.Operations`" begin
        # The `!` functions live in `Qiskit` itself, so they can be used
        # fully-qualified without bringing the bare names into scope. This
        # exercises several operation kinds: gates, reset!, measure!, barrier!.
        qc = QuantumCircuit(2, 2)
        Qiskit.h!(qc, 1)
        Qiskit.cx!(qc, 1, 2)
        Qiskit.barrier!(qc)
        Qiskit.reset!(qc, 1)
        Qiskit.measure!(qc, 1, 1)
        Qiskit.measure!(qc, 2, 2)
        @test [i.name for i in qc.data] ==
              ["h", "cx", "barrier", "reset", "measure", "measure"]
    end

    @testset "parametric gate argument order (params first, then qubits)" begin
        qc_prop = QuantumCircuit(1)
        qc_prop.rz(0.25, 1)
        qc_ops = QuantumCircuit(1)
        rz!(qc_ops, 0.25, 1)
        @test [i.name for i in qc_ops.data] == [i.name for i in qc_prop.data]
    end

    @testset "one-off operations" begin
        qc = QuantumCircuit(2, 1)
        barrier!(qc)
        unitary!(qc, [0 1; 1 0], [1])
        reset!(qc, 2)
        measure!(qc, 1, 1)
        @test [i.name for i in qc.data] == ["barrier", "unitary", "reset", "measure"]
    end

    @testset "Unitful delay!" begin
        qc = QuantumCircuit(1)
        delay!(qc, 1, 2.5 * Unitful.μs)
        @test qc.data[1].name == "delay"
        @test_throws ArgumentError delay!(qc, 1, 1 * Unitful.Ms)
    end

    # The gate arities in GATE_TABLE are hardcoded (the C API cannot report
    # them). Validate every entry against the C library by building one
    # instruction per gate and reading back the resulting CircuitInstruction.
    @testset "GATE_TABLE arities match the C library" begin
        for (name, _gate, nq, np) in Qiskit.GATE_TABLE
            qc = QuantumCircuit(nq)
            # params first (zeros), then qubits 1:nq
            getproperty(qc, name)(zeros(np)..., (1:nq)...)
            inst = qc.data[1]
            @test inst.num_qubits == nq
            @test inst.num_params == np
        end
    end
end
