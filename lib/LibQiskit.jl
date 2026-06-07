module LibQiskit

using Qiskit_jll
export Qiskit_jll

using CEnum: CEnum, @cenum

mutable struct QkQuantumRegister end

mutable struct QkClassicalRegister end

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

@cenum QkExitCode::UInt32 begin
    QkExitCode_Success = 0x0000000000000000
    QkExitCode_CInputError = 0x0000000000000064
    QkExitCode_NullPointerError = 0x0000000000000065
    QkExitCode_AlignmentError = 0x0000000000000066
    QkExitCode_IndexError = 0x0000000000000067
    QkExitCode_DuplicateIndexError = 0x0000000000000068
    QkExitCode_ArithmeticError = 0x00000000000000c8
    QkExitCode_MismatchedQubits = 0x00000000000000c9
    QkExitCode_ExpectedUnitary = 0x00000000000000ca
    QkExitCode_TargetError = 0x000000000000012c
    QkExitCode_TargetInstAlreadyExists = 0x000000000000012d
    QkExitCode_TargetQargMismatch = 0x000000000000012e
    QkExitCode_TargetInvalidQargsKey = 0x000000000000012f
    QkExitCode_TargetInvalidInstKey = 0x0000000000000130
    QkExitCode_TranspilerError = 0x0000000000000190
end

@cenum QkDelayUnit::UInt8 begin
    QkDelayUnit_S = 0x0000000000000000
    QkDelayUnit_MS = 0x0000000000000001
    QkDelayUnit_US = 0x0000000000000002
    QkDelayUnit_NS = 0x0000000000000003
    QkDelayUnit_PS = 0x0000000000000004
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

mutable struct QkCircuit end

mutable struct QkObs end

mutable struct QkTarget end

mutable struct QkTargetEntry end

mutable struct QkTranspileLayout end

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
    params::Ptr{Cdouble}
    num_qubits::UInt32
    num_clbits::UInt32
    num_params::UInt32
end

struct QkComplex64
    re::Cdouble
    im::Cdouble
end

struct QkObsTerm
    coeff::QkComplex64
    len::Csize_t
    bit_terms::Ptr{QkBitTerm}
    indices::Ptr{UInt32}
    num_qubits::UInt32
end

struct QkSabreLayoutOptions
    max_iterations::Csize_t
    num_swap_trials::Csize_t
    num_random_trials::Csize_t
    seed::UInt64
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

function qk_complex64_from_native(arg1)
    @ccall libqiskit.qk_complex64_from_native(arg1::Cint)::QkComplex64
end

# Circuit functions
function qk_circuit_new(num_qubits, num_clbits)
    @ccall libqiskit.qk_circuit_new(num_qubits::UInt32, num_clbits::UInt32)::Ptr{QkCircuit}
end

function qk_circuit_free(qc)
    @ccall libqiskit.qk_circuit_free(qc::Ptr{QkCircuit})::Cvoid
end

function qk_circuit_copy(qc)
    @ccall libqiskit.qk_circuit_copy(qc::Ptr{QkCircuit})::Ptr{QkCircuit}
end

function qk_circuit_num_qubits(qc)
    @ccall libqiskit.qk_circuit_num_qubits(qc::Ptr{QkCircuit})::UInt32
end

function qk_circuit_num_clbits(qc)
    @ccall libqiskit.qk_circuit_num_clbits(qc::Ptr{QkCircuit})::UInt32
end

function qk_circuit_num_instructions(qc)
    @ccall libqiskit.qk_circuit_num_instructions(qc::Ptr{QkCircuit})::Csize_t
end

function qk_circuit_get_instruction(qc, index, inst)
    @ccall libqiskit.qk_circuit_get_instruction(qc::Ptr{QkCircuit}, index::Csize_t, inst::Ptr{QkCircuitInstruction})::Cvoid
end

function qk_circuit_instruction_clear(inst)
    @ccall libqiskit.qk_circuit_instruction_clear(inst::Ptr{QkCircuitInstruction})::Cvoid
end

function qk_circuit_gate(qc, gate, qubits, params)
    @ccall libqiskit.qk_circuit_gate(qc::Ptr{QkCircuit}, gate::QkGate, qubits::Ptr{UInt32}, params::Ptr{Cdouble})::QkExitCode
end

function qk_circuit_measure(qc, qubit, clbit)
    @ccall libqiskit.qk_circuit_measure(qc::Ptr{QkCircuit}, qubit::UInt32, clbit::UInt32)::QkExitCode
end

function qk_circuit_reset(qc, qubit)
    @ccall libqiskit.qk_circuit_reset(qc::Ptr{QkCircuit}, qubit::UInt32)::QkExitCode
end

function qk_circuit_barrier(qc, qubits, num_qubits)
    @ccall libqiskit.qk_circuit_barrier(qc::Ptr{QkCircuit}, qubits::Ptr{UInt32}, num_qubits::UInt32)::QkExitCode
end

