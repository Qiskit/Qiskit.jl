module LibQiskit

using Qiskit_jll
export Qiskit_jll

using CEnum: CEnum, @cenum

struct QkComplex64
    re::Cdouble
    im::Cdouble
end

@cenum QkExitCode::UInt32 begin
    QkExitCode_Success = 0x0000000000000000
    QkExitCode_CInputError = 0x0000000000000064
    QkExitCode_NullPointerError = 0x0000000000000065
    QkExitCode_AlignmentError = 0x0000000000000066
    QkExitCode_IndexError = 0x0000000000000067
    QkExitCode_DuplicateIndexError = 0x0000000000000068
    QkExitCode_InvalidOperationKind = 0x0000000000000069
    QkExitCode_ArithmeticError = 0x00000000000000c8
    QkExitCode_MismatchedQubits = 0x00000000000000c9
    QkExitCode_ExpectedUnitary = 0x00000000000000ca
    QkExitCode_TargetError = 0x000000000000012c
    QkExitCode_TargetInstAlreadyExists = 0x000000000000012d
    QkExitCode_TargetQargMismatch = 0x000000000000012e
    QkExitCode_TargetInvalidQargsKey = 0x000000000000012f
    QkExitCode_TargetInvalidInstKey = 0x0000000000000130
    QkExitCode_TranspilerError = 0x0000000000000190
    QkExitCode_DagError = 0x00000000000001f4
    QkExitCode_DagComposeMismatch = 0x00000000000001f5
    QkExitCode_DagComposeMissingBit = 0x00000000000001f6
    QkExitCode_ParameterError = 0x0000000000000258
    QkExitCode_ParameterNameConflict = 0x0000000000000259
end

@cenum QkGate::UInt8 begin
    QkGate_GlobalPhase = 0x0000000000000000
    QkGate_H = 0x0000000000000001
    QkGate_I = 0x0000000000000002
    QkGate_X = 0x0000000000000003
    QkGate_Y = 0x0000000000000004
    QkGate_Z = 0x0000000000000005
    QkGate_Phase = 0x0000000000000006
    QkGate_R = 0x0000000000000007
    QkGate_RX = 0x0000000000000008
    QkGate_RY = 0x0000000000000009
    QkGate_RZ = 0x000000000000000a
    QkGate_S = 0x000000000000000b
    QkGate_Sdg = 0x000000000000000c
    QkGate_SX = 0x000000000000000d
    QkGate_SXdg = 0x000000000000000e
    QkGate_T = 0x000000000000000f
    QkGate_Tdg = 0x0000000000000010
    QkGate_U = 0x0000000000000011
    QkGate_U1 = 0x0000000000000012
    QkGate_U2 = 0x0000000000000013
    QkGate_U3 = 0x0000000000000014
    QkGate_CH = 0x0000000000000015
    QkGate_CX = 0x0000000000000016
    QkGate_CY = 0x0000000000000017
    QkGate_CZ = 0x0000000000000018
    QkGate_DCX = 0x0000000000000019
    QkGate_ECR = 0x000000000000001a
    QkGate_Swap = 0x000000000000001b
    QkGate_ISwap = 0x000000000000001c
    QkGate_CPhase = 0x000000000000001d
    QkGate_CRX = 0x000000000000001e
    QkGate_CRY = 0x000000000000001f
    QkGate_CRZ = 0x0000000000000020
    QkGate_CS = 0x0000000000000021
    QkGate_CSdg = 0x0000000000000022
    QkGate_CSX = 0x0000000000000023
    QkGate_CU = 0x0000000000000024
    QkGate_CU1 = 0x0000000000000025
    QkGate_CU3 = 0x0000000000000026
    QkGate_RXX = 0x0000000000000027
    QkGate_RYY = 0x0000000000000028
    QkGate_RZZ = 0x0000000000000029
    QkGate_RZX = 0x000000000000002a
    QkGate_XXMinusYY = 0x000000000000002b
    QkGate_XXPlusYY = 0x000000000000002c
    QkGate_CCX = 0x000000000000002d
    QkGate_CCZ = 0x000000000000002e
    QkGate_CSwap = 0x000000000000002f
    QkGate_RCCX = 0x0000000000000030
    QkGate_C3X = 0x0000000000000031
    QkGate_C3SX = 0x0000000000000032
    QkGate_RC3X = 0x0000000000000033
end

@cenum QkOperationKind::UInt8 begin
    QkOperationKind_Gate = 0x0000000000000000
    QkOperationKind_Barrier = 0x0000000000000001
    QkOperationKind_Delay = 0x0000000000000002
    QkOperationKind_Measure = 0x0000000000000003
    QkOperationKind_Reset = 0x0000000000000004
    QkOperationKind_Unitary = 0x0000000000000005
    QkOperationKind_PauliProductMeasurement = 0x0000000000000006
    QkOperationKind_ControlFlow = 0x0000000000000007
    QkOperationKind_Unknown = 0x0000000000000008
    QkOperationKind_PauliProductRotation = 0x0000000000000009
end

@cenum QkDelayUnit::UInt8 begin
    QkDelayUnit_S = 0x0000000000000000
    QkDelayUnit_MS = 0x0000000000000001
    QkDelayUnit_US = 0x0000000000000002
    QkDelayUnit_NS = 0x0000000000000003
    QkDelayUnit_PS = 0x0000000000000004
end

@cenum QkVarsMode::UInt8 begin
    QkVarsMode_Alike = 0x0000000000000000
    QkVarsMode_Captures = 0x0000000000000001
    QkVarsMode_Drop = 0x0000000000000002
end

@cenum QkBlocksMode::UInt8 begin
    QkBlocksMode_Drop = 0x0000000000000000
    QkBlocksMode_Keep = 0x0000000000000001
end

@cenum QkDagNodeType::UInt8 begin
    QkDagNodeType_Operation = 0x0000000000000000
    QkDagNodeType_QubitIn = 0x0000000000000001
    QkDagNodeType_QubitOut = 0x0000000000000002
    QkDagNodeType_ClbitIn = 0x0000000000000003
    QkDagNodeType_ClbitOut = 0x0000000000000004
    QkDagNodeType_VarIn = 0x0000000000000005
    QkDagNodeType_VarOut = 0x0000000000000006
end

@cenum QkBitTerm::UInt8 begin
    QkBitTerm_X = 0x0000000000000002
    QkBitTerm_Plus = 0x000000000000000a
    QkBitTerm_Minus = 0x0000000000000006
    QkBitTerm_Y = 0x0000000000000003
    QkBitTerm_Right = 0x000000000000000b
    QkBitTerm_Left = 0x0000000000000007
    QkBitTerm_Z = 0x0000000000000001
    QkBitTerm_Zero = 0x0000000000000009
    QkBitTerm_One = 0x0000000000000005
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
    @ccall libqiskit.qk_api_version()::UInt32
