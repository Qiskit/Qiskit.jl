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

import .C: qk_transpile, qk_transpile_layout_free, qk_transpiler_default_options, QkTranspileLayout, QkTranspileOptions, QkTranspileResult

"""
    TranspileOptions

Options for the Qiskit transpiler.

Available properties:

- `optimization_level`: the optimization level, an integer between `0` and `3`
- `seed`: the seed for the transpiler. If set to a negative number this means
  no seed will be set and the RNGs used in the transpiler will be seeded from
  system entropy.
- `approximation_degree`: a heuristic dial where `1.0` means no approximation
  (up to numerical tolerance) and `0.0` means the maximum approximation. A
  `NaN` value indicates that approximation is allowed up to the reported error
  rate for an operation in the target.
"""
mutable struct TranspileOptions
    options::QkTranspileOptions
    TranspileOptions() = new(qk_transpiler_default_options())
end

# Deliberately omits the internal `options` field (unlike other wrappers, which
# union in `fieldnames`): it is readable but not settable, so it isn't advertised.
function Base.propertynames(::TranspileOptions; private::Bool = false)
    (:optimization_level, :seed, :approximation_degree)
end

function Base.getproperty(obj::TranspileOptions, sym::Symbol)
    if sym === :options
        getfield(obj, :options)
    elseif sym in (:optimization_level, :seed, :approximation_degree)
        getfield(getfield(obj, :options), sym)
    else
        getfield(obj, sym)
    end
end

function Base.setproperty!(obj::TranspileOptions, sym::Symbol, val)
    # There is intentionally no branch for `:options`: every mutation must go
    # through validation, because out-of-range values make the C API panic,
    # which aborts the process rather than raising a catchable exception.
    if sym === :optimization_level
        val isa Integer && !(val isa Bool) && 0 <= val <= 3 ||
            throw(ArgumentError("optimization_level must be an integer between 0 and 3."))
        setfield!(
            obj,
            :options,
            QkTranspileOptions(UInt8(val), obj.seed, obj.approximation_degree),
        )
    elseif sym === :seed
        val isa Integer && !(val isa Bool) ||
            throw(ArgumentError("seed must be an integer."))
        setfield!(
            obj,
            :options,
            QkTranspileOptions(
                obj.optimization_level,
                Int64(val),
                obj.approximation_degree,
            ),
        )
    elseif sym === :approximation_degree
        val isa Real && (isnan(val) || 0.0 <= val <= 1.0) || throw(
            ArgumentError(
                "approximation_degree must be a NaN or a value between 0.0 and 1.0.",
            ),
        )
        setfield!(
            obj,
            :options,
            QkTranspileOptions(obj.optimization_level, obj.seed, Float64(val)),
        )
    else
        throw(ArgumentError("Unknown TranspileOptions property: $sym"))
    end
    nothing
end

function Base.show(io::IO, obj::TranspileOptions)
    print(io, "TranspileOptions(")
    show(io, Int(obj.optimization_level))
    print(io, ", ")
    show(io, obj.seed)
    print(io, ", ")
    show(io, obj.approximation_degree)
    print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", obj::TranspileOptions)
    print(io, "TranspileOptions:\n  optimization_level: ")
    show(io, Int(obj.optimization_level))
    print(io, "\n  seed: ")
    show(io, obj.seed)
    print(io, "\n  approximation_degree: ")
    show(io, obj.approximation_degree)
end

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

function Base.show(io::IO, obj::TranspileLayout)
    if obj.ptr == C_NULL
        print(io, "TranspileLayout(NULL)")
    else
        print(io, "TranspileLayout(...)")
    end
end

const TranspileResult = @NamedTuple begin
    circuit::QuantumCircuit
    layout::TranspileLayout
end

TranspileResult(circuit::QuantumCircuit, layout::TranspileLayout) =
    # Call the NamedTuple constructor
    TranspileResult((circuit, layout))

function Base.show(io::IO, result::TranspileResult)
    print(io, "TranspileResult(circuit=")
    show(io, result.circuit)
    print(io, ", layout=")
    show(io, result.layout)
    print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", result::TranspileResult)
    print(io, "TranspileResult:\n  circuit: ")
    show(io, result.circuit)
    print(io, "\n  layout:  ")
    show(io, result.layout)
end

function qk_transpile(
    qc::QuantumCircuit,
    target::Target,
    options::TranspileOptions,
)::TranspileResult
    result_ref = qk_transpile(qc.ptr, target.ptr, Ref(options.options))
    circuit = QuantumCircuit(result_ref[].circuit)
    layout = TranspileLayout(result_ref[].layout)
    return TranspileResult(circuit, layout)
end

function qk_transpile(qc::QuantumCircuit, target::Target)::TranspileResult
    result_ref = qk_transpile(qc.ptr, target.ptr)
    circuit = QuantumCircuit(result_ref[].circuit)
    layout = TranspileLayout(result_ref[].layout)
    return TranspileResult(circuit, layout)
end

"""
    transpile(circuit, target; options=nothing)

Transpile a single circuit.

The Qiskit transpiler is a quantum circuit compiler that rewrites a given input
circuit to match the constraints of a QPU and optimizes the circuit for
execution. Pass a [`TranspileOptions`](@ref) object as the `options` keyword
argument to control the transpiler.

This function wraps `qk_transpile`, which is multithreaded internally and will
launch a thread pool with threads equal to the number of CPUs reported by the
operating system by default. This will include logical cores on CPUs with
simultaneous multithreading. You can tune the number of threads with the
`RAYON_NUM_THREADS` environment variable. For example, setting
`RAYON_NUM_THREADS=4` would limit the thread pool to 4 threads.
"""
transpile(
    qc::QuantumCircuit,
    target::Target;
    options::Union{TranspileOptions,Nothing} = nothing,
)::TranspileResult =
    options === nothing ? qk_transpile(qc, target) : qk_transpile(qc, target, options)

export TranspileLayout, TranspileOptions, TranspileResult, transpile