function qk_circuit_unitary(qc, matrix, qubits, num_qubits, check_input)
    @ccall libqiskit.qk_circuit_unitary(qc::Ptr{QkCircuit}, matrix::Ptr{QkComplex64}, qubits::Ptr{UInt32}, num_qubits::UInt32, check_input::UInt8)::QkExitCode
end

function qk_circuit_delay(qc, qubit, duration, unit)
    @ccall libqiskit.qk_circuit_delay(qc::Ptr{QkCircuit}, qubit::UInt32, duration::Cdouble, unit::UInt8)::QkExitCode
end

function qk_circuit_count_ops(qc)
    @ccall libqiskit.qk_circuit_count_ops(qc::Ptr{QkCircuit})::QkOpCounts
end

function qk_opcounts_clear(opcounts)
    @ccall libqiskit.qk_opcounts_clear(opcounts::Ptr{QkOpCounts})::Cvoid
end

# Gate functions
function qk_gate_num_qubits(gate)
    @ccall libqiskit.qk_gate_num_qubits(gate::QkGate)::UInt32
end

function qk_gate_num_params(gate)
    @ccall libqiskit.qk_gate_num_params(gate::QkGate)::UInt32
end

# Observable / BitTerm functions
function qk_bitterm_label(bit_term)
    @ccall libqiskit.qk_bitterm_label(bit_term::UInt8)::UInt8
end

function qk_obs_zero(n)
    @ccall libqiskit.qk_obs_zero(n::UInt32)::Ptr{QkObs}
end

function qk_obs_free(obs)
    @ccall libqiskit.qk_obs_free(obs::Ptr{QkObs})::Cvoid
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

# Target functions
function qk_target_new(num_qubits)
    @ccall libqiskit.qk_target_new(num_qubits::UInt32)::Ptr{QkTarget}
end

function qk_target_free(target)
    @ccall libqiskit.qk_target_free(target::Ptr{QkTarget})::Cvoid
end

function qk_target_copy(target)
    @ccall libqiskit.qk_target_copy(target::Ptr{QkTarget})::Ptr{QkTarget}
end

function qk_target_num_qubits(target)
    @ccall libqiskit.qk_target_num_qubits(target::Ptr{QkTarget})::UInt32
end

function qk_target_num_instructions(target)
    @ccall libqiskit.qk_target_num_instructions(target::Ptr{QkTarget})::Csize_t
end

function qk_target_add_instruction(target, entry)
    @ccall libqiskit.qk_target_add_instruction(target::Ptr{QkTarget}, entry::Ptr{QkTargetEntry})::QkExitCode
end

# TargetEntry functions
function qk_target_entry_new(operation)
    @ccall libqiskit.qk_target_entry_new(operation::QkGate)::Ptr{QkTargetEntry}
end

function qk_target_entry_new_measure()
    @ccall libqiskit.qk_target_entry_new_measure()::Ptr{QkTargetEntry}
end

function qk_target_entry_new_reset()
    @ccall libqiskit.qk_target_entry_new_reset()::Ptr{QkTargetEntry}
end

function qk_target_entry_new_fixed(operation, params)
    @ccall libqiskit.qk_target_entry_new_fixed(operation::QkGate, params::Ptr{Cdouble})::Ptr{QkTargetEntry}
end

function qk_target_entry_free(entry)
    @ccall libqiskit.qk_target_entry_free(entry::Ptr{QkTargetEntry})::Cvoid
end

function qk_target_entry_num_properties(entry)
    @ccall libqiskit.qk_target_entry_num_properties(entry::Ptr{QkTargetEntry})::Csize_t
end

function qk_target_entry_add_property(entry, qubits, num_qubits, duration, error)
    @ccall libqiskit.qk_target_entry_add_property(entry::Ptr{QkTargetEntry}, qubits::Ptr{UInt32}, num_qubits::UInt32, duration::Cdouble, error::Cdouble)::QkExitCode
end

# Transpiler functions
function qk_transpile(qc, target, options, result, error_string)
    @ccall libqiskit.qk_transpile(qc::Ptr{QkCircuit}, target::Ptr{QkTarget}, options::Ptr{QkTranspileOptions}, result::Ptr{QkTranspileResult}, error_string::Ptr{Ptr{Cchar}})::QkExitCode
end

function qk_transpile_layout_free(layout)
    @ccall libqiskit.qk_transpile_layout_free(layout::Ptr{QkTranspileLayout})::Cvoid
end

const QISKIT_RELEASE_LEVEL_DEV = 0x0a

const QISKIT_RELEASE_LEVEL_BETA = 0x0b

const QISKIT_RELEASE_LEVEL_RC = 0x0c

const QISKIT_RELEASE_LEVEL_FINAL = 0x0f

const QISKIT_VERSION_MAJOR = 2

const QISKIT_VERSION_MINOR = 2

const QISKIT_VERSION_PATCH = 3

const QISKIT_RELEASE_LEVEL = QISKIT_RELEASE_LEVEL_FINAL

const QISKIT_RELEASE_SERIAL = 0

const QISKIT_VERSION = "2.2.3"

# exports
const PREFIXES = ["Qk", "qk_", "QISKIT_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
