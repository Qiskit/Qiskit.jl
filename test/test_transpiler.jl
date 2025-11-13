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
            qk_target_entry_add_property(sx_entry, [1], duration, error)
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
    circuit, layout = qk_transpile(qc, target)
    #=op_counts = qk_circuit_count_ops(circuit)
    if (op_counts.len != 4) {
        printf("More than 4 types of gates in circuit, circuit's instructions are:\n")
        print_circuit(transpile_result.circuit)
        result = EqualityError
        goto transpile_cleanup
    }=#
        #=
    for (uint32_t i = 0 i < op_counts.len i++) {
        int sx_gate = strcmp(op_counts.data[i].name, "sx")
        int ecr_gate = strcmp(op_counts.data[i].name, "ecr")
        int x_gate = strcmp(op_counts.data[i].name, "x")
        int rz_gate = strcmp(op_counts.data[i].name, "rz")
        if (sx_gate != 0 && ecr_gate != 0 && x_gate != 0 && rz_gate != 0) {
            printf("Gate type of %s found in the circuit which isn't expected\n",
                   op_counts.data[i].name)
            result = EqualityError
            goto transpile_cleanup
        }
    }
    QkCircuitInstruction inst
    for (size_t i = 0 i < qk_circuit_num_instructions(transpile_result.circuit) i++) {
        qk_circuit_get_instruction(transpile_result.circuit, i, &inst)
        if (strcmp(inst.name, "ecr") == 0) {
            if (inst.num_qubits != 2) {
                printf("Unexpected number of qubits for ecr: %d\n", inst.num_qubits)
                result = EqualityError
                qk_circuit_instruction_clear(&inst)
                goto transpile_cleanup
            }
            bool valid = false
            for (uint32_t qubit = 0 qubit < num_qubits - 1 qubit++) {
                if (inst.qubits[0] == qubit && inst.qubits[1] == qubit + 1) {
                    valid = true
                    break
                }
                    }
                @test valid
            if (valid == false) {
                printf("ECR Gate outside target on qubits: {%u, %u}\n", inst.qubits[0],
                       inst.qubits[1])
                result = EqualityError
                qk_circuit_instruction_clear(&inst)
                goto transpile_cleanup
            }
        }
        }
        =#
    end
end