end

function qk_circuit_new(num_qubits, num_clbits)
    @ccall libqiskit.qk_circuit_new(num_qubits::UInt32, num_clbits::UInt32)::Ptr{QkCircuit}
end

function qk_quantum_register_new(num_qubits, name)
    @ccall libqiskit.qk_quantum_register_new(num_qubits::UInt32, name::Ptr{Cchar})::Ptr{QkQuantumRegister}
end

function qk_quantum_register_free(reg)
    @ccall libqiskit.qk_quantum_register_free(reg::Ptr{QkQuantumRegister})::Cvoid
end

function qk_classical_register_free(reg)
    @ccall libqiskit.qk_classical_register_free(reg::Ptr{QkClassicalRegister})::Cvoid
end

function qk_classical_register_new(num_clbits, name)
    @ccall libqiskit.qk_classical_register_new(num_clbits::UInt32, name::Ptr{Cchar})::Ptr{QkClassicalRegister}
end

function qk_circuit_add_quantum_register(circuit, reg)
    @ccall libqiskit.qk_circuit_add_quantum_register(circuit::Ptr{QkCircuit}, reg::Ptr{QkQuantumRegister})::Cvoid
end

function qk_circuit_add_classical_register(circuit, reg)
    @ccall libqiskit.qk_circuit_add_classical_register(circuit::Ptr{QkCircuit}, reg::Ptr{QkClassicalRegister})::Cvoid
end

function qk_circuit_copy(circuit)
    @ccall libqiskit.qk_circuit_copy(circuit::Ptr{QkCircuit})::Ptr{QkCircuit}
end

function qk_circuit_num_qubits(circuit)
    @ccall libqiskit.qk_circuit_num_qubits(circuit::Ptr{QkCircuit})::UInt32
end

function qk_circuit_num_clbits(circuit)
    @ccall libqiskit.qk_circuit_num_clbits(circuit::Ptr{QkCircuit})::UInt32
end

function qk_circuit_num_param_symbols(circuit)
    @ccall libqiskit.qk_circuit_num_param_symbols(circuit::Ptr{QkCircuit})::Csize_t
end

function qk_circuit_free(circuit)
    @ccall libqiskit.qk_circuit_free(circuit::Ptr{QkCircuit})::Cvoid
end

function qk_circuit_gate(circuit, gate, qubits, params)
    @ccall libqiskit.qk_circuit_gate(circuit::Ptr{QkCircuit}, gate::QkGate, qubits::Ptr{UInt32}, params::Ptr{Cdouble})::QkExitCode
end

function qk_circuit_parameterized_gate(circuit, gate, qubits, params)
    @ccall libqiskit.qk_circuit_parameterized_gate(circuit::Ptr{QkCircuit}, gate::QkGate, qubits::Ptr{UInt32}, params::Ptr{Ptr{QkParam}})::QkExitCode
end

function qk_gate_num_qubits(gate)
    @ccall libqiskit.qk_gate_num_qubits(gate::QkGate)::UInt32
end

function qk_gate_num_params(gate)
    @ccall libqiskit.qk_gate_num_params(gate::QkGate)::UInt32
end

function qk_circuit_measure(circuit, qubit, clbit)
    @ccall libqiskit.qk_circuit_measure(circuit::Ptr{QkCircuit}, qubit::UInt32, clbit::UInt32)::QkExitCode
end

function qk_circuit_reset(circuit, qubit)
    @ccall libqiskit.qk_circuit_reset(circuit::Ptr{QkCircuit}, qubit::UInt32)::QkExitCode
end

function qk_circuit_barrier(circuit, qubits, num_qubits)
    @ccall libqiskit.qk_circuit_barrier(circuit::Ptr{QkCircuit}, qubits::Ptr{UInt32}, num_qubits::UInt32)::QkExitCode
end

function qk_circuit_unitary(circuit, matrix, qubits, num_qubits, check_input)
    @ccall libqiskit.qk_circuit_unitary(circuit::Ptr{QkCircuit}, matrix::Ptr{QkComplex64}, qubits::Ptr{UInt32}, num_qubits::UInt32, check_input::Bool)::QkExitCode
end

function qk_circuit_inst_unitary(circuit, index, out)
    @ccall libqiskit.qk_circuit_inst_unitary(circuit::Ptr{QkCircuit}, index::Csize_t, out::Ptr{QkComplex64})::Cvoid
end

function qk_circuit_instruction_kind(circuit, index)
    @ccall libqiskit.qk_circuit_instruction_kind(circuit::Ptr{QkCircuit}, index::Csize_t)::QkOperationKind
end

function qk_circuit_count_ops(circuit)
    @ccall libqiskit.qk_circuit_count_ops(circuit::Ptr{QkCircuit})::QkOpCounts
end

function qk_circuit_num_instructions(circuit)
    @ccall libqiskit.qk_circuit_num_instructions(circuit::Ptr{QkCircuit})::Csize_t
end

function qk_circuit_get_instruction(circuit, index, instruction)
    @ccall libqiskit.qk_circuit_get_instruction(circuit::Ptr{QkCircuit}, index::Csize_t, instruction::Ptr{QkCircuitInstruction})::Cvoid
end

function qk_circuit_pauli_product_rotation(circuit, rotation, qubits)
    @ccall libqiskit.qk_circuit_pauli_product_rotation(circuit::Ptr{QkCircuit}, rotation::Ptr{QkPauliProductRotation}, qubits::Ptr{UInt32})::Cvoid
end

function qk_circuit_inst_pauli_product_rotation(circuit, index, instruction)
    @ccall libqiskit.qk_circuit_inst_pauli_product_rotation(circuit::Ptr{QkCircuit}, index::Csize_t, instruction::Ptr{QkPauliProductRotation})::QkExitCode
end

function qk_circuit_pauli_product_measurement(circuit, measurement, qubits, clbit)
    @ccall libqiskit.qk_circuit_pauli_product_measurement(circuit::Ptr{QkCircuit}, measurement::Ptr{QkPauliProductMeasurement}, qubits::Ptr{UInt32}, clbit::UInt32)::Cvoid
end

function qk_circuit_inst_pauli_product_measurement(circuit, index, instruction)
    @ccall libqiskit.qk_circuit_inst_pauli_product_measurement(circuit::Ptr{QkCircuit}, index::Csize_t, instruction::Ptr{QkPauliProductMeasurement})::QkExitCode
