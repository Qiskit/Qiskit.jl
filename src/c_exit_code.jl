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

# Append the C-provided description, when there is one, to our own summary of the
# exit code.  The C string belongs to the caller; we only read it.
function _throw_exit_code(error_string::Ptr{Cchar}, summary::AbstractString)
    if error_string != C_NULL
        detail = unsafe_string(error_string)
        if !isempty(detail)
            throw(ErrorException("$(rstrip(summary, '.')): $detail"))
        end
    end
    throw(ErrorException(summary))
end

# Throw an informative exception unless `code` is `QkExitCode_Success`.
#
# `error_string`, when non-NULL, is a C string that the failing function wrote a
# description of the problem into; it is appended to the message.  The pointer is
# only read here, so the caller remains responsible for freeing it (with
# `qk_str_free`) after this function returns or throws.
function check_exit_code(code::QkExitCode, error_string::Ptr{Cchar} = Ptr{Cchar}(C_NULL))::Nothing
    if code == QkExitCode_Success
        return
    elseif code == QkExitCode_CInputError
        _throw_exit_code(error_string, "Error related to C data input.")
    elseif code == QkExitCode_NullPointerError
        _throw_exit_code(error_string, "Unexpected null pointer.")
    elseif code == QkExitCode_AlignmentError
        _throw_exit_code(error_string, "Pointer is not aligned to expected data.")
    elseif code == QkExitCode_IndexError
        _throw_exit_code(error_string, "Index out of bounds.")
    elseif code == QkExitCode_DuplicateIndexError
        _throw_exit_code(error_string, "Duplicate index.")
    elseif code == QkExitCode_ArithmeticError
        _throw_exit_code(error_string, "Error related to arithmetic operations or similar.")
    elseif code == QkExitCode_MismatchedQubits
        _throw_exit_code(error_string, "Mismatching number of qubits.")
    elseif code == QkExitCode_ExpectedUnitary
        _throw_exit_code(error_string, "Matrix is not unitary.")
    elseif code == QkExitCode_TargetError
        _throw_exit_code(error_string, "Target related error")
    elseif code == QkExitCode_TargetInstAlreadyExists
        _throw_exit_code(error_string, "Instruction already exists in the Target")
    elseif code == QkExitCode_TargetQargMismatch
        _throw_exit_code(error_string, "Properties with incorrect qargs was added")
    elseif code == QkExitCode_TargetInvalidQargsKey
        _throw_exit_code(error_string, "Trying to query into the target with non-existent qargs.")
    elseif code == QkExitCode_TargetInvalidInstKey
        _throw_exit_code(error_string, "Querying an operation that doesn't exist in the Target.")
    elseif code == QkExitCode_TranspilerError
        _throw_exit_code(error_string, "Transpilation failed.")
    elseif code == QkExitCode_InvalidOperationKind
        _throw_exit_code(error_string, "Invalid operation kind.")
    elseif code == QkExitCode_DagError
        _throw_exit_code(error_string, "DAG operation error.")
    elseif code == QkExitCode_DagComposeMismatch
        _throw_exit_code(error_string, "DAGs have mismatching qubit/clbit amounts during compose.")
    elseif code == QkExitCode_DagComposeMissingBit
        _throw_exit_code(error_string, "One or more bit indices were not found during compose.")
    elseif code == QkExitCode_ParameterError
        _throw_exit_code(error_string, "Error concerning parameter handling.")
    elseif code == QkExitCode_ParameterNameConflict
        _throw_exit_code(error_string, "Parameter name conflict.")
    else
        _throw_exit_code(error_string, "Unrecognized error code from Qiskit: $code")
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
