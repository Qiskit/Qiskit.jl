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

import .C: qk_transpile, QkTranspileLayout, QkTranspileResult

mutable struct TranspileLayout
    ptr::Ptr{QkTranspileLayout}
end

function qk_transpile(qc::QuantumCircuit, target::Target)::Tuple{QuantumCircuit, TranspileLayout}
    result_ref = qk_transpile(qc.ptr, target.ptr)
    return QuantumCircuit(result_ref[].circuit), TranspileLayout(result_ref[].layout)
end
