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

import .LibQiskit: QkBitTerm, QkObs

function qk_bitterm_label(bit_term::QkBitTerm)::Char
    @ccall libqiskit.qk_bitterm_label(bit_term::UInt8)::UInt8
end

function qk_obs_free(obs::Ptr{QkObs})
    @ccall libqiskit.qk_obs_free(obs::Ptr{QkObs})::Cvoid
end

function qk_obs_zero(n::Integer)
    n >= 0 || throw()
    @ccall libqiskit.qk_obs_zero(n::UInt32)::Ptr{QkObs}
end

function qk_obs_num_terms(obs::Ptr{QkObs})::Int
    signed(@ccall libqiskit.qk_obs_num_terms(obs::Ptr{QkObs})::Csize_t)
end

function qk_obs_num_qubits(obs::Ptr{QkObs})::Int
    signed(@ccall libqiskit.qk_obs_num_qubits(obs::Ptr{QkObs})::UInt32)
end

function qk_obs_len(obs::Ptr{QkObs})::Int
    signed(@ccall libqiskit.qk_obs_len(obs::Ptr{QkObs})::Csize_t)
end

export QkBitTerm, qk_bitterm_label, QkObs, qk_obs_free, qk_obs_zero, qk_obs_num_terms, qk_obs_num_qubits, qk_obs_len

# Export enum instances
for e in (QkBitTerm,)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