end

function qk_circuit_instruction_clear(inst)
    @ccall libqiskit.qk_circuit_instruction_clear(inst::Ptr{QkCircuitInstruction})::Cvoid
end

function qk_opcounts_clear(op_counts)
    @ccall libqiskit.qk_opcounts_clear(op_counts::Ptr{QkOpCounts})::Cvoid
end

function qk_circuit_delay(circuit, qubit, duration, unit)
    @ccall libqiskit.qk_circuit_delay(circuit::Ptr{QkCircuit}, qubit::UInt32, duration::Cdouble, unit::QkDelayUnit)::QkExitCode
end

function qk_circuit_draw(circuit, config)
    @ccall libqiskit.qk_circuit_draw(circuit::Ptr{QkCircuit}, config::Ptr{QkCircuitDrawerConfig})::Ptr{Cchar}
end

function qk_circuit_to_dag(circuit)
    @ccall libqiskit.qk_circuit_to_dag(circuit::Ptr{QkCircuit})::Ptr{QkDag}
end

function qk_circuit_copy_empty_like(circuit, vars_mode, blocks_mode)
    @ccall libqiskit.qk_circuit_copy_empty_like(circuit::Ptr{QkCircuit}, vars_mode::QkVarsMode, blocks_mode::QkBlocksMode)::Ptr{QkCircuit}
end

function qk_circuit_library_iqp(num_qubits, interactions, check_input)
    @ccall libqiskit.qk_circuit_library_iqp(num_qubits::UInt32, interactions::Ptr{Int64}, check_input::Bool)::Ptr{QkCircuit}
end

function qk_circuit_library_random_iqp(num_qubits, seed)
    @ccall libqiskit.qk_circuit_library_random_iqp(num_qubits::UInt32, seed::Int64)::Ptr{QkCircuit}
end

function qk_pauli_product_rotation_clear(inst)
    @ccall libqiskit.qk_pauli_product_rotation_clear(inst::Ptr{QkPauliProductRotation})::Cvoid
end

function qk_pauli_product_measurement_clear(inst)
    @ccall libqiskit.qk_pauli_product_measurement_clear(inst::Ptr{QkPauliProductMeasurement})::Cvoid
end

function qk_circuit_library_quantum_volume(num_qubits, depth, seed)
    @ccall libqiskit.qk_circuit_library_quantum_volume(num_qubits::UInt32, depth::Csize_t, seed::Int64)::Ptr{QkCircuit}
end

function qk_circuit_library_suzuki_trotter(op, order, reps, time, preserve_order, insert_barriers)
    @ccall libqiskit.qk_circuit_library_suzuki_trotter(op::Ptr{QkObs}, order::UInt32, reps::UInt32, time::Cdouble, preserve_order::Bool, insert_barriers::Bool)::Ptr{QkCircuit}
end

function qk_dag_new()
    @ccall libqiskit.qk_dag_new()::Ptr{QkDag}
end

function qk_dag_add_quantum_register(dag, reg)
    @ccall libqiskit.qk_dag_add_quantum_register(dag::Ptr{QkDag}, reg::Ptr{QkQuantumRegister})::Cvoid
end

function qk_dag_add_classical_register(dag, reg)
    @ccall libqiskit.qk_dag_add_classical_register(dag::Ptr{QkDag}, reg::Ptr{QkClassicalRegister})::Cvoid
end

function qk_dag_num_qubits(dag)
    @ccall libqiskit.qk_dag_num_qubits(dag::Ptr{QkDag})::UInt32
end

function qk_dag_num_clbits(dag)
    @ccall libqiskit.qk_dag_num_clbits(dag::Ptr{QkDag})::UInt32
end

function qk_dag_num_op_nodes(dag)
    @ccall libqiskit.qk_dag_num_op_nodes(dag::Ptr{QkDag})::Csize_t
end

function qk_dag_node_type(dag, node)
    @ccall libqiskit.qk_dag_node_type(dag::Ptr{QkDag}, node::UInt32)::QkDagNodeType
end

function qk_dag_qubit_in_node(dag, qubit)
    @ccall libqiskit.qk_dag_qubit_in_node(dag::Ptr{QkDag}, qubit::UInt32)::UInt32
end

function qk_dag_qubit_out_node(dag, qubit)
    @ccall libqiskit.qk_dag_qubit_out_node(dag::Ptr{QkDag}, qubit::UInt32)::UInt32
end

function qk_dag_clbit_in_node(dag, clbit)
    @ccall libqiskit.qk_dag_clbit_in_node(dag::Ptr{QkDag}, clbit::UInt32)::UInt32
end

function qk_dag_clbit_out_node(dag, clbit)
    @ccall libqiskit.qk_dag_clbit_out_node(dag::Ptr{QkDag}, clbit::UInt32)::UInt32
end

function qk_dag_wire_node_value(dag, node)
    @ccall libqiskit.qk_dag_wire_node_value(dag::Ptr{QkDag}, node::UInt32)::UInt32
end

function qk_dag_op_node_num_qubits(dag, node)
    @ccall libqiskit.qk_dag_op_node_num_qubits(dag::Ptr{QkDag}, node::UInt32)::UInt32
end

function qk_dag_op_node_num_clbits(dag, node)
    @ccall libqiskit.qk_dag_op_node_num_clbits(dag::Ptr{QkDag}, node::UInt32)::UInt32
end

function qk_dag_op_node_num_params(dag, node)
    @ccall libqiskit.qk_dag_op_node_num_params(dag::Ptr{QkDag}, node::UInt32)::UInt32
end

function qk_dag_op_node_qubits(dag, node)
    @ccall libqiskit.qk_dag_op_node_qubits(dag::Ptr{QkDag}, node::UInt32)::Ptr{UInt32}
end

function qk_dag_op_node_clbits(dag, node)
    @ccall libqiskit.qk_dag_op_node_clbits(dag::Ptr{QkDag}, node::UInt32)::Ptr{UInt32}
end

function qk_dag_apply_gate(dag, gate, qubits, params, front)
    @ccall libqiskit.qk_dag_apply_gate(dag::Ptr{QkDag}, gate::QkGate, qubits::Ptr{UInt32}, params::Ptr{Cdouble}, front::Bool)::UInt32
end

function qk_dag_apply_measure(dag, qubit, clbit, front)
    @ccall libqiskit.qk_dag_apply_measure(dag::Ptr{QkDag}, qubit::UInt32, clbit::UInt32, front::Bool)::UInt32
end

function qk_dag_apply_reset(dag, qubit, front)
    @ccall libqiskit.qk_dag_apply_reset(dag::Ptr{QkDag}, qubit::UInt32, front::Bool)::UInt32
