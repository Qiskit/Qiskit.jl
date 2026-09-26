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

import .C: QkParam, LibQiskit
using .C

"""
    Parameter

Represents a circuit parameter which may hold real, complex, or symbolic values.

# Constructors

- `Parameter(name::String)` — create a symbolic parameter with the given name.
- `Parameter(value::Real)` — create a parameter holding a real number.
- `Parameter(value::Complex)` — create a parameter holding a complex number.

# Examples

```julia
theta = Parameter(\"θ\")
phi = Parameter(\"φ\")
expr = 2 * theta + sin(phi)
qc.rz(theta, 1)
```
"""
mutable struct Parameter
    ptr::Ptr{QkParam}

    function Parameter(name::String)
        ptr = qk_param_new_symbol(name)
        p = new(ptr)
        finalizer(qk_param_free, p)
        p
    end

    function Parameter(value::Real)
        ptr = qk_param_from_double(Float64(value))
        p = new(ptr)
        finalizer(qk_param_free, p)
        p
    end

    function Parameter(value::Complex)
        ptr = qk_param_from_complex(ComplexF64(value))
        p = new(ptr)
        finalizer(qk_param_free, p)
        p
    end

    function Parameter(ptr::Ptr{QkParam})
        p = new(ptr)
        finalizer(qk_param_free, p)
        p
    end
end

function qk_param_free(p::Parameter)::Nothing
    if p.ptr != C_NULL
        LibQiskit.qk_param_free(p.ptr)
        p.ptr = C_NULL
    end
    nothing
end

function Base.copy(p::Parameter)::Parameter
    Parameter(qk_param_copy(p.ptr))
end

function Base.string(p::Parameter)::String
    qk_param_str(p.ptr)
end

function Base.show(io::IO, p::Parameter)
    if p.ptr == C_NULL
        print(io, "Parameter(NULL)")
    else
        print(io, "Parameter($(string(p)))")
    end
end

function Base.:(==)(a::Parameter, b::Parameter)::Bool
    qk_param_equal(a.ptr, b.ptr)
end

# Binop helpers
_param_binop(a::Parameter, b::Parameter, op) = (out = qk_param_zero(); op(out, a.ptr, b.ptr); Parameter(out))
_param_binop(a::Parameter, b::Real, op) = _param_binop(a, Parameter(b), op)
_param_binop(a::Real, b::Parameter, op) = _param_binop(Parameter(a), b, op)

function Base.:+(a::Parameter, b::Parameter)
    _param_binop(a, b, qk_param_add)
end
Base.:+(a::Parameter, b::Real) = _param_binop(a, b, qk_param_add)
Base.:+(a::Real, b::Parameter) = _param_binop(a, b, qk_param_add)

function Base.:-(a::Parameter, b::Parameter)
    _param_binop(a, b, qk_param_sub)
end
Base.:-(a::Parameter, b::Real) = _param_binop(a, b, qk_param_sub)
Base.:-(a::Real, b::Parameter) = _param_binop(a, b, qk_param_sub)

function Base.:*(a::Parameter, b::Parameter)
    _param_binop(a, b, qk_param_mul)
end
Base.:*(a::Parameter, b::Real) = _param_binop(a, b, qk_param_mul)
Base.:*(a::Real, b::Parameter) = _param_binop(a, b, qk_param_mul)

function Base.:/(a::Parameter, b::Parameter)
    _param_binop(a, b, qk_param_div)
end
Base.:/(a::Parameter, b::Real) = _param_binop(a, b, qk_param_div)
Base.:/(a::Real, b::Parameter) = _param_binop(a, b, qk_param_div)

function Base.:^(a::Parameter, b::Parameter)
    _param_binop(a, b, qk_param_pow)
end
Base.:^(a::Parameter, b::Real) = _param_binop(a, b, qk_param_pow)
Base.:^(a::Real, b::Parameter) = _param_binop(a, b, qk_param_pow)

# Unary helpers
_param_unop(a::Parameter, op) = (out = qk_param_zero(); op(out, a.ptr); Parameter(out))

function Base.:-(a::Parameter)
    _param_unop(a, qk_param_neg)
end

function Base.conj(a::Parameter)
    _param_unop(a, qk_param_conjugate)
end

function Base.abs(a::Parameter)
    _param_unop(a, qk_param_abs)
end

function Base.sign(a::Parameter)
    _param_unop(a, qk_param_sign)
end

# Trig functions
Base.sin(a::Parameter) = _param_unop(a, qk_param_sin)
Base.cos(a::Parameter) = _param_unop(a, qk_param_cos)
Base.tan(a::Parameter) = _param_unop(a, qk_param_tan)
Base.asin(a::Parameter) = _param_unop(a, qk_param_asin)
Base.acos(a::Parameter) = _param_unop(a, qk_param_acos)
Base.atan(a::Parameter) = _param_unop(a, qk_param_atan)

# Transcendental functions
Base.log(a::Parameter) = _param_unop(a, qk_param_log)
Base.exp(a::Parameter) = _param_unop(a, qk_param_exp)

"""
    as_real(p::Parameter) -> Float64

Attempt to cast the parameter as a `Float64`. Returns `NaN` if the parameter
contains unbound symbolic variables.
"""
function as_real(p::Parameter)::Float64
    qk_param_as_real(p.ptr)
end

export Parameter, as_real
