# This code is part of Qiskit.
#
# (C) Copyright IBM 2026.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

import .LibQiskit:
    QkPauliProductRotation, QkPauliProductMeasurement, QkOperationKind, QkExitCode


function check_pauli_product_index(qc::Ref{QkCircuit}, index::Integer, offset::Int)::Csize_t
    check_not_null(qc)
    if !checkindex(Bool, range(offset, length=qk_circuit_num_instructions(qc)), index)
        throw(ArgumentError("Invalid instruction index"))
    end
    return Csize_t(index - offset)
end

function qk_circuit_instruction_kind(
    qc::Ref{QkCircuit},
    index::Integer;
    offset::Int=1,
)::QkOperationKind
    index0 = check_pauli_product_index(qc, index, offset)
    LibQiskit.qk_circuit_instruction_kind(qc, index0)
end

export qk_circuit_instruction_kind
