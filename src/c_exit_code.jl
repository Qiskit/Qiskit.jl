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

@enum QkExitCode::UInt32 begin
    QkExitCode_Success = 0
    QkExitCode_CInputError = 100
    QkExitCode_NullPointerError = 101
    QkExitCode_AlignmentError = 102
    QkExitCode_IndexError = 103
    QkExitCode_ArithmeticError = 200
    QkExitCode_MismatchedQubits = 201
    QkExitCode_ExpectedUnitary = 202
end

function check_exit_code(code::QkExitCode)::Nothing
    if code == QkExitCode_Success
        return
    elseif code == 100
        throw(ErrorException("Error related to C data input."))
    elseif code == 101
        throw(ErrorException("Unexpected null pointer."))
    elseif code == 102
        throw(ErrorException("Pointer is not aligned to expected data."))
    elseif code == 103
        throw(ErrorException("Index out of bounds."))
    elseif code == 200
        throw(ErrorException("Error related to arithmetic operations or similar."))
    elseif code == 201
        throw(ErrorException("Mismatching number of qubits."))
    elseif code == 202
        throw(ErrorException("Matrix is not unitary."))
    else
        throw(ErrorException("Unrecognized error code from Qiskit: {code}"))
    end
end
