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
    ccall((:qk_complex64_from_native, libqiskit), QkComplex64, (Cint,), arg1)
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