end

function qk_dag_apply_barrier(dag, qubits, num_qubits, front)
    @ccall libqiskit.qk_dag_apply_barrier(dag::Ptr{QkDag}, qubits::Ptr{UInt32}, num_qubits::UInt32, front::Bool)::UInt32
end

function qk_dag_apply_unitary(dag, matrix, qubits, num_qubits, front)
    @ccall libqiskit.qk_dag_apply_unitary(dag::Ptr{QkDag}, matrix::Ptr{QkComplex64}, qubits::Ptr{UInt32}, num_qubits::UInt32, front::Bool)::UInt32
end

function qk_dag_op_node_gate_op(dag, node, out_params)
    @ccall libqiskit.qk_dag_op_node_gate_op(dag::Ptr{QkDag}, node::UInt32, out_params::Ptr{Cdouble})::QkGate
end

function qk_dag_op_node_unitary(dag, node, out)
    @ccall libqiskit.qk_dag_op_node_unitary(dag::Ptr{QkDag}, node::UInt32, out::Ptr{QkComplex64})::Cvoid
end

function qk_dag_op_node_kind(dag, node)
    @ccall libqiskit.qk_dag_op_node_kind(dag::Ptr{QkDag}, node::UInt32)::QkOperationKind
end

function qk_dag_successors(dag, node)
    @ccall libqiskit.qk_dag_successors(dag::Ptr{QkDag}, node::UInt32)::QkDagNeighbors
end

function qk_dag_predecessors(dag, node)
    @ccall libqiskit.qk_dag_predecessors(dag::Ptr{QkDag}, node::UInt32)::QkDagNeighbors
end

function qk_dag_neighbors_clear(neighbors)
    @ccall libqiskit.qk_dag_neighbors_clear(neighbors::Ptr{QkDagNeighbors})::Cvoid
end

function qk_dag_get_instruction(dag, index, instruction)
    @ccall libqiskit.qk_dag_get_instruction(dag::Ptr{QkDag}, index::UInt32, instruction::Ptr{QkCircuitInstruction})::Cvoid
end

function qk_dag_compose(dag, other, qubits, clbits)
    @ccall libqiskit.qk_dag_compose(dag::Ptr{QkDag}, other::Ptr{QkDag}, qubits::Ptr{UInt32}, clbits::Ptr{UInt32})::QkExitCode
end

function qk_dag_free(dag)
    @ccall libqiskit.qk_dag_free(dag::Ptr{QkDag})::Cvoid
end

function qk_dag_to_circuit(dag)
    @ccall libqiskit.qk_dag_to_circuit(dag::Ptr{QkDag})::Ptr{QkCircuit}
end

function qk_dag_topological_op_nodes(dag, out_order)
    @ccall libqiskit.qk_dag_topological_op_nodes(dag::Ptr{QkDag}, out_order::Ptr{UInt32})::Cvoid
end

function qk_dag_substitute_node_with_dag(dag, node, replacement)
    @ccall libqiskit.qk_dag_substitute_node_with_dag(dag::Ptr{QkDag}, node::UInt32, replacement::Ptr{QkDag})::Cvoid
end

function qk_dag_copy_empty_like(dag, vars_mode, blocks_mode)
    @ccall libqiskit.qk_dag_copy_empty_like(dag::Ptr{QkDag}, vars_mode::QkVarsMode, blocks_mode::QkBlocksMode)::Ptr{QkDag}
end

function qk_dag_replace_block_with_unitary(dag, num_block_ids, block_ids, matrix, num_qubits, qubits, cycle_check)
    @ccall libqiskit.qk_dag_replace_block_with_unitary(dag::Ptr{QkDag}, num_block_ids::UInt32, block_ids::Ptr{UInt32}, matrix::Ptr{QkComplex64}, num_qubits::UInt32, qubits::Ptr{UInt32}, cycle_check::Bool)::UInt32
end

function qk_dag_substitute_node_with_unitary(dag, node, matrix, num_qubits)
    @ccall libqiskit.qk_dag_substitute_node_with_unitary(dag::Ptr{QkDag}, node::UInt32, matrix::Ptr{QkComplex64}, num_qubits::UInt32)::Cvoid
end

function qk_param_new_symbol(name)
    @ccall libqiskit.qk_param_new_symbol(name::Ptr{Cchar})::Ptr{QkParam}
end

function qk_param_zero()
    @ccall libqiskit.qk_param_zero()::Ptr{QkParam}
end

function qk_param_free(param)
    @ccall libqiskit.qk_param_free(param::Ptr{QkParam})::Cvoid
end

function qk_param_from_double(value)
    @ccall libqiskit.qk_param_from_double(value::Cdouble)::Ptr{QkParam}
end

function qk_param_from_complex(value)
    @ccall libqiskit.qk_param_from_complex(value::QkComplex64)::Ptr{QkParam}
end

function qk_param_copy(param)
    @ccall libqiskit.qk_param_copy(param::Ptr{QkParam})::Ptr{QkParam}
end

function qk_param_str(param)
    @ccall libqiskit.qk_param_str(param::Ptr{QkParam})::Ptr{Cchar}
end

function qk_param_add(out, lhs, rhs)
    @ccall libqiskit.qk_param_add(out::Ptr{QkParam}, lhs::Ptr{QkParam}, rhs::Ptr{QkParam})::QkExitCode
end

function qk_param_sub(out, lhs, rhs)
    @ccall libqiskit.qk_param_sub(out::Ptr{QkParam}, lhs::Ptr{QkParam}, rhs::Ptr{QkParam})::QkExitCode
end

function qk_param_mul(out, lhs, rhs)
    @ccall libqiskit.qk_param_mul(out::Ptr{QkParam}, lhs::Ptr{QkParam}, rhs::Ptr{QkParam})::QkExitCode
end

function qk_param_div(out, num, den)
    @ccall libqiskit.qk_param_div(out::Ptr{QkParam}, num::Ptr{QkParam}, den::Ptr{QkParam})::QkExitCode
end

function qk_param_pow(out, base, pow)
    @ccall libqiskit.qk_param_pow(out::Ptr{QkParam}, base::Ptr{QkParam}, pow::Ptr{QkParam})::QkExitCode
end

