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

"""
    TranspileLayout

This type stores the permutation introduced by the transpiler. In general
Qiskit’s transpiler is unitary-preserving up to the initial layout and output
permutations. The initial layout is the mapping from virtual circuit qubits to
physical qubits on the target and the output permutation is caused by swap gate
insertion or permutation elision prior to the initial layout being set in the
transpiler pipeline. This type tracks these details and provide an interface to
reason about these permutations.
"""
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

"""
    transpile(circuit, target)

Transpile a single circuit.

The Qiskit transpiler is a quantum circuit compiler that rewrites a given input
circuit to match the constraints of a QPU and optimizes the circuit for
execution.

This function wraps `qk_transpile`, which is multithreaded internally and will
launch a thread pool with threads equal to the number of CPUs reported by the
operating system by default. This will include logical cores on CPUs with
simultaneous multithreading. You can tune the number of threads with the
`RAYON_NUM_THREADS` environment variable. For example, setting
`RAYON_NUM_THREADS=4` would limit the thread pool to 4 threads.
"""
transpile(qc::QuantumCircuit, target::Target)::TranspileResult =
    qk_transpile(qc, target)

export TranspileLayout, TranspileResult, transpile
