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

import .LibQiskit: QkTranspileOptions, QkTranspileLayout, QkTranspileResult

QkTranspileResult() = QkTranspileResult(C_NULL, C_NULL)

function qk_transpile(qc::Ref{QkCircuit}, target::Ref{QkTarget})::Ref{QkTranspileResult}
    result = Ref(QkTranspileResult())
    error_string = Ptr{Cchar}(C_NULL)
    exit_code = @ccall libqiskit.qk_transpile(qc::Ref{QkCircuit}, target::Ref{QkTarget}, C_NULL::Ptr{QkTranspileOptions}, result::Ref{QkTranspileResult}, error_string::Ref{Ptr{Cchar}})::QkExitCode
    check_exit_code(exit_code, error_string)
    return result
end

export qk_transpile