function qk_param_sin(out, src)
    @ccall libqiskit.qk_param_sin(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_cos(out, src)
    @ccall libqiskit.qk_param_cos(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_tan(out, src)
    @ccall libqiskit.qk_param_tan(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_asin(out, src)
    @ccall libqiskit.qk_param_asin(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_acos(out, src)
    @ccall libqiskit.qk_param_acos(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_atan(out, src)
    @ccall libqiskit.qk_param_atan(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_log(out, src)
    @ccall libqiskit.qk_param_log(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_exp(out, src)
    @ccall libqiskit.qk_param_exp(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_abs(out, src)
    @ccall libqiskit.qk_param_abs(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_sign(out, src)
    @ccall libqiskit.qk_param_sign(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_neg(out, src)
    @ccall libqiskit.qk_param_neg(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_conjugate(out, src)
    @ccall libqiskit.qk_param_conjugate(out::Ptr{QkParam}, src::Ptr{QkParam})::QkExitCode
end

function qk_param_equal(lhs, rhs)
    @ccall libqiskit.qk_param_equal(lhs::Ptr{QkParam}, rhs::Ptr{QkParam})::Bool
end

function qk_param_as_real(param)
    @ccall libqiskit.qk_param_as_real(param::Ptr{QkParam})::Cdouble
end

function qk_obs_zero(num_qubits)
    @ccall libqiskit.qk_obs_zero(num_qubits::UInt32)::Ptr{QkObs}
end

function qk_obs_identity(num_qubits)
    @ccall libqiskit.qk_obs_identity(num_qubits::UInt32)::Ptr{QkObs}
end

function qk_obs_new(num_qubits, num_terms, num_bits, coeffs, bit_terms, indices, boundaries)
    @ccall libqiskit.qk_obs_new(num_qubits::UInt32, num_terms::UInt64, num_bits::UInt64, coeffs::Ptr{QkComplex64}, bit_terms::Ptr{QkBitTerm}, indices::Ptr{UInt32}, boundaries::Ptr{Csize_t})::Ptr{QkObs}
end

function qk_obs_free(obs)
    @ccall libqiskit.qk_obs_free(obs::Ptr{QkObs})::Cvoid
end

function qk_obs_add_term(obs, cterm)
    @ccall libqiskit.qk_obs_add_term(obs::Ptr{QkObs}, cterm::Ptr{QkObsTerm})::QkExitCode
end

function qk_obs_term(obs, index, out)
    @ccall libqiskit.qk_obs_term(obs::Ptr{QkObs}, index::UInt64, out::Ptr{QkObsTerm})::QkExitCode
end

function qk_obs_num_terms(obs)
    @ccall libqiskit.qk_obs_num_terms(obs::Ptr{QkObs})::Csize_t
end

function qk_obs_num_qubits(obs)
    @ccall libqiskit.qk_obs_num_qubits(obs::Ptr{QkObs})::UInt32
end

function qk_obs_len(obs)
    @ccall libqiskit.qk_obs_len(obs::Ptr{QkObs})::Csize_t
end

function qk_obs_coeffs(obs)
    @ccall libqiskit.qk_obs_coeffs(obs::Ptr{QkObs})::Ptr{QkComplex64}
end

function qk_obs_indices(obs)
    @ccall libqiskit.qk_obs_indices(obs::Ptr{QkObs})::Ptr{UInt32}
end

function qk_obs_boundaries(obs)
    @ccall libqiskit.qk_obs_boundaries(obs::Ptr{QkObs})::Ptr{Csize_t}
end

function qk_obs_bit_terms(obs)
    @ccall libqiskit.qk_obs_bit_terms(obs::Ptr{QkObs})::Ptr{QkBitTerm}
end

function qk_obs_multiply(obs, coeff)
    @ccall libqiskit.qk_obs_multiply(obs::Ptr{QkObs}, coeff::Ptr{QkComplex64})::Ptr{QkObs}
end

function qk_obs_multiply_inplace(obs, coeff)
    @ccall libqiskit.qk_obs_multiply_inplace(obs::Ptr{QkObs}, coeff::Ptr{QkComplex64})::Cvoid
end

function qk_obs_add(left, right)
    @ccall libqiskit.qk_obs_add(left::Ptr{QkObs}, right::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_add_inplace(left, right)
    @ccall libqiskit.qk_obs_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs})::Cvoid
end

function qk_obs_scaled_add(left, right, factor)
    @ccall libqiskit.qk_obs_scaled_add(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::Ptr{QkComplex64})::Ptr{QkObs}
end

function qk_obs_scaled_add_inplace(left, right, factor)
    @ccall libqiskit.qk_obs_scaled_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::Ptr{QkComplex64})::Cvoid
end

function qk_obs_compose(first, second)
    @ccall libqiskit.qk_obs_compose(first::Ptr{QkObs}, second::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_compose_map(first, second, qargs)
    @ccall libqiskit.qk_obs_compose_map(first::Ptr{QkObs}, second::Ptr{QkObs}, qargs::Ptr{UInt32})::Ptr{QkObs}
end

function qk_obs_apply_layout(obs, layout, num_qubits)
    @ccall libqiskit.qk_obs_apply_layout(obs::Ptr{QkObs}, layout::Ptr{UInt32}, num_qubits::UInt32)::QkExitCode
end

function qk_obs_canonicalize(obs, tol)
    @ccall libqiskit.qk_obs_canonicalize(obs::Ptr{QkObs}, tol::Cdouble)::Ptr{QkObs}
end

function qk_obs_copy(obs)
    @ccall libqiskit.qk_obs_copy(obs::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_equal(obs, other)
    @ccall libqiskit.qk_obs_equal(obs::Ptr{QkObs}, other::Ptr{QkObs})::Bool
end

function qk_obs_str(obs)
    @ccall libqiskit.qk_obs_str(obs::Ptr{QkObs})::Ptr{Cchar}
end

function qk_str_free(string)
    @ccall libqiskit.qk_str_free(string::Ptr{Cchar})::Cvoid
end

function qk_obsterm_str(term)
    @ccall libqiskit.qk_obsterm_str(term::Ptr{QkObsTerm})::Ptr{Cchar}
end

function qk_bitterm_label(bit_term)
    @ccall libqiskit.qk_bitterm_label(bit_term::QkBitTerm)::UInt8
end

function qk_neighbors_is_all_to_all(neighbors)
    @ccall libqiskit.qk_neighbors_is_all_to_all(neighbors::Ptr{QkNeighbors})::Bool
end

function qk_neighbors_from_target(target, neighbors)
    @ccall libqiskit.qk_neighbors_from_target(target::Ptr{QkTarget}, neighbors::Ptr{QkNeighbors})::Bool
end

function qk_neighbors_clear(neighbors)
    @ccall libqiskit.qk_neighbors_clear(neighbors::Ptr{QkNeighbors})::Cvoid
end

function qk_transpiler_pass_standalone_basis_translator(circuit, target, min_qubits)
    @ccall libqiskit.qk_transpiler_pass_standalone_basis_translator(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, min_qubits::Csize_t)::Cvoid
end

function qk_transpiler_pass_standalone_commutative_cancellation(circuit, target, approximation_degree)
    @ccall libqiskit.qk_transpiler_pass_standalone_commutative_cancellation(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, approximation_degree::Cdouble)::QkExitCode
end

function qk_transpiler_pass_standalone_consolidate_blocks(circuit, target, approximation_degree, force_consolidate)
    @ccall libqiskit.qk_transpiler_pass_standalone_consolidate_blocks(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, approximation_degree::Cdouble, force_consolidate::Bool)::Cvoid
end

function qk_transpiler_pass_standalone_convert_to_pauli_rotations(circuit)
    @ccall libqiskit.qk_transpiler_pass_standalone_convert_to_pauli_rotations(circuit::Ptr{QkCircuit})::Cvoid
end

function qk_transpiler_pass_standalone_elide_permutations(circuit)
    @ccall libqiskit.qk_transpiler_pass_standalone_elide_permutations(circuit::Ptr{QkCircuit})::Ptr{QkTranspileLayout}
end

function qk_transpiler_pass_elide_permutations(dag)
    @ccall libqiskit.qk_transpiler_pass_elide_permutations(dag::Ptr{QkDag})::Ptr{QkTranspileLayout}
end

function qk_transpiler_pass_standalone_check_gate_direction(circuit, target)
    @ccall libqiskit.qk_transpiler_pass_standalone_check_gate_direction(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget})::Bool
end

function qk_transpiler_pass_standalone_gate_direction(circuit, target)
    @ccall libqiskit.qk_transpiler_pass_standalone_gate_direction(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget})::Cvoid
end

function qk_transpiler_pass_check_gate_direction(dag, target)
    @ccall libqiskit.qk_transpiler_pass_check_gate_direction(dag::Ptr{QkDag}, target::Ptr{QkTarget})::Bool
end

function qk_transpiler_pass_gate_direction(dag, target)
    @ccall libqiskit.qk_transpiler_pass_gate_direction(dag::Ptr{QkDag}, target::Ptr{QkTarget})::Cvoid
end

function qk_transpiler_pass_standalone_inverse_cancellation(circuit)
    @ccall libqiskit.qk_transpiler_pass_standalone_inverse_cancellation(circuit::Ptr{QkCircuit})::Cvoid
end

function qk_transpiler_pass_standalone_litinski_transformation(circuit, fix_clifford)
    @ccall libqiskit.qk_transpiler_pass_standalone_litinski_transformation(circuit::Ptr{QkCircuit}, fix_clifford::Bool)::Cvoid
end

function qk_transpiler_standalone_optimize_1q_sequences(circuit, target)
    @ccall libqiskit.qk_transpiler_standalone_optimize_1q_sequences(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget})::Cvoid
end

function qk_transpiler_pass_standalone_optimize_1q_sequences(circuit, target)
    @ccall libqiskit.qk_transpiler_pass_standalone_optimize_1q_sequences(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget})::Cvoid
end

function qk_transpiler_pass_optimize_1q_sequences(dag, target)
    @ccall libqiskit.qk_transpiler_pass_optimize_1q_sequences(dag::Ptr{QkDag}, target::Ptr{QkTarget})::Cvoid
end

function qk_transpiler_pass_standalone_remove_diagonal_gates_before_measure(circuit)
    @ccall libqiskit.qk_transpiler_pass_standalone_remove_diagonal_gates_before_measure(circuit::Ptr{QkCircuit})::Cvoid
end

function qk_transpiler_pass_remove_diagonal_gates_before_measure(dag)
    @ccall libqiskit.qk_transpiler_pass_remove_diagonal_gates_before_measure(dag::Ptr{QkDag})::Cvoid
end

function qk_transpiler_pass_standalone_remove_identity_equivalent(circuit, target, approximation_degree)
    @ccall libqiskit.qk_transpiler_pass_standalone_remove_identity_equivalent(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, approximation_degree::Cdouble)::Cvoid
end

function qk_transpiler_pass_remove_identity_equivalent(dag, target, approximation_degree)
    @ccall libqiskit.qk_transpiler_pass_remove_identity_equivalent(dag::Ptr{QkDag}, target::Ptr{QkTarget}, approximation_degree::Cdouble)::Cvoid
end

function qk_sabre_layout_options_default()
    @ccall libqiskit.qk_sabre_layout_options_default()::QkSabreLayoutOptions
end

function qk_transpiler_pass_standalone_sabre_layout(circuit, target, options)
    @ccall libqiskit.qk_transpiler_pass_standalone_sabre_layout(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, options::Ptr{QkSabreLayoutOptions})::Ptr{QkTranspileLayout}
end

function qk_transpiler_pass_standalone_split_2q_unitaries(circuit, requested_fidelity, split_swaps)
    @ccall libqiskit.qk_transpiler_pass_standalone_split_2q_unitaries(circuit::Ptr{QkCircuit}, requested_fidelity::Cdouble, split_swaps::Bool)::Ptr{QkTranspileLayout}
end

function qk_transpiler_pass_split_2q_unitaries(dag, requested_fidelity, split_swaps)
    @ccall libqiskit.qk_transpiler_pass_split_2q_unitaries(dag::Ptr{QkDag}, requested_fidelity::Cdouble, split_swaps::Bool)::Ptr{QkTranspileLayout}
end

function qk_transpiler_pass_standalone_unitary_synthesis(circuit, target, min_qubits, approximation_degree)
    @ccall libqiskit.qk_transpiler_pass_standalone_unitary_synthesis(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, min_qubits::Csize_t, approximation_degree::Cdouble)::Cvoid
end

function qk_vf2_layout_result_has_match(layout)
    @ccall libqiskit.qk_vf2_layout_result_has_match(layout::Ptr{QkVF2LayoutResult})::Bool
end

function qk_vf2_layout_result_has_improvement(layout)
    @ccall libqiskit.qk_vf2_layout_result_has_improvement(layout::Ptr{QkVF2LayoutResult})::Bool
end

function qk_vf2_layout_result_map_virtual_qubit(layout, qubit)
    @ccall libqiskit.qk_vf2_layout_result_map_virtual_qubit(layout::Ptr{QkVF2LayoutResult}, qubit::UInt32)::UInt32
end

function qk_vf2_layout_result_free(layout)
    @ccall libqiskit.qk_vf2_layout_result_free(layout::Ptr{QkVF2LayoutResult})::Cvoid
end

function qk_vf2_layout_configuration_new()
    @ccall libqiskit.qk_vf2_layout_configuration_new()::Ptr{QkVF2LayoutConfiguration}
end

function qk_vf2_layout_configuration_free(config)
    @ccall libqiskit.qk_vf2_layout_configuration_free(config::Ptr{QkVF2LayoutConfiguration})::Cvoid
end

function qk_vf2_layout_configuration_set_call_limit(config, before, after)
    @ccall libqiskit.qk_vf2_layout_configuration_set_call_limit(config::Ptr{QkVF2LayoutConfiguration}, before::Int64, after::Int64)::Cvoid
end

function qk_vf2_layout_configuration_set_time_limit(config, limit)
    @ccall libqiskit.qk_vf2_layout_configuration_set_time_limit(config::Ptr{QkVF2LayoutConfiguration}, limit::Cdouble)::Cvoid
end

function qk_vf2_layout_configuration_set_max_trials(config, limit)
    @ccall libqiskit.qk_vf2_layout_configuration_set_max_trials(config::Ptr{QkVF2LayoutConfiguration}, limit::UInt64)::Cvoid
end

function qk_vf2_layout_configuration_set_shuffle_seed(config, seed)
    @ccall libqiskit.qk_vf2_layout_configuration_set_shuffle_seed(config::Ptr{QkVF2LayoutConfiguration}, seed::UInt64)::Cvoid
end

function qk_vf2_layout_configuration_set_score_initial(config, score_initial)
    @ccall libqiskit.qk_vf2_layout_configuration_set_score_initial(config::Ptr{QkVF2LayoutConfiguration}, score_initial::Bool)::Cvoid
end

function qk_transpiler_pass_standalone_vf2_layout_average(circuit, target, config, strict_direction)
    @ccall libqiskit.qk_transpiler_pass_standalone_vf2_layout_average(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, config::Ptr{QkVF2LayoutConfiguration}, strict_direction::Bool)::Ptr{QkVF2LayoutResult}
end

function qk_transpiler_pass_standalone_vf2_layout_exact(circuit, target, config)
    @ccall libqiskit.qk_transpiler_pass_standalone_vf2_layout_exact(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, config::Ptr{QkVF2LayoutConfiguration})::Ptr{QkVF2LayoutResult}
end

function qk_transpiler_pass_standalone_vf2_layout(circuit, target, strict_direction, call_limit, time_limit, max_trials)
    @ccall libqiskit.qk_transpiler_pass_standalone_vf2_layout(circuit::Ptr{QkCircuit}, target::Ptr{QkTarget}, strict_direction::Bool, call_limit::Int64, time_limit::Cdouble, max_trials::Int64)::Ptr{QkVF2LayoutResult}
end

function qk_target_new(num_qubits)
    @ccall libqiskit.qk_target_new(num_qubits::UInt32)::Ptr{QkTarget}
end

function qk_target_num_qubits(target)
    @ccall libqiskit.qk_target_num_qubits(target::Ptr{QkTarget})::UInt32
end

function qk_target_dt(target)
    @ccall libqiskit.qk_target_dt(target::Ptr{QkTarget})::Cdouble
end

function qk_target_granularity(target)
    @ccall libqiskit.qk_target_granularity(target::Ptr{QkTarget})::UInt32
end

function qk_target_min_length(target)
    @ccall libqiskit.qk_target_min_length(target::Ptr{QkTarget})::UInt32
end

function qk_target_pulse_alignment(target)
    @ccall libqiskit.qk_target_pulse_alignment(target::Ptr{QkTarget})::UInt32
end

function qk_target_acquire_alignment(target)
    @ccall libqiskit.qk_target_acquire_alignment(target::Ptr{QkTarget})::UInt32
end

function qk_target_set_dt(target, dt)
    @ccall libqiskit.qk_target_set_dt(target::Ptr{QkTarget}, dt::Cdouble)::QkExitCode
end

function qk_target_set_granularity(target, granularity)
    @ccall libqiskit.qk_target_set_granularity(target::Ptr{QkTarget}, granularity::UInt32)::QkExitCode
end

function qk_target_set_min_length(target, min_length)
    @ccall libqiskit.qk_target_set_min_length(target::Ptr{QkTarget}, min_length::UInt32)::QkExitCode
end

function qk_target_set_pulse_alignment(target, pulse_alignment)
    @ccall libqiskit.qk_target_set_pulse_alignment(target::Ptr{QkTarget}, pulse_alignment::UInt32)::QkExitCode
end

function qk_target_set_acquire_alignment(target, acquire_alignment)
    @ccall libqiskit.qk_target_set_acquire_alignment(target::Ptr{QkTarget}, acquire_alignment::UInt32)::QkExitCode
end

function qk_target_copy(target)
    @ccall libqiskit.qk_target_copy(target::Ptr{QkTarget})::Ptr{QkTarget}
end

function qk_target_free(target)
    @ccall libqiskit.qk_target_free(target::Ptr{QkTarget})::Cvoid
end

function qk_target_entry_new(operation)
    @ccall libqiskit.qk_target_entry_new(operation::QkGate)::Ptr{QkTargetEntry}
end

function qk_target_entry_new_measure()
    @ccall libqiskit.qk_target_entry_new_measure()::Ptr{QkTargetEntry}
end

function qk_target_entry_new_reset()
    @ccall libqiskit.qk_target_entry_new_reset()::Ptr{QkTargetEntry}
end

function qk_target_entry_new_fixed(operation, params, name)
    @ccall libqiskit.qk_target_entry_new_fixed(operation::QkGate, params::Ptr{Cdouble}, name::Ptr{Cchar})::Ptr{QkTargetEntry}
end

function qk_target_entry_num_properties(entry)
    @ccall libqiskit.qk_target_entry_num_properties(entry::Ptr{QkTargetEntry})::Csize_t
end

function qk_target_entry_free(entry)
    @ccall libqiskit.qk_target_entry_free(entry::Ptr{QkTargetEntry})::Cvoid
end

function qk_target_entry_add_property(entry, qargs, num_qubits, duration, error)
    @ccall libqiskit.qk_target_entry_add_property(entry::Ptr{QkTargetEntry}, qargs::Ptr{UInt32}, num_qubits::UInt32, duration::Cdouble, error::Cdouble)::QkExitCode
end

function qk_target_entry_set_name(entry, name)
    @ccall libqiskit.qk_target_entry_set_name(entry::Ptr{QkTargetEntry}, name::Ptr{Cchar})::QkExitCode
end

function qk_target_add_instruction(target, target_entry)
    @ccall libqiskit.qk_target_add_instruction(target::Ptr{QkTarget}, target_entry::Ptr{QkTargetEntry})::QkExitCode
end

function qk_target_update_property(target, instruction, qargs, num_qubits, duration, error)
    @ccall libqiskit.qk_target_update_property(target::Ptr{QkTarget}, instruction::QkGate, qargs::Ptr{UInt32}, num_qubits::UInt32, duration::Cdouble, error::Cdouble)::QkExitCode
end

function qk_target_num_instructions(target)
    @ccall libqiskit.qk_target_num_instructions(target::Ptr{QkTarget})::Csize_t
end

function qk_target_instruction_supported(target, operation_name, qargs, params)
    @ccall libqiskit.qk_target_instruction_supported(target::Ptr{QkTarget}, operation_name::Ptr{Cchar}, qargs::Ptr{UInt32}, params::Ptr{Ptr{QkParam}})::Bool
end

function qk_target_op_index(target, name)
    @ccall libqiskit.qk_target_op_index(target::Ptr{QkTarget}, name::Ptr{Cchar})::Csize_t
end

function qk_target_op_name(target, index)
    @ccall libqiskit.qk_target_op_name(target::Ptr{QkTarget}, index::Csize_t)::Ptr{Cchar}
end

function qk_target_op_num_properties(target, index)
    @ccall libqiskit.qk_target_op_num_properties(target::Ptr{QkTarget}, index::Csize_t)::Csize_t
end

function qk_target_op_qargs_index(target, op_idx, qargs)
    @ccall libqiskit.qk_target_op_qargs_index(target::Ptr{QkTarget}, op_idx::Csize_t, qargs::Ptr{UInt32})::Csize_t
end

function qk_target_op_qargs(target, op_idx, qarg_idx, qargs_out, qargs_len)
    @ccall libqiskit.qk_target_op_qargs(target::Ptr{QkTarget}, op_idx::Csize_t, qarg_idx::Csize_t, qargs_out::Ptr{Ptr{UInt32}}, qargs_len::Ptr{UInt32})::Cvoid
end

function qk_target_op_props(target, op_idx, qarg_idx, inst_props)
    @ccall libqiskit.qk_target_op_props(target::Ptr{QkTarget}, op_idx::Csize_t, qarg_idx::Csize_t, inst_props::Ptr{QkInstructionProperties})::Cvoid
end

function qk_target_op_get(target, index, out_op)
    @ccall libqiskit.qk_target_op_get(target::Ptr{QkTarget}, index::Csize_t, out_op::Ptr{QkTargetOp})::Cvoid
end

function qk_target_op_gate(target, index)
    @ccall libqiskit.qk_target_op_gate(target::Ptr{QkTarget}, index::Csize_t)::QkGate
end

function qk_target_op_clear(op)
    @ccall libqiskit.qk_target_op_clear(op::Ptr{QkTargetOp})::Cvoid
end

function qk_transpile_state_new(state)
    @ccall libqiskit.qk_transpile_state_new(state::Ptr{Ptr{QkTranspilerStageState}})::Cvoid
end

function qk_transpile_state_free(state)
    @ccall libqiskit.qk_transpile_state_free(state::Ptr{QkTranspilerStageState})::Cvoid
end

function qk_transpile_state_layout(state)
    @ccall libqiskit.qk_transpile_state_layout(state::Ptr{QkTranspilerStageState})::Ptr{QkTranspileLayout}
end

function qk_transpile_state_layout_set(state, layout)
    @ccall libqiskit.qk_transpile_state_layout_set(state::Ptr{QkTranspilerStageState}, layout::Ptr{QkTranspileLayout})::Cvoid
end

function qk_transpiler_default_options()
    @ccall libqiskit.qk_transpiler_default_options()::QkTranspileOptions
end

function qk_transpile_stage_init(dag, target, options, state, error)
    @ccall libqiskit.qk_transpile_stage_init(dag::Ptr{QkDag}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, state::Ptr{Ptr{QkTranspilerStageState}}, error::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile_stage_routing(dag, target, options, state, error)
    @ccall libqiskit.qk_transpile_stage_routing(dag::Ptr{QkDag}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, state::Ptr{QkTranspilerStageState}, error::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile_stage_optimization(dag, target, options, error, state)
    @ccall libqiskit.qk_transpile_stage_optimization(dag::Ptr{QkDag}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, error::Ptr{Ptr{Cchar}}, state::Ptr{QkTranspilerStageState})::QkExitCode
end

function qk_transpile_stage_translation(dag, target, options, error)
    @ccall libqiskit.qk_transpile_stage_translation(dag::Ptr{QkDag}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, error::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile_stage_layout(dag, target, options, state, error)
    @ccall libqiskit.qk_transpile_stage_layout(dag::Ptr{QkDag}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, state::Ptr{Ptr{QkTranspilerStageState}}, error::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile(qc, target, options, result, error)
    @ccall libqiskit.qk_transpile(qc::Ptr{QkCircuit}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, result::Ptr{QkTranspileResult}, error::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile_layout_num_input_qubits(layout)
    @ccall libqiskit.qk_transpile_layout_num_input_qubits(layout::Ptr{QkTranspileLayout})::UInt32
end

function qk_transpile_layout_num_output_qubits(layout)
    @ccall libqiskit.qk_transpile_layout_num_output_qubits(layout::Ptr{QkTranspileLayout})::UInt32
end

function qk_transpile_layout_initial_layout(layout, filter_ancillas, initial_layout)
    @ccall libqiskit.qk_transpile_layout_initial_layout(layout::Ptr{QkTranspileLayout}, filter_ancillas::Bool, initial_layout::Ptr{UInt32})::Bool
end

function qk_transpile_layout_output_permutation(layout, output_permutation)
    @ccall libqiskit.qk_transpile_layout_output_permutation(layout::Ptr{QkTranspileLayout}, output_permutation::Ptr{UInt32})::Bool
end

function qk_transpile_layout_final_layout(layout, filter_ancillas, final_layout)
    @ccall libqiskit.qk_transpile_layout_final_layout(layout::Ptr{QkTranspileLayout}, filter_ancillas::Bool, final_layout::Ptr{UInt32})::Cvoid
end

function qk_transpile_layout_generate_from_mapping(original_dag, target, qubit_mapping)
    @ccall libqiskit.qk_transpile_layout_generate_from_mapping(original_dag::Ptr{QkDag}, target::Ptr{QkTarget}, qubit_mapping::Ptr{UInt32})::Ptr{QkTranspileLayout}
end

function qk_transpile_layout_free(layout)
    @ccall libqiskit.qk_transpile_layout_free(layout::Ptr{QkTranspileLayout})::Cvoid
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
