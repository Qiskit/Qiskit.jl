module LibQiskit

using Qiskit_jll
export Qiskit_jll

using CEnum: CEnum, @cenum

struct QkComplex64
    re::Cdouble
    im::Cdouble
end

function qk_complex64_to_native(value)
    ccall((:qk_complex64_to_native, libqiskit), ComplexF32, (Ptr{QkComplex64},), value)
end

function qk_complex64_from_native(value)
    ccall((:qk_complex64_from_native, libqiskit), QkComplex64, (Ptr{ComplexF32},), value)
end

@cenum QkExitCode::UInt32 begin
    QkExitCode_Success = 0
    QkExitCode_CInputError = 100
    QkExitCode_NullPointerError = 101
    QkExitCode_AlignmentError = 102
    QkExitCode_IndexError = 103
    QkExitCode_DuplicateIndexError = 104
    QkExitCode_InvalidOperationKind = 105
    QkExitCode_ArithmeticError = 200
    QkExitCode_MismatchedQubits = 201
    QkExitCode_ExpectedUnitary = 202
    QkExitCode_TargetError = 300
    QkExitCode_TargetInstAlreadyExists = 301
    QkExitCode_TargetQargMismatch = 302
    QkExitCode_TargetInvalidQargsKey = 303
    QkExitCode_TargetInvalidInstKey = 304
    QkExitCode_TranspilerError = 400
    QkExitCode_DagError = 500
    QkExitCode_DagComposeMismatch = 501
    QkExitCode_DagComposeMissingBit = 502
    QkExitCode_ParameterError = 600
    QkExitCode_ParameterNameConflict = 601
end

@cenum QkGate::UInt32 begin
    QkGate_GlobalPhase = 0
    QkGate_H = 1
    QkGate_I = 2
    QkGate_X = 3
    QkGate_Y = 4
    QkGate_Z = 5
    QkGate_Phase = 6
    QkGate_R = 7
    QkGate_RX = 8
    QkGate_RY = 9
    QkGate_RZ = 10
    QkGate_S = 11
    QkGate_Sdg = 12
    QkGate_SX = 13
    QkGate_SXdg = 14
    QkGate_T = 15
    QkGate_Tdg = 16
    QkGate_U = 17
    QkGate_U1 = 18
    QkGate_U2 = 19
    QkGate_U3 = 20
    QkGate_CH = 21
    QkGate_CX = 22
    QkGate_CY = 23
    QkGate_CZ = 24
    QkGate_DCX = 25
    QkGate_ECR = 26
    QkGate_Swap = 27
    QkGate_ISwap = 28
    QkGate_CPhase = 29
    QkGate_CRX = 30
    QkGate_CRY = 31
    QkGate_CRZ = 32
    QkGate_CS = 33
    QkGate_CSdg = 34
    QkGate_CSX = 35
    QkGate_CU = 36
    QkGate_CU1 = 37
    QkGate_CU3 = 38
    QkGate_RXX = 39
    QkGate_RYY = 40
    QkGate_RZZ = 41
    QkGate_RZX = 42
    QkGate_XXMinusYY = 43
    QkGate_XXPlusYY = 44
    QkGate_CCX = 45
    QkGate_CCZ = 46
    QkGate_CSwap = 47
    QkGate_RCCX = 48
    QkGate_C3X = 49
    QkGate_C3SX = 50
    QkGate_RC3X = 51
end

@cenum QkOperationKind::UInt32 begin
    QkOperationKind_Gate = 0
    QkOperationKind_Barrier = 1
    QkOperationKind_Delay = 2
    QkOperationKind_Measure = 3
    QkOperationKind_Reset = 4
    QkOperationKind_Unitary = 5
    QkOperationKind_PauliProductMeasurement = 6
    QkOperationKind_ControlFlow = 7
    QkOperationKind_Unknown = 8
    QkOperationKind_PauliProductRotation = 9
end

@cenum QkDelayUnit::UInt32 begin
    QkDelayUnit_S = 0
    QkDelayUnit_MS = 1
    QkDelayUnit_US = 2
    QkDelayUnit_NS = 3
    QkDelayUnit_PS = 4
end

@cenum QkVarsMode::UInt32 begin
    QkVarsMode_Alike = 0
    QkVarsMode_Captures = 1
    QkVarsMode_Drop = 2
end

@cenum QkBlocksMode::UInt32 begin
    QkBlocksMode_Drop = 0
    QkBlocksMode_Keep = 1
end

@cenum QkDagNodeType::UInt32 begin
    QkDagNodeType_Operation = 0
    QkDagNodeType_QubitIn = 1
    QkDagNodeType_QubitOut = 2
    QkDagNodeType_ClbitIn = 3
    QkDagNodeType_ClbitOut = 4
    QkDagNodeType_VarIn = 5
    QkDagNodeType_VarOut = 6
end

@cenum QkBitTerm::UInt32 begin
    QkBitTerm_X = 2
    QkBitTerm_Plus = 10
    QkBitTerm_Minus = 6
    QkBitTerm_Y = 3
    QkBitTerm_Right = 11
    QkBitTerm_Left = 7
    QkBitTerm_Z = 1
    QkBitTerm_Zero = 9
    QkBitTerm_One = 5
end

mutable struct QkCircuit end

mutable struct QkClassicalRegister end

mutable struct QkDag end

mutable struct QkParam end

mutable struct QkQuantumRegister end

mutable struct QkObs end

mutable struct QkTarget end

mutable struct QkTargetEntry end

mutable struct QkTranspileLayout end

mutable struct QkTranspilerStageState end

mutable struct QkVF2LayoutConfiguration end

mutable struct QkVF2LayoutResult end

struct QkOpCount
    name::Ptr{Cchar}
    count::Csize_t
end

struct QkOpCounts
    data::Ptr{QkOpCount}
    len::Csize_t
end

struct QkCircuitInstruction
    name::Ptr{Cchar}
    qubits::Ptr{UInt32}
    clbits::Ptr{UInt32}
    params::Ptr{Ptr{QkParam}}
    num_qubits::UInt32
    num_clbits::UInt32
    num_params::UInt32
end

struct QkPauliProductRotation
    z::Ptr{Bool}
    x::Ptr{Bool}
    len::Csize_t
    angle::Ptr{QkParam}
end

struct QkPauliProductMeasurement
    z::Ptr{Bool}
    x::Ptr{Bool}
    len::Csize_t
    flip_outcome::Bool
end

struct QkCircuitDrawerConfig
    bundle_cregs::Bool
    merge_wires::Bool
    fold::Csize_t
end

struct QkDagNeighbors
    neighbors::Ptr{UInt32}
    num_neighbors::Csize_t
