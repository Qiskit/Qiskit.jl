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

function qk_transpile_layout_free(qc::Ptr{QkTranspileLayout})
    LibQiskit.qk_transpile_layout_free(qc)
end

function check_not_null(ptr::Ptr{QkTranspileLayout})::Nothing
    if ptr == C_NULL
        throw(ArgumentError("Ptr{QkTranspileLayout} is NULL."))
    end
    nothing
end

QkTranspileResult() = QkTranspileResult(C_NULL, C_NULL)

function qk_transpile(qc::Ref{QkCircuit}, target::Ref{QkTarget})::Ref{QkTranspileResult}
    result = Ref(QkTranspileResult())
    error_string = Ref{Ptr{Cchar}}(C_NULL)
    exit_code = LibQiskit.qk_transpile(qc, target, C_NULL, result, error_string)
    check_exit_code(exit_code, error_string[])
    return result
end

export qk_transpile, qk_transpile_layout_free
