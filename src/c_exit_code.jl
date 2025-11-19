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

import .LibQiskit: QkExitCode

function check_exit_code(code::QkExitCode, error_string::Ptr{Cchar} = Ptr{Cchar}(C_NULL))::Nothing
    if error_string != C_NULL
        #println(unsafe_string(pointer(error_string)))
    end
    if code == QkExitCode_Success
        return
    elseif code == QkExitCode_CInputError
        throw(ErrorException("Error related to C data input."))
    elseif code == QkExitCode_NullPointerError
        throw(ErrorException("Unexpected null pointer."))
    elseif code == QkExitCode_AlignmentError
        throw(ErrorException("Pointer is not aligned to expected data."))
    elseif code == QkExitCode_IndexError
        throw(ErrorException("Index out of bounds."))
    elseif code == QkExitCode_DuplicateIndexError
        throw(ErrorException("Duplicate index."))
    elseif code == QkExitCode_ArithmeticError
        throw(ErrorException("Error related to arithmetic operations or similar."))
    elseif code == QkExitCode_MismatchedQubits
        throw(ErrorException("Mismatching number of qubits."))
    elseif code == QkExitCode_ExpectedUnitary
        throw(ErrorException("Matrix is not unitary."))
    elseif code == QkExitCode_TargetError
        throw(ErrorException("Target related error"))
    elseif code == QkExitCode_TargetInstAlreadyExists
        throw(ErrorException("Instruction already exists in the Target"))
    elseif code == QkExitCode_TargetQargMismatch
        throw(ErrorException("Properties with incorrect qargs was added"))
    elseif code == QkExitCode_TargetInvalidQargsKey
        throw(ErrorException("Trying to query into the target with non-existent qargs."))
    elseif code == QkExitCode_TargetInvalidInstKey
        throw(ErrorException("Querying an operation that doesn't exist in the Target."))
    elseif code == QkExitCode_TranspilerError
        throw(ErrorException("Transpilation failed."))
    else
        throw(ErrorException("Unrecognized error code from Qiskit: $code"))
    end
end

export QkExitCode

# Export enum instances
for e in (QkExitCode,)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
