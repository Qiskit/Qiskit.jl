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

@testset "Transpiler" begin
    @testset "transpile_bv" begin
        # Julia translation of qiskit-sdk/test/c/test_transpiler.c
        num_qubits = 10
        target = Qiskit.Target(num_qubits)

        x_entry = Qiskit.target_entry_gate(QkGate_X)
        for i in 1:num_qubits
            error = 0.8e-6 * i
            duration = 1.8e-9 * i
            qk_target_entry_add_property(x_entry, [i], duration, error)
        end
        qk_target_add_instruction(target, x_entry)

        sx_entry = Qiskit.target_entry_gate(QkGate_SX)
        for i in 1:num_qubits
            error = 0.8e-6 * i
            duration = 1.8e-9 * i
            qk_target_entry_add_property(sx_entry, [i], duration, error)
        end
        qk_target_add_instruction(target, sx_entry)

        rz_entry = Qiskit.target_entry_gate(QkGate_RZ)
        for i in 1:num_qubits
            error = 0.0
            duration = 0.0
            qk_target_entry_add_property(rz_entry, [i], duration, error)
        end
        qk_target_add_instruction(target, rz_entry)

        ecr_entry = Qiskit.target_entry_gate(QkGate_ECR)
        for i in 1:num_qubits-1
            inst_error = 0.0090393 * (num_qubits - i + 1)
            inst_duration = 0.020039
            qk_target_entry_add_property(ecr_entry, [i, i + 1], inst_duration, inst_error)
        end
        qk_target_add_instruction(target, ecr_entry)

        qc = QuantumCircuit(num_qubits)
        qc.x(10)
        for i in 1:num_qubits
            qc.h(i)
        end
        for i in 1:2:num_qubits-1
            qc.cx(i, num_qubits)
        end
        #QkTranspileOptions options = qk_transpiler_default_options()
        #options.seed = 42
        transpile_result = transpile(qc, target)
        op_counts = qk_circuit_count_ops(transpile_result.circuit)
        @test length(op_counts) == 4
        op_count_set = Set([name for (name, _) in op_counts])
        @test op_count_set == Set(["sx", "ecr", "x", "rz"])
        num_instructions = qk_circuit_num_instructions(transpile_result.circuit)
        for i in 1:num_instructions
            inst = qk_circuit_get_instruction(transpile_result.circuit, i)
            if inst.name == "ecr"
                @test inst.num_qubits == 2
                @test inst.qubits[1] ∈ 1:num_qubits
                @test inst.qubits[2] ∈ 1:num_qubits
                @test inst.qubits[1] + 1 == inst.qubits[2]
            end
        end
    end
end