end

struct QkObsTerm
    coeff::QkComplex64
    len::Csize_t
    bit_terms::Ptr{QkBitTerm}
    indices::Ptr{UInt32}
    num_qubits::UInt32
end

struct QkNeighbors
    neighbors::Ptr{UInt32}
    partition::Ptr{Csize_t}
    num_qubits::UInt32
end

struct QkSabreLayoutOptions
    max_iterations::Csize_t
    num_swap_trials::Csize_t
    num_random_trials::Csize_t
    seed::UInt64
end

struct QkInstructionProperties
    duration::Cdouble
    error::Cdouble
end

struct QkTargetOp
    op_type::QkOperationKind
    name::Ptr{Cchar}
    num_qubits::UInt32
    params::Ptr{Ptr{QkParam}}
    num_params::UInt32
end

struct QkTranspileOptions
    optimization_level::UInt8
    seed::Int64
    approximation_degree::Cdouble
end

struct QkTranspileResult
    circuit::Ptr{QkCircuit}
    layout::Ptr{QkTranspileLayout}
end

function qk_api_version()
    ccall((:qk_api_version, libqiskit), UInt32, ())
end

function qk_circuit_new(num_qubits, num_clbits)
    ccall((:qk_circuit_new, libqiskit), Ptr{QkCircuit}, (UInt32, UInt32), num_qubits, num_clbits)
end

function qk_quantum_register_new(num_qubits, name)
    ccall((:qk_quantum_register_new, libqiskit), Ptr{QkQuantumRegister}, (UInt32, Ptr{Cchar}), num_qubits, name)
end

function qk_quantum_register_free(reg)
    ccall((:qk_quantum_register_free, libqiskit), Cvoid, (Ptr{QkQuantumRegister},), reg)
end

function qk_classical_register_free(reg)
    ccall((:qk_classical_register_free, libqiskit), Cvoid, (Ptr{QkClassicalRegister},), reg)
end

function qk_classical_register_new(num_clbits, name)
    ccall((:qk_classical_register_new, libqiskit), Ptr{QkClassicalRegister}, (UInt32, Ptr{Cchar}), num_clbits, name)
end

function qk_circuit_add_quantum_register(circuit, reg)
    ccall((:qk_circuit_add_quantum_register, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkQuantumRegister}), circuit, reg)
end

function qk_circuit_add_classical_register(circuit, reg)
    ccall((:qk_circuit_add_classical_register, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkClassicalRegister}), circuit, reg)
end

