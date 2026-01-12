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

import .C: qk_transpile, qk_transpile_layout_free, QkTranspileLayout, QkTranspileResult

mutable struct TranspileLayout
    ptr::Ptr{QkTranspileLayout}
    function TranspileLayout(ptr::Ptr{QkTranspileLayout})
        check_not_null(ptr)
        layout = new(ptr)
        # Take ownership; it's our job to free it eventually
        finalizer(qk_transpile_layout_free, layout)
        layout
    end
end

function qk_transpile_layout_free(obj::TranspileLayout)::Nothing
    if obj.ptr != C_NULL
        qk_transpile_layout_free(obj.ptr)
        obj.ptr = C_NULL
    end
    nothing
end

const TranspileResult = @NamedTuple begin
    circuit::QuantumCircuit
    layout::TranspileLayout
end

TranspileResult(circuit::QuantumCircuit, layout::TranspileLayout) =
    # Call the NamedTuple constructor
    TranspileResult((circuit, layout))

function qk_transpile(qc::QuantumCircuit, target::Target)::TranspileResult
    result_ref = qk_transpile(qc.ptr, target.ptr)
    circuit = QuantumCircuit(result_ref[].circuit)
    layout = TranspileLayout(result_ref[].layout)
    return TranspileResult(circuit, layout)
end

transpile(qc::QuantumCircuit, target::Target)::TranspileResult =
    qk_transpile(qc, target)

export TranspileLayout, TranspileResult, transpile
