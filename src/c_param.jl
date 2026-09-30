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

import .LibQiskit: QkParam

function qk_param_free(param::Ptr{QkParam})::Nothing
    LibQiskit.qk_param_free(param)
    nothing
end

function qk_param_new_symbol(name::String)::Ptr{QkParam}
    ptr = LibQiskit.qk_param_new_symbol(name)
    if ptr == C_NULL
        throw(ErrorException("Failed to create parameter symbol."))
    end
    ptr
end

function qk_param_from_double(value::Float64)::Ptr{QkParam}
    ptr = LibQiskit.qk_param_from_double(value)
    if ptr == C_NULL
        throw(ErrorException("Failed to create parameter from double."))
    end
    ptr
end

function qk_param_from_complex(value::ComplexF64)::Ptr{QkParam}
    ptr = LibQiskit.qk_param_from_complex(LibQiskit.QkComplex64(real(value), imag(value)))
    if ptr == C_NULL
        throw(ErrorException("Failed to create parameter from complex."))
    end
    ptr
end

function qk_param_zero()::Ptr{QkParam}
    ptr = LibQiskit.qk_param_zero()
    if ptr == C_NULL
        throw(ErrorException("Failed to create zero parameter."))
    end
    ptr
end

function qk_param_copy(param::Ptr{QkParam})::Ptr{QkParam}
    ptr = LibQiskit.qk_param_copy(param)
    if ptr == C_NULL
        throw(ErrorException("Failed to copy parameter."))
    end
    ptr
end

function qk_param_str(param::Ptr{QkParam})::String
    cstr = LibQiskit.qk_param_str(param)
    s = unsafe_string(cstr)
    LibQiskit.qk_str_free(cstr)
    s
end

function qk_param_equal(a::Ptr{QkParam}, b::Ptr{QkParam})::Bool
    LibQiskit.qk_param_equal(a, b)
end

function qk_param_as_real(param::Ptr{QkParam})::Float64
    LibQiskit.qk_param_as_real(param)
end

function qk_param_add(out::Ptr{QkParam}, a::Ptr{QkParam}, b::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_add(out, a, b))
    nothing
end

function qk_param_sub(out::Ptr{QkParam}, a::Ptr{QkParam}, b::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_sub(out, a, b))
    nothing
end

function qk_param_mul(out::Ptr{QkParam}, a::Ptr{QkParam}, b::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_mul(out, a, b))
    nothing
end

function qk_param_div(out::Ptr{QkParam}, num::Ptr{QkParam}, den::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_div(out, num, den))
    nothing
end

function qk_param_pow(out::Ptr{QkParam}, base::Ptr{QkParam}, pow::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_pow(out, base, pow))
    nothing
end

function qk_param_sin(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_sin(out, src))
    nothing
end

function qk_param_cos(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_cos(out, src))
    nothing
end

function qk_param_tan(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_tan(out, src))
    nothing
end

function qk_param_asin(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_asin(out, src))
    nothing
end

function qk_param_acos(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_acos(out, src))
    nothing
end

function qk_param_atan(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_atan(out, src))
    nothing
end

function qk_param_log(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_log(out, src))
    nothing
end

function qk_param_exp(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_exp(out, src))
    nothing
end

function qk_param_abs(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_abs(out, src))
    nothing
end

function qk_param_sign(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_sign(out, src))
    nothing
end

function qk_param_neg(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_neg(out, src))
    nothing
end

function qk_param_conjugate(out::Ptr{QkParam}, src::Ptr{QkParam})::Nothing
    check_exit_code(LibQiskit.qk_param_conjugate(out, src))
    nothing
end

export QkParam
export qk_param_free, qk_param_new_symbol, qk_param_from_double, qk_param_from_complex
export qk_param_zero, qk_param_copy, qk_param_str, qk_param_equal, qk_param_as_real
export qk_param_add, qk_param_sub, qk_param_mul, qk_param_div, qk_param_pow
export qk_param_sin, qk_param_cos, qk_param_tan, qk_param_asin, qk_param_acos, qk_param_atan
export qk_param_log, qk_param_exp, qk_param_abs, qk_param_sign, qk_param_neg, qk_param_conjugate