function qk_circuit_copy(circuit)
    ccall((:qk_circuit_copy, libqiskit), Ptr{QkCircuit}, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_num_qubits(circuit)
    ccall((:qk_circuit_num_qubits, libqiskit), UInt32, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_num_clbits(circuit)
    ccall((:qk_circuit_num_clbits, libqiskit), UInt32, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_num_param_symbols(circuit)
    ccall((:qk_circuit_num_param_symbols, libqiskit), Csize_t, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_free(circuit)
    ccall((:qk_circuit_free, libqiskit), Cvoid, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_gate(circuit, gate, qubits, params)
    ccall((:qk_circuit_gate, libqiskit), QkExitCode, (Ptr{QkCircuit}, QkGate, Ptr{UInt32}, Ptr{Cdouble}), circuit, gate, qubits, params)
end

function qk_circuit_parameterized_gate(circuit, gate, qubits, params)
    ccall((:qk_circuit_parameterized_gate, libqiskit), QkExitCode, (Ptr{QkCircuit}, QkGate, Ptr{UInt32}, Ptr{Ptr{QkParam}}), circuit, gate, qubits, params)
end

function qk_gate_num_qubits(gate)
    ccall((:qk_gate_num_qubits, libqiskit), UInt32, (QkGate,), gate)
end

function qk_gate_num_params(gate)
    ccall((:qk_gate_num_params, libqiskit), UInt32, (QkGate,), gate)
end

function qk_circuit_measure(circuit, qubit, clbit)
    ccall((:qk_circuit_measure, libqiskit), QkExitCode, (Ptr{QkCircuit}, UInt32, UInt32), circuit, qubit, clbit)
end

function qk_circuit_reset(circuit, qubit)
    ccall((:qk_circuit_reset, libqiskit), QkExitCode, (Ptr{QkCircuit}, UInt32), circuit, qubit)
end

function qk_circuit_barrier(circuit, qubits, num_qubits)
    ccall((:qk_circuit_barrier, libqiskit), QkExitCode, (Ptr{QkCircuit}, Ptr{UInt32}, UInt32), circuit, qubits, num_qubits)
end

function qk_circuit_unitary(circuit, matrix, qubits, num_qubits, check_input)
    ccall((:qk_circuit_unitary, libqiskit), QkExitCode, (Ptr{QkCircuit}, Ptr{QkComplex64}, Ptr{UInt32}, UInt32, Bool), circuit, matrix, qubits, num_qubits, check_input)
end

function qk_circuit_inst_unitary(circuit, index, out)
    ccall((:qk_circuit_inst_unitary, libqiskit), Cvoid, (Ptr{QkCircuit}, Csize_t, Ptr{QkComplex64}), circuit, index, out)
end

function qk_circuit_instruction_kind(circuit, index)
    ccall((:qk_circuit_instruction_kind, libqiskit), QkOperationKind, (Ptr{QkCircuit}, Csize_t), circuit, index)
end

function qk_circuit_count_ops(circuit)
    ccall((:qk_circuit_count_ops, libqiskit), QkOpCounts, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_num_instructions(circuit)
    ccall((:qk_circuit_num_instructions, libqiskit), Csize_t, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_get_instruction(circuit, index, instruction)
    ccall((:qk_circuit_get_instruction, libqiskit), Cvoid, (Ptr{QkCircuit}, Csize_t, Ptr{QkCircuitInstruction}), circuit, index, instruction)
end

function qk_circuit_pauli_product_rotation(circuit, rotation, qubits)
    ccall((:qk_circuit_pauli_product_rotation, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkPauliProductRotation}, Ptr{UInt32}), circuit, rotation, qubits)
end

function qk_circuit_inst_pauli_product_rotation(circuit, index, instruction)
    ccall((:qk_circuit_inst_pauli_product_rotation, libqiskit), QkExitCode, (Ptr{QkCircuit}, Csize_t, Ptr{QkPauliProductRotation}), circuit, index, instruction)
end

function qk_circuit_pauli_product_measurement(circuit, measurement, qubits, clbit)
    ccall((:qk_circuit_pauli_product_measurement, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkPauliProductMeasurement}, Ptr{UInt32}, UInt32), circuit, measurement, qubits, clbit)
end

function qk_circuit_inst_pauli_product_measurement(circuit, index, instruction)
    ccall((:qk_circuit_inst_pauli_product_measurement, libqiskit), QkExitCode, (Ptr{QkCircuit}, Csize_t, Ptr{QkPauliProductMeasurement}), circuit, index, instruction)
end

function qk_circuit_instruction_clear(inst)
    ccall((:qk_circuit_instruction_clear, libqiskit), Cvoid, (Ptr{QkCircuitInstruction},), inst)
end

function qk_opcounts_clear(op_counts)
    ccall((:qk_opcounts_clear, libqiskit), Cvoid, (Ptr{QkOpCounts},), op_counts)
end

function qk_circuit_delay(circuit, qubit, duration, unit)
    ccall((:qk_circuit_delay, libqiskit), QkExitCode, (Ptr{QkCircuit}, UInt32, Cdouble, QkDelayUnit), circuit, qubit, duration, unit)
end

function qk_circuit_draw(circuit, config)
    ccall((:qk_circuit_draw, libqiskit), Ptr{Cchar}, (Ptr{QkCircuit}, Ptr{QkCircuitDrawerConfig}), circuit, config)
end

function qk_circuit_to_dag(circuit)
    ccall((:qk_circuit_to_dag, libqiskit), Ptr{QkDag}, (Ptr{QkCircuit},), circuit)
end

function qk_circuit_copy_empty_like(circuit, vars_mode, blocks_mode)
    ccall((:qk_circuit_copy_empty_like, libqiskit), Ptr{QkCircuit}, (Ptr{QkCircuit}, QkVarsMode, QkBlocksMode), circuit, vars_mode, blocks_mode)
end

function qk_circuit_library_iqp(num_qubits, interactions, check_input)
    ccall((:qk_circuit_library_iqp, libqiskit), Ptr{QkCircuit}, (UInt32, Ptr{Int64}, Bool), num_qubits, interactions, check_input)
end

function qk_circuit_library_random_iqp(num_qubits, seed)
    ccall((:qk_circuit_library_random_iqp, libqiskit), Ptr{QkCircuit}, (UInt32, Int64), num_qubits, seed)
end

function qk_pauli_product_rotation_clear(inst)
    ccall((:qk_pauli_product_rotation_clear, libqiskit), Cvoid, (Ptr{QkPauliProductRotation},), inst)
end

function qk_pauli_product_measurement_clear(inst)
    ccall((:qk_pauli_product_measurement_clear, libqiskit), Cvoid, (Ptr{QkPauliProductMeasurement},), inst)
end

function qk_circuit_library_quantum_volume(num_qubits, depth, seed)
    ccall((:qk_circuit_library_quantum_volume, libqiskit), Ptr{QkCircuit}, (UInt32, Csize_t, Int64), num_qubits, depth, seed)
end

function qk_circuit_library_suzuki_trotter(op, order, reps, time, preserve_order, insert_barriers)
    ccall((:qk_circuit_library_suzuki_trotter, libqiskit), Ptr{QkCircuit}, (Ptr{QkObs}, UInt32, UInt32, Cdouble, Bool, Bool), op, order, reps, time, preserve_order, insert_barriers)
end

function qk_dag_new()
    ccall((:qk_dag_new, libqiskit), Ptr{QkDag}, ())
end

function qk_dag_add_quantum_register(dag, reg)
    ccall((:qk_dag_add_quantum_register, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{QkQuantumRegister}), dag, reg)
end

function qk_dag_add_classical_register(dag, reg)
    ccall((:qk_dag_add_classical_register, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{QkClassicalRegister}), dag, reg)
end

function qk_dag_num_qubits(dag)
    ccall((:qk_dag_num_qubits, libqiskit), UInt32, (Ptr{QkDag},), dag)
end

function qk_dag_num_clbits(dag)
    ccall((:qk_dag_num_clbits, libqiskit), UInt32, (Ptr{QkDag},), dag)
end

function qk_dag_num_op_nodes(dag)
    ccall((:qk_dag_num_op_nodes, libqiskit), Csize_t, (Ptr{QkDag},), dag)
end

function qk_dag_node_type(dag, node)
    ccall((:qk_dag_node_type, libqiskit), QkDagNodeType, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_qubit_in_node(dag, qubit)
    ccall((:qk_dag_qubit_in_node, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, qubit)
end

function qk_dag_qubit_out_node(dag, qubit)
    ccall((:qk_dag_qubit_out_node, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, qubit)
end

function qk_dag_clbit_in_node(dag, clbit)
    ccall((:qk_dag_clbit_in_node, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, clbit)
end

function qk_dag_clbit_out_node(dag, clbit)
    ccall((:qk_dag_clbit_out_node, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, clbit)
end

function qk_dag_wire_node_value(dag, node)
    ccall((:qk_dag_wire_node_value, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_op_node_num_qubits(dag, node)
    ccall((:qk_dag_op_node_num_qubits, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_op_node_num_clbits(dag, node)
    ccall((:qk_dag_op_node_num_clbits, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_op_node_num_params(dag, node)
    ccall((:qk_dag_op_node_num_params, libqiskit), UInt32, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_op_node_qubits(dag, node)
    ccall((:qk_dag_op_node_qubits, libqiskit), Ptr{UInt32}, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_op_node_clbits(dag, node)
    ccall((:qk_dag_op_node_clbits, libqiskit), Ptr{UInt32}, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_apply_gate(dag, gate, qubits, params, front)
    ccall((:qk_dag_apply_gate, libqiskit), UInt32, (Ptr{QkDag}, QkGate, Ptr{UInt32}, Ptr{Cdouble}, Bool), dag, gate, qubits, params, front)
end

function qk_dag_apply_measure(dag, qubit, clbit, front)
    ccall((:qk_dag_apply_measure, libqiskit), UInt32, (Ptr{QkDag}, UInt32, UInt32, Bool), dag, qubit, clbit, front)
end

function qk_dag_apply_reset(dag, qubit, front)
    ccall((:qk_dag_apply_reset, libqiskit), UInt32, (Ptr{QkDag}, UInt32, Bool), dag, qubit, front)
end

function qk_dag_apply_barrier(dag, qubits, num_qubits, front)
    ccall((:qk_dag_apply_barrier, libqiskit), UInt32, (Ptr{QkDag}, Ptr{UInt32}, UInt32, Bool), dag, qubits, num_qubits, front)
end

function qk_dag_apply_unitary(dag, matrix, qubits, num_qubits, front)
    ccall((:qk_dag_apply_unitary, libqiskit), UInt32, (Ptr{QkDag}, Ptr{QkComplex64}, Ptr{UInt32}, UInt32, Bool), dag, matrix, qubits, num_qubits, front)
end

function qk_dag_op_node_gate_op(dag, node, out_params)
    ccall((:qk_dag_op_node_gate_op, libqiskit), QkGate, (Ptr{QkDag}, UInt32, Ptr{Cdouble}), dag, node, out_params)
end

function qk_dag_op_node_unitary(dag, node, out)
    ccall((:qk_dag_op_node_unitary, libqiskit), Cvoid, (Ptr{QkDag}, UInt32, Ptr{QkComplex64}), dag, node, out)
end

function qk_dag_op_node_kind(dag, node)
    ccall((:qk_dag_op_node_kind, libqiskit), QkOperationKind, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_successors(dag, node)
    ccall((:qk_dag_successors, libqiskit), QkDagNeighbors, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_predecessors(dag, node)
    ccall((:qk_dag_predecessors, libqiskit), QkDagNeighbors, (Ptr{QkDag}, UInt32), dag, node)
end

function qk_dag_neighbors_clear(neighbors)
    ccall((:qk_dag_neighbors_clear, libqiskit), Cvoid, (Ptr{QkDagNeighbors},), neighbors)
end

function qk_dag_get_instruction(dag, index, instruction)
    ccall((:qk_dag_get_instruction, libqiskit), Cvoid, (Ptr{QkDag}, UInt32, Ptr{QkCircuitInstruction}), dag, index, instruction)
end

function qk_dag_compose(dag, other, qubits, clbits)
    ccall((:qk_dag_compose, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkDag}, Ptr{UInt32}, Ptr{UInt32}), dag, other, qubits, clbits)
end

function qk_dag_free(dag)
    ccall((:qk_dag_free, libqiskit), Cvoid, (Ptr{QkDag},), dag)
end

function qk_dag_to_circuit(dag)
    ccall((:qk_dag_to_circuit, libqiskit), Ptr{QkCircuit}, (Ptr{QkDag},), dag)
end

function qk_dag_topological_op_nodes(dag, out_order)
    ccall((:qk_dag_topological_op_nodes, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{UInt32}), dag, out_order)
end

function qk_dag_substitute_node_with_dag(dag, node, replacement)
    ccall((:qk_dag_substitute_node_with_dag, libqiskit), Cvoid, (Ptr{QkDag}, UInt32, Ptr{QkDag}), dag, node, replacement)
end

function qk_dag_copy_empty_like(dag, vars_mode, blocks_mode)
    ccall((:qk_dag_copy_empty_like, libqiskit), Ptr{QkDag}, (Ptr{QkDag}, QkVarsMode, QkBlocksMode), dag, vars_mode, blocks_mode)
end

function qk_dag_replace_block_with_unitary(dag, num_block_ids, block_ids, matrix, num_qubits, qubits, cycle_check)
    ccall((:qk_dag_replace_block_with_unitary, libqiskit), UInt32, (Ptr{QkDag}, UInt32, Ptr{UInt32}, Ptr{QkComplex64}, UInt32, Ptr{UInt32}, Bool), dag, num_block_ids, block_ids, matrix, num_qubits, qubits, cycle_check)
end

function qk_dag_substitute_node_with_unitary(dag, node, matrix, num_qubits)
    ccall((:qk_dag_substitute_node_with_unitary, libqiskit), Cvoid, (Ptr{QkDag}, UInt32, Ptr{QkComplex64}, UInt32), dag, node, matrix, num_qubits)
end

function qk_param_new_symbol(name)
    ccall((:qk_param_new_symbol, libqiskit), Ptr{QkParam}, (Ptr{Cchar},), name)
end

function qk_param_zero()
    ccall((:qk_param_zero, libqiskit), Ptr{QkParam}, ())
end

function qk_param_free(param)
    ccall((:qk_param_free, libqiskit), Cvoid, (Ptr{QkParam},), param)
end

function qk_param_from_double(value)
    ccall((:qk_param_from_double, libqiskit), Ptr{QkParam}, (Cdouble,), value)
end

function qk_param_from_complex(value)
    ccall((:qk_param_from_complex, libqiskit), Ptr{QkParam}, (QkComplex64,), value)
end

function qk_param_copy(param)
    ccall((:qk_param_copy, libqiskit), Ptr{QkParam}, (Ptr{QkParam},), param)
end

function qk_param_str(param)
    ccall((:qk_param_str, libqiskit), Ptr{Cchar}, (Ptr{QkParam},), param)
end

function qk_param_add(out, lhs, rhs)
    ccall((:qk_param_add, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}, Ptr{QkParam}), out, lhs, rhs)
end

function qk_param_sub(out, lhs, rhs)
    ccall((:qk_param_sub, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}, Ptr{QkParam}), out, lhs, rhs)
end

function qk_param_mul(out, lhs, rhs)
    ccall((:qk_param_mul, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}, Ptr{QkParam}), out, lhs, rhs)
end

function qk_param_div(out, num, den)
    ccall((:qk_param_div, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}, Ptr{QkParam}), out, num, den)
end

function qk_param_pow(out, base, pow)
    ccall((:qk_param_pow, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}, Ptr{QkParam}), out, base, pow)
end

function qk_param_sin(out, src)
    ccall((:qk_param_sin, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_cos(out, src)
    ccall((:qk_param_cos, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_tan(out, src)
    ccall((:qk_param_tan, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_asin(out, src)
    ccall((:qk_param_asin, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_acos(out, src)
    ccall((:qk_param_acos, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_atan(out, src)
    ccall((:qk_param_atan, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_log(out, src)
    ccall((:qk_param_log, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_exp(out, src)
    ccall((:qk_param_exp, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_abs(out, src)
    ccall((:qk_param_abs, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_sign(out, src)
    ccall((:qk_param_sign, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_neg(out, src)
    ccall((:qk_param_neg, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_conjugate(out, src)
    ccall((:qk_param_conjugate, libqiskit), QkExitCode, (Ptr{QkParam}, Ptr{QkParam}), out, src)
end

function qk_param_equal(lhs, rhs)
    ccall((:qk_param_equal, libqiskit), Bool, (Ptr{QkParam}, Ptr{QkParam}), lhs, rhs)
end

function qk_param_as_real(param)
    ccall((:qk_param_as_real, libqiskit), Cdouble, (Ptr{QkParam},), param)
end

function qk_obs_zero(num_qubits)
    ccall((:qk_obs_zero, libqiskit), Ptr{QkObs}, (UInt32,), num_qubits)
end

function qk_obs_identity(num_qubits)
    ccall((:qk_obs_identity, libqiskit), Ptr{QkObs}, (UInt32,), num_qubits)
end

function qk_obs_new(num_qubits, num_terms, num_bits, coeffs, bit_terms, indices, boundaries)
    ccall((:qk_obs_new, libqiskit), Ptr{QkObs}, (UInt32, UInt64, UInt64, Ptr{QkComplex64}, Ptr{QkBitTerm}, Ptr{UInt32}, Ptr{Csize_t}), num_qubits, num_terms, num_bits, coeffs, bit_terms, indices, boundaries)
end

function qk_obs_free(obs)
    ccall((:qk_obs_free, libqiskit), Cvoid, (Ptr{QkObs},), obs)
end

function qk_obs_add_term(obs, cterm)
    ccall((:qk_obs_add_term, libqiskit), QkExitCode, (Ptr{QkObs}, Ptr{QkObsTerm}), obs, cterm)
end

function qk_obs_term(obs, index, out)
    ccall((:qk_obs_term, libqiskit), QkExitCode, (Ptr{QkObs}, UInt64, Ptr{QkObsTerm}), obs, index, out)
end

function qk_obs_num_terms(obs)
    ccall((:qk_obs_num_terms, libqiskit), Csize_t, (Ptr{QkObs},), obs)
end

function qk_obs_num_qubits(obs)
    ccall((:qk_obs_num_qubits, libqiskit), UInt32, (Ptr{QkObs},), obs)
end

function qk_obs_len(obs)
    ccall((:qk_obs_len, libqiskit), Csize_t, (Ptr{QkObs},), obs)
end

function qk_obs_coeffs(obs)
    ccall((:qk_obs_coeffs, libqiskit), Ptr{QkComplex64}, (Ptr{QkObs},), obs)
end

function qk_obs_indices(obs)
    ccall((:qk_obs_indices, libqiskit), Ptr{UInt32}, (Ptr{QkObs},), obs)
end

function qk_obs_boundaries(obs)
    ccall((:qk_obs_boundaries, libqiskit), Ptr{Csize_t}, (Ptr{QkObs},), obs)
end

function qk_obs_bit_terms(obs)
    ccall((:qk_obs_bit_terms, libqiskit), Ptr{QkBitTerm}, (Ptr{QkObs},), obs)
end

function qk_obs_multiply(obs, coeff)
    ccall((:qk_obs_multiply, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Ptr{QkComplex64}), obs, coeff)
end

function qk_obs_multiply_inplace(obs, coeff)
    ccall((:qk_obs_multiply_inplace, libqiskit), Cvoid, (Ptr{QkObs}, Ptr{QkComplex64}), obs, coeff)
end

function qk_obs_add(left, right)
    ccall((:qk_obs_add, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Ptr{QkObs}), left, right)
end

function qk_obs_add_inplace(left, right)
    ccall((:qk_obs_add_inplace, libqiskit), Cvoid, (Ptr{QkObs}, Ptr{QkObs}), left, right)
end

function qk_obs_scaled_add(left, right, factor)
    ccall((:qk_obs_scaled_add, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Ptr{QkObs}, Ptr{QkComplex64}), left, right, factor)
end

function qk_obs_scaled_add_inplace(left, right, factor)
    ccall((:qk_obs_scaled_add_inplace, libqiskit), Cvoid, (Ptr{QkObs}, Ptr{QkObs}, Ptr{QkComplex64}), left, right, factor)
end

function qk_obs_compose(first, second)
    ccall((:qk_obs_compose, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Ptr{QkObs}), first, second)
end

function qk_obs_compose_map(first, second, qargs)
    ccall((:qk_obs_compose_map, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Ptr{QkObs}, Ptr{UInt32}), first, second, qargs)
end

function qk_obs_apply_layout(obs, layout, num_qubits)
    ccall((:qk_obs_apply_layout, libqiskit), QkExitCode, (Ptr{QkObs}, Ptr{UInt32}, UInt32), obs, layout, num_qubits)
end

function qk_obs_canonicalize(obs, tol)
    ccall((:qk_obs_canonicalize, libqiskit), Ptr{QkObs}, (Ptr{QkObs}, Cdouble), obs, tol)
end

function qk_obs_copy(obs)
    ccall((:qk_obs_copy, libqiskit), Ptr{QkObs}, (Ptr{QkObs},), obs)
end

function qk_obs_equal(obs, other)
    ccall((:qk_obs_equal, libqiskit), Bool, (Ptr{QkObs}, Ptr{QkObs}), obs, other)
end

function qk_obs_str(obs)
    ccall((:qk_obs_str, libqiskit), Ptr{Cchar}, (Ptr{QkObs},), obs)
end

function qk_str_free(string)
    ccall((:qk_str_free, libqiskit), Cvoid, (Ptr{Cchar},), string)
end

function qk_obsterm_str(term)
    ccall((:qk_obsterm_str, libqiskit), Ptr{Cchar}, (Ptr{QkObsTerm},), term)
end

function qk_bitterm_label(bit_term)
    ccall((:qk_bitterm_label, libqiskit), UInt8, (QkBitTerm,), bit_term)
end

function qk_neighbors_is_all_to_all(neighbors)
    ccall((:qk_neighbors_is_all_to_all, libqiskit), Bool, (Ptr{QkNeighbors},), neighbors)
end

function qk_neighbors_from_target(target, neighbors)
    ccall((:qk_neighbors_from_target, libqiskit), Bool, (Ptr{QkTarget}, Ptr{QkNeighbors}), target, neighbors)
end

function qk_neighbors_clear(neighbors)
    ccall((:qk_neighbors_clear, libqiskit), Cvoid, (Ptr{QkNeighbors},), neighbors)
end

function qk_transpiler_pass_standalone_basis_translator(circuit, target, min_qubits)
    ccall((:qk_transpiler_pass_standalone_basis_translator, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}, Csize_t), circuit, target, min_qubits)
end

function qk_transpiler_pass_standalone_commutative_cancellation(circuit, target, approximation_degree)
    ccall((:qk_transpiler_pass_standalone_commutative_cancellation, libqiskit), QkExitCode, (Ptr{QkCircuit}, Ptr{QkTarget}, Cdouble), circuit, target, approximation_degree)
end

function qk_transpiler_pass_standalone_consolidate_blocks(circuit, target, approximation_degree, force_consolidate)
    ccall((:qk_transpiler_pass_standalone_consolidate_blocks, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}, Cdouble, Bool), circuit, target, approximation_degree, force_consolidate)
end

function qk_transpiler_pass_standalone_convert_to_pauli_rotations(circuit)
    ccall((:qk_transpiler_pass_standalone_convert_to_pauli_rotations, libqiskit), Cvoid, (Ptr{QkCircuit},), circuit)
end

function qk_transpiler_pass_standalone_elide_permutations(circuit)
    ccall((:qk_transpiler_pass_standalone_elide_permutations, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkCircuit},), circuit)
end

function qk_transpiler_pass_elide_permutations(dag)
    ccall((:qk_transpiler_pass_elide_permutations, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkDag},), dag)
end

function qk_transpiler_pass_standalone_check_gate_direction(circuit, target)
    ccall((:qk_transpiler_pass_standalone_check_gate_direction, libqiskit), Bool, (Ptr{QkCircuit}, Ptr{QkTarget}), circuit, target)
end

function qk_transpiler_pass_standalone_gate_direction(circuit, target)
    ccall((:qk_transpiler_pass_standalone_gate_direction, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}), circuit, target)
end

function qk_transpiler_pass_check_gate_direction(dag, target)
    ccall((:qk_transpiler_pass_check_gate_direction, libqiskit), Bool, (Ptr{QkDag}, Ptr{QkTarget}), dag, target)
end

function qk_transpiler_pass_gate_direction(dag, target)
    ccall((:qk_transpiler_pass_gate_direction, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{QkTarget}), dag, target)
end

function qk_transpiler_pass_standalone_inverse_cancellation(circuit)
    ccall((:qk_transpiler_pass_standalone_inverse_cancellation, libqiskit), Cvoid, (Ptr{QkCircuit},), circuit)
end

function qk_transpiler_pass_standalone_litinski_transformation(circuit, fix_clifford)
    ccall((:qk_transpiler_pass_standalone_litinski_transformation, libqiskit), Cvoid, (Ptr{QkCircuit}, Bool), circuit, fix_clifford)
end

function qk_transpiler_standalone_optimize_1q_sequences(circuit, target)
    ccall((:qk_transpiler_standalone_optimize_1q_sequences, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}), circuit, target)
end

function qk_transpiler_pass_standalone_optimize_1q_sequences(circuit, target)
    ccall((:qk_transpiler_pass_standalone_optimize_1q_sequences, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}), circuit, target)
end

function qk_transpiler_pass_optimize_1q_sequences(dag, target)
    ccall((:qk_transpiler_pass_optimize_1q_sequences, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{QkTarget}), dag, target)
end

function qk_transpiler_pass_standalone_remove_diagonal_gates_before_measure(circuit)
    ccall((:qk_transpiler_pass_standalone_remove_diagonal_gates_before_measure, libqiskit), Cvoid, (Ptr{QkCircuit},), circuit)
end

function qk_transpiler_pass_remove_diagonal_gates_before_measure(dag)
    ccall((:qk_transpiler_pass_remove_diagonal_gates_before_measure, libqiskit), Cvoid, (Ptr{QkDag},), dag)
end

function qk_transpiler_pass_standalone_remove_identity_equivalent(circuit, target, approximation_degree)
    ccall((:qk_transpiler_pass_standalone_remove_identity_equivalent, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}, Cdouble), circuit, target, approximation_degree)
end

function qk_transpiler_pass_remove_identity_equivalent(dag, target, approximation_degree)
    ccall((:qk_transpiler_pass_remove_identity_equivalent, libqiskit), Cvoid, (Ptr{QkDag}, Ptr{QkTarget}, Cdouble), dag, target, approximation_degree)
end

function qk_sabre_layout_options_default()
    ccall((:qk_sabre_layout_options_default, libqiskit), QkSabreLayoutOptions, ())
end

function qk_transpiler_pass_standalone_sabre_layout(circuit, target, options)
    ccall((:qk_transpiler_pass_standalone_sabre_layout, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkCircuit}, Ptr{QkTarget}, Ptr{QkSabreLayoutOptions}), circuit, target, options)
end

function qk_transpiler_pass_standalone_split_2q_unitaries(circuit, requested_fidelity, split_swaps)
    ccall((:qk_transpiler_pass_standalone_split_2q_unitaries, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkCircuit}, Cdouble, Bool), circuit, requested_fidelity, split_swaps)
end

function qk_transpiler_pass_split_2q_unitaries(dag, requested_fidelity, split_swaps)
    ccall((:qk_transpiler_pass_split_2q_unitaries, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkDag}, Cdouble, Bool), dag, requested_fidelity, split_swaps)
end

function qk_transpiler_pass_standalone_unitary_synthesis(circuit, target, min_qubits, approximation_degree)
    ccall((:qk_transpiler_pass_standalone_unitary_synthesis, libqiskit), Cvoid, (Ptr{QkCircuit}, Ptr{QkTarget}, Csize_t, Cdouble), circuit, target, min_qubits, approximation_degree)
end

function qk_vf2_layout_result_has_match(layout)
    ccall((:qk_vf2_layout_result_has_match, libqiskit), Bool, (Ptr{QkVF2LayoutResult},), layout)
end

function qk_vf2_layout_result_has_improvement(layout)
    ccall((:qk_vf2_layout_result_has_improvement, libqiskit), Bool, (Ptr{QkVF2LayoutResult},), layout)
end

function qk_vf2_layout_result_map_virtual_qubit(layout, qubit)
    ccall((:qk_vf2_layout_result_map_virtual_qubit, libqiskit), UInt32, (Ptr{QkVF2LayoutResult}, UInt32), layout, qubit)
end

function qk_vf2_layout_result_free(layout)
    ccall((:qk_vf2_layout_result_free, libqiskit), Cvoid, (Ptr{QkVF2LayoutResult},), layout)
end

function qk_vf2_layout_configuration_new()
    ccall((:qk_vf2_layout_configuration_new, libqiskit), Ptr{QkVF2LayoutConfiguration}, ())
end

function qk_vf2_layout_configuration_free(config)
    ccall((:qk_vf2_layout_configuration_free, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration},), config)
end

function qk_vf2_layout_configuration_set_call_limit(config, before, after)
    ccall((:qk_vf2_layout_configuration_set_call_limit, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration}, Int64, Int64), config, before, after)
end

function qk_vf2_layout_configuration_set_time_limit(config, limit)
    ccall((:qk_vf2_layout_configuration_set_time_limit, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration}, Cdouble), config, limit)
end

function qk_vf2_layout_configuration_set_max_trials(config, limit)
    ccall((:qk_vf2_layout_configuration_set_max_trials, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration}, UInt64), config, limit)
end

function qk_vf2_layout_configuration_set_shuffle_seed(config, seed)
    ccall((:qk_vf2_layout_configuration_set_shuffle_seed, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration}, UInt64), config, seed)
end

function qk_vf2_layout_configuration_set_score_initial(config, score_initial)
    ccall((:qk_vf2_layout_configuration_set_score_initial, libqiskit), Cvoid, (Ptr{QkVF2LayoutConfiguration}, Bool), config, score_initial)
end

function qk_transpiler_pass_standalone_vf2_layout_average(circuit, target, config, strict_direction)
    ccall((:qk_transpiler_pass_standalone_vf2_layout_average, libqiskit), Ptr{QkVF2LayoutResult}, (Ptr{QkCircuit}, Ptr{QkTarget}, Ptr{QkVF2LayoutConfiguration}, Bool), circuit, target, config, strict_direction)
end

function qk_transpiler_pass_standalone_vf2_layout_exact(circuit, target, config)
    ccall((:qk_transpiler_pass_standalone_vf2_layout_exact, libqiskit), Ptr{QkVF2LayoutResult}, (Ptr{QkCircuit}, Ptr{QkTarget}, Ptr{QkVF2LayoutConfiguration}), circuit, target, config)
end

function qk_transpiler_pass_standalone_vf2_layout(circuit, target, strict_direction, call_limit, time_limit, max_trials)
    ccall((:qk_transpiler_pass_standalone_vf2_layout, libqiskit), Ptr{QkVF2LayoutResult}, (Ptr{QkCircuit}, Ptr{QkTarget}, Bool, Int64, Cdouble, Int64), circuit, target, strict_direction, call_limit, time_limit, max_trials)
end

function qk_target_new(num_qubits)
    ccall((:qk_target_new, libqiskit), Ptr{QkTarget}, (UInt32,), num_qubits)
end

function qk_target_num_qubits(target)
    ccall((:qk_target_num_qubits, libqiskit), UInt32, (Ptr{QkTarget},), target)
end

function qk_target_dt(target)
    ccall((:qk_target_dt, libqiskit), Cdouble, (Ptr{QkTarget},), target)
end

function qk_target_granularity(target)
    ccall((:qk_target_granularity, libqiskit), UInt32, (Ptr{QkTarget},), target)
end

function qk_target_min_length(target)
    ccall((:qk_target_min_length, libqiskit), UInt32, (Ptr{QkTarget},), target)
end

function qk_target_pulse_alignment(target)
    ccall((:qk_target_pulse_alignment, libqiskit), UInt32, (Ptr{QkTarget},), target)
end

function qk_target_acquire_alignment(target)
    ccall((:qk_target_acquire_alignment, libqiskit), UInt32, (Ptr{QkTarget},), target)
end

function qk_target_set_dt(target, dt)
    ccall((:qk_target_set_dt, libqiskit), QkExitCode, (Ptr{QkTarget}, Cdouble), target, dt)
end

function qk_target_set_granularity(target, granularity)
    ccall((:qk_target_set_granularity, libqiskit), QkExitCode, (Ptr{QkTarget}, UInt32), target, granularity)
end

function qk_target_set_min_length(target, min_length)
    ccall((:qk_target_set_min_length, libqiskit), QkExitCode, (Ptr{QkTarget}, UInt32), target, min_length)
end

function qk_target_set_pulse_alignment(target, pulse_alignment)
    ccall((:qk_target_set_pulse_alignment, libqiskit), QkExitCode, (Ptr{QkTarget}, UInt32), target, pulse_alignment)
end

function qk_target_set_acquire_alignment(target, acquire_alignment)
    ccall((:qk_target_set_acquire_alignment, libqiskit), QkExitCode, (Ptr{QkTarget}, UInt32), target, acquire_alignment)
end

function qk_target_copy(target)
    ccall((:qk_target_copy, libqiskit), Ptr{QkTarget}, (Ptr{QkTarget},), target)
end

function qk_target_free(target)
    ccall((:qk_target_free, libqiskit), Cvoid, (Ptr{QkTarget},), target)
end

function qk_target_entry_new(operation)
    ccall((:qk_target_entry_new, libqiskit), Ptr{QkTargetEntry}, (QkGate,), operation)
end

function qk_target_entry_new_measure()
    ccall((:qk_target_entry_new_measure, libqiskit), Ptr{QkTargetEntry}, ())
end

function qk_target_entry_new_reset()
    ccall((:qk_target_entry_new_reset, libqiskit), Ptr{QkTargetEntry}, ())
end

function qk_target_entry_new_fixed(operation, params, name)
    ccall((:qk_target_entry_new_fixed, libqiskit), Ptr{QkTargetEntry}, (QkGate, Ptr{Cdouble}, Ptr{Cchar}), operation, params, name)
end

function qk_target_entry_num_properties(entry)
    ccall((:qk_target_entry_num_properties, libqiskit), Csize_t, (Ptr{QkTargetEntry},), entry)
end

function qk_target_entry_free(entry)
    ccall((:qk_target_entry_free, libqiskit), Cvoid, (Ptr{QkTargetEntry},), entry)
end

function qk_target_entry_add_property(entry, qargs, num_qubits, duration, error)
    ccall((:qk_target_entry_add_property, libqiskit), QkExitCode, (Ptr{QkTargetEntry}, Ptr{UInt32}, UInt32, Cdouble, Cdouble), entry, qargs, num_qubits, duration, error)
end

function qk_target_entry_set_name(entry, name)
    ccall((:qk_target_entry_set_name, libqiskit), QkExitCode, (Ptr{QkTargetEntry}, Ptr{Cchar}), entry, name)
end

function qk_target_add_instruction(target, target_entry)
    ccall((:qk_target_add_instruction, libqiskit), QkExitCode, (Ptr{QkTarget}, Ptr{QkTargetEntry}), target, target_entry)
end

function qk_target_update_property(target, instruction, qargs, num_qubits, duration, error)
    ccall((:qk_target_update_property, libqiskit), QkExitCode, (Ptr{QkTarget}, QkGate, Ptr{UInt32}, UInt32, Cdouble, Cdouble), target, instruction, qargs, num_qubits, duration, error)
end

function qk_target_num_instructions(target)
    ccall((:qk_target_num_instructions, libqiskit), Csize_t, (Ptr{QkTarget},), target)
end

function qk_target_instruction_supported(target, operation_name, qargs, params)
    ccall((:qk_target_instruction_supported, libqiskit), Bool, (Ptr{QkTarget}, Ptr{Cchar}, Ptr{UInt32}, Ptr{Ptr{QkParam}}), target, operation_name, qargs, params)
end

function qk_target_op_index(target, name)
    ccall((:qk_target_op_index, libqiskit), Csize_t, (Ptr{QkTarget}, Ptr{Cchar}), target, name)
end

function qk_target_op_name(target, index)
    ccall((:qk_target_op_name, libqiskit), Ptr{Cchar}, (Ptr{QkTarget}, Csize_t), target, index)
end

function qk_target_op_num_properties(target, index)
    ccall((:qk_target_op_num_properties, libqiskit), Csize_t, (Ptr{QkTarget}, Csize_t), target, index)
end

function qk_target_op_qargs_index(target, op_idx, qargs)
    ccall((:qk_target_op_qargs_index, libqiskit), Csize_t, (Ptr{QkTarget}, Csize_t, Ptr{UInt32}), target, op_idx, qargs)
end

function qk_target_op_qargs(target, op_idx, qarg_idx, qargs_out, qargs_len)
    ccall((:qk_target_op_qargs, libqiskit), Cvoid, (Ptr{QkTarget}, Csize_t, Csize_t, Ptr{Ptr{UInt32}}, Ptr{UInt32}), target, op_idx, qarg_idx, qargs_out, qargs_len)
end

function qk_target_op_props(target, op_idx, qarg_idx, inst_props)
    ccall((:qk_target_op_props, libqiskit), Cvoid, (Ptr{QkTarget}, Csize_t, Csize_t, Ptr{QkInstructionProperties}), target, op_idx, qarg_idx, inst_props)
end

function qk_target_op_get(target, index, out_op)
    ccall((:qk_target_op_get, libqiskit), Cvoid, (Ptr{QkTarget}, Csize_t, Ptr{QkTargetOp}), target, index, out_op)
end

function qk_target_op_gate(target, index)
    ccall((:qk_target_op_gate, libqiskit), QkGate, (Ptr{QkTarget}, Csize_t), target, index)
end

function qk_target_op_clear(op)
    ccall((:qk_target_op_clear, libqiskit), Cvoid, (Ptr{QkTargetOp},), op)
end

function qk_transpile_state_new(state)
    ccall((:qk_transpile_state_new, libqiskit), Cvoid, (Ptr{Ptr{QkTranspilerStageState}},), state)
end

function qk_transpile_state_free(state)
    ccall((:qk_transpile_state_free, libqiskit), Cvoid, (Ptr{QkTranspilerStageState},), state)
end

function qk_transpile_state_layout(state)
    ccall((:qk_transpile_state_layout, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkTranspilerStageState},), state)
end

function qk_transpile_state_layout_set(state, layout)
    ccall((:qk_transpile_state_layout_set, libqiskit), Cvoid, (Ptr{QkTranspilerStageState}, Ptr{QkTranspileLayout}), state, layout)
end

function qk_transpiler_default_options()
    ccall((:qk_transpiler_default_options, libqiskit), QkTranspileOptions, ())
end

function qk_transpile_stage_init(dag, target, options, state, error)
    ccall((:qk_transpile_stage_init, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{Ptr{QkTranspilerStageState}}, Ptr{Ptr{Cchar}}), dag, target, options, state, error)
end

function qk_transpile_stage_routing(dag, target, options, state, error)
    ccall((:qk_transpile_stage_routing, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{QkTranspilerStageState}, Ptr{Ptr{Cchar}}), dag, target, options, state, error)
end

function qk_transpile_stage_optimization(dag, target, options, error, state)
    ccall((:qk_transpile_stage_optimization, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{Ptr{Cchar}}, Ptr{QkTranspilerStageState}), dag, target, options, error, state)
end

function qk_transpile_stage_translation(dag, target, options, error)
    ccall((:qk_transpile_stage_translation, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{Ptr{Cchar}}), dag, target, options, error)
end

function qk_transpile_stage_layout(dag, target, options, state, error)
    ccall((:qk_transpile_stage_layout, libqiskit), QkExitCode, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{Ptr{QkTranspilerStageState}}, Ptr{Ptr{Cchar}}), dag, target, options, state, error)
end

function qk_transpile(qc, target, options, result, error)
    ccall((:qk_transpile, libqiskit), QkExitCode, (Ptr{QkCircuit}, Ptr{QkTarget}, Ptr{QkTranspileOptions}, Ptr{QkTranspileResult}, Ptr{Ptr{Cchar}}), qc, target, options, result, error)
end

function qk_transpile_layout_num_input_qubits(layout)
    ccall((:qk_transpile_layout_num_input_qubits, libqiskit), UInt32, (Ptr{QkTranspileLayout},), layout)
end

function qk_transpile_layout_num_output_qubits(layout)
    ccall((:qk_transpile_layout_num_output_qubits, libqiskit), UInt32, (Ptr{QkTranspileLayout},), layout)
end

function qk_transpile_layout_initial_layout(layout, filter_ancillas, initial_layout)
    ccall((:qk_transpile_layout_initial_layout, libqiskit), Bool, (Ptr{QkTranspileLayout}, Bool, Ptr{UInt32}), layout, filter_ancillas, initial_layout)
end

function qk_transpile_layout_output_permutation(layout, output_permutation)
    ccall((:qk_transpile_layout_output_permutation, libqiskit), Bool, (Ptr{QkTranspileLayout}, Ptr{UInt32}), layout, output_permutation)
end

function qk_transpile_layout_final_layout(layout, filter_ancillas, final_layout)
    ccall((:qk_transpile_layout_final_layout, libqiskit), Cvoid, (Ptr{QkTranspileLayout}, Bool, Ptr{UInt32}), layout, filter_ancillas, final_layout)
end

function qk_transpile_layout_generate_from_mapping(original_dag, target, qubit_mapping)
    ccall((:qk_transpile_layout_generate_from_mapping, libqiskit), Ptr{QkTranspileLayout}, (Ptr{QkDag}, Ptr{QkTarget}, Ptr{UInt32}), original_dag, target, qubit_mapping)
end

function qk_transpile_layout_free(layout)
    ccall((:qk_transpile_layout_free, libqiskit), Cvoid, (Ptr{QkTranspileLayout},), layout)
end

# Skipping MacroDefinition: Qk_DEPRECATED_FN __attribute__ ( ( deprecated ) )

const QISKIT_RELEASE_LEVEL_DEV = 0x0a

const QISKIT_RELEASE_LEVEL_BETA = 0x0b

const QISKIT_RELEASE_LEVEL_RC = 0x0c

const QISKIT_RELEASE_LEVEL_FINAL = 0x0f

const QISKIT_VERSION_MAJOR = 2

const QISKIT_VERSION_MINOR = 4

const QISKIT_VERSION_PATCH = 1

const QISKIT_RELEASE_LEVEL = QISKIT_RELEASE_LEVEL_FINAL

const QISKIT_RELEASE_SERIAL = 0

const QISKIT_VERSION = "2.4.1"

# exports
const PREFIXES = ["Qk", "qk_", "QISKIT_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
