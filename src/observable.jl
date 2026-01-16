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

import .C: qk_obs_free, qk_obs_num_terms, qk_obs_num_qubits, qk_obs_zero, qk_obs_len, QkObs

"""
    SparseObservable

Qiskit observable.  This is a wrapper of `QkObs`, which is similar to
`SparseObservable` in Python.
"""
mutable struct SparseObservable
    ptr::Ptr{QkObs}
    @doc"""
        SparseObservable(n::Integer)

    Construct an empty `SparseObservable` on `n` qubits.
    """
    function SparseObservable(n::Integer)
        obs = new(qk_obs_zero(n))
        finalizer(qk_obs_free, obs)
        obs
    end
end

function check_not_null(qc::Ptr{QkObs})::Nothing
    if qc == C_NULL
        throw(ArgumentError("Ptr{QkObs} is NULL."))
    end
    nothing
end

function qk_obs_free(obs::SparseObservable)::Nothing
    if obs.ptr != C_NULL
        qk_obs_free(obs.ptr)
        obs.ptr = C_NULL
    end
    nothing
end

function qk_obs_num_terms(obs::SparseObservable)::Int
    check_not_null(obs.ptr)
    qk_obs_num_terms(obs.ptr)
end

function qk_obs_num_qubits(obs::SparseObservable)::Int
    check_not_null(obs.ptr)
    qk_obs_num_qubits(obs.ptr)
end

function qk_obs_len(obs::SparseObservable)::Int
    check_not_null(obs.ptr)
    qk_obs_len(obs.ptr)
end

export SparseObservable
