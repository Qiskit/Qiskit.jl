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

import .C: qk_circuit_instruction_kind, check_pauli_product_index

import .LibQiskit:
    QkOperationKind, QkPauliProductRotation, QkPauliProductMeasurement, QkCircuit

"""
    PauliProduct

A Pauli operator acting on a subset of a circuit's qubits.

The `z` and `x` fields use the symplectic encoding of the Qiskit C API: qubit
`i` carries `I` when neither bit is set, `X` when only `x[i]` is set, `Z` when
only `z[i]` is set, and `Y` when both are set.

The `z` and `x` entries are positional: entry `i` describes the Pauli on qubit
`qubits[i]`, so `qubits` is needed to interpret them.  A `PauliProduct` lists
only the qubits its instruction acts on, which is generally fewer than the
number of qubits in the circuit it came from.
"""
struct PauliProduct
    z::Vector{Bool}
    x::Vector{Bool}
    qubits::Vector{Int}
    function PauliProduct(
        z::AbstractVector{Bool},
        x::AbstractVector{Bool},
        qubits::AbstractVector{<:Integer},
    )
        if !(length(z) == length(x) == length(qubits))
            throw(ArgumentError("`z`, `x`, and `qubits` must have equal lengths."))
        end
        new(collect(Bool, z), collect(Bool, x), collect(Int, qubits))
    end
end

Base.length(p::PauliProduct) = length(p.qubits)

# These types are plain values read back out of a circuit, so compare them
# field-wise: the default `===` fallback would make two reads of the same
# instruction unequal because each allocates its own arrays.
Base.:(==)(a::PauliProduct, b::PauliProduct) =
    a.z == b.z && a.x == b.x && a.qubits == b.qubits

Base.hash(p::PauliProduct, h::UInt) =
    hash(p.qubits, hash(p.x, hash(p.z, hash(:PauliProduct, h))))

function Base.getproperty(p::PauliProduct, sym::Symbol)
    if sym === :num_qubits
        return length(getfield(p, :qubits))
    end
    return getfield(p, sym)
end

Base.propertynames(::PauliProduct) = (:z, :x, :qubits, :num_qubits)

"""
    pauli_label(p::PauliProduct)

Return the Pauli label of `p` as a `String`, one character per entry of
`p.qubits`, in the same order.  Use `p.qubits` to map each character back to
the qubit it acts on.
"""
function pauli_label(p::PauliProduct)::String
    map(zip(p.z, p.x)) do (zi, xi)
        zi && xi ? 'Y' : zi ? 'Z' : xi ? 'X' : 'I'
    end |> String
end

function Base.show(io::IO, p::PauliProduct)
    print(io, "PauliProduct(\"", pauli_label(p), "\", ", p.qubits, ")")
end

# `len` in the C structs is the size of the operator's support, not the width of
# the circuit, so the `z`/`x` arrays are read with that length and paired with
# the instruction's own qubit list.
function _pauli_product(
    z::Ptr{Bool},
    x::Ptr{Bool},
    len::Integer,
    qubits::AbstractVector{<:Integer},
)::PauliProduct
    n = Int(len)
    if n != length(qubits)
        throw(
            ErrorException(
                "Pauli product length ($n) does not match the number of qubits " *
                "the instruction acts on ($(length(qubits))).",
            ),
        )
    end
    # `unsafe_wrap` aliases memory owned by the caller's instruction struct, so
    # copy eagerly: `PauliProduct`'s constructor does that via `collect`.
    PauliProduct(unsafe_wrap(Array, z, n), unsafe_wrap(Array, x, n), qubits)
end

"""
    PauliProductRotation

A rotation about a Pauli product, as produced by the Litinski transformation
and by `convert_to_pauli_rotations!`.

The rotation applied is `exp(-i * angle / 2 * P)`, where `P` is `pauli`.
"""
struct PauliProductRotation
    pauli::PauliProduct
    angle::Float64
end

Base.:(==)(a::PauliProductRotation, b::PauliProductRotation) =
    a.pauli == b.pauli && a.angle == b.angle

Base.hash(inst::PauliProductRotation, h::UInt) =
    hash(inst.angle, hash(inst.pauli, hash(:PauliProductRotation, h)))

function Base.getproperty(inst::PauliProductRotation, sym::Symbol)
    if sym === :qubits
        return getfield(inst, :pauli).qubits
    elseif sym === :num_qubits
        return length(getfield(inst, :pauli).qubits)
    end
    return getfield(inst, sym)
end

Base.propertynames(::PauliProductRotation) = (:pauli, :angle, :qubits, :num_qubits)

function Base.show(io::IO, inst::PauliProductRotation)
    print(
        io,
        "PauliProductRotation(\"",
        pauli_label(inst.pauli),
        "\", ",
        inst.pauli.qubits,
        ", ",
        inst.angle,
        ")",
    )
end

"""
    PauliProductMeasurement

A measurement of a Pauli product, as produced by the Litinski transformation
and by `convert_to_pauli_rotations!`.

`flip_outcome` indicates that the recorded outcome is the complement of the
measured eigenvalue.
"""
struct PauliProductMeasurement
    pauli::PauliProduct
    clbit::Int
    flip_outcome::Bool
end

Base.:(==)(a::PauliProductMeasurement, b::PauliProductMeasurement) =
    a.pauli == b.pauli && a.clbit == b.clbit && a.flip_outcome == b.flip_outcome

Base.hash(inst::PauliProductMeasurement, h::UInt) = hash(
    inst.flip_outcome,
    hash(inst.clbit, hash(inst.pauli, hash(:PauliProductMeasurement, h))),
)

function Base.getproperty(inst::PauliProductMeasurement, sym::Symbol)
    if sym === :qubits
        return getfield(inst, :pauli).qubits
    elseif sym === :num_qubits
        return length(getfield(inst, :pauli).qubits)
    end
    return getfield(inst, sym)
end

Base.propertynames(::PauliProductMeasurement) =
    (:pauli, :clbit, :flip_outcome, :qubits, :num_qubits)

function Base.show(io::IO, inst::PauliProductMeasurement)
    print(
        io,
        "PauliProductMeasurement(\"",
        pauli_label(inst.pauli),
        "\", ",
        inst.pauli.qubits,
        ", clbit=",
        inst.clbit,
        inst.flip_outcome ? ", flip_outcome=true)" : ")",
    )
end

qk_circuit_instruction_kind(qc::QuantumCircuit, index::Integer)::QkOperationKind =
    qk_circuit_instruction_kind(qc.ptr, index; offset=qc.offset)

function qk_circuit_inst_pauli_product_rotation(
    qc::Ref{QkCircuit},
    index::Integer;
    offset::Int=1,
)::PauliProductRotation
    index0 = check_pauli_product_index(qc, index, offset)
    ref = Ref(QkPauliProductRotation(C_NULL, C_NULL, 0, C_NULL))
    exit_code = LibQiskit.qk_circuit_inst_pauli_product_rotation(qc, index0, ref)
    if exit_code != LibQiskit.QkExitCode_Success
        throw(ArgumentError("Instruction at index $index is not a Pauli product rotation."))
    end
    inst = qk_circuit_get_instruction(qc, index; offset=offset)
    # Everything below reads memory owned by `ref`, which
    # `qk_pauli_product_rotation_clear` frees at the end of this function, so
    # each read must materialize its own copy before then.
    try
        c = ref[]
        pauli = _pauli_product(c.z, c.x, c.len, inst.qubits)
        return PauliProductRotation(pauli, LibQiskit.qk_param_as_real(c.angle))
    finally
        LibQiskit.qk_pauli_product_rotation_clear(ref)
    end
end

function qk_circuit_inst_pauli_product_measurement(
    qc::Ref{QkCircuit},
    index::Integer;
    offset::Int=1,
)::PauliProductMeasurement
    index0 = check_pauli_product_index(qc, index, offset)
    ref = Ref(QkPauliProductMeasurement(C_NULL, C_NULL, 0, false))
    exit_code = LibQiskit.qk_circuit_inst_pauli_product_measurement(qc, index0, ref)
    if exit_code != LibQiskit.QkExitCode_Success
        throw(
            ArgumentError(
                "Instruction at index $index is not a Pauli product measurement.",
            ),
        )
    end
    inst = qk_circuit_get_instruction(qc, index; offset=offset)
    if length(inst.clbits) != 1
        LibQiskit.qk_pauli_product_measurement_clear(ref)
        throw(
            ErrorException(
                "Expected a Pauli product measurement to use exactly one clbit, " *
                "but it uses $(length(inst.clbits)).",
            ),
        )
    end
    # As above, `qk_pauli_product_measurement_clear` frees the memory read here.
    try
        c = ref[]
        pauli = _pauli_product(c.z, c.x, c.len, inst.qubits)
        return PauliProductMeasurement(pauli, only(inst.clbits), c.flip_outcome)
    finally
        LibQiskit.qk_pauli_product_measurement_clear(ref)
    end
end

qk_circuit_inst_pauli_product_rotation(
    qc::QuantumCircuit,
    index::Integer,
)::PauliProductRotation =
    qk_circuit_inst_pauli_product_rotation(qc.ptr, index; offset=qc.offset)

qk_circuit_inst_pauli_product_measurement(
    qc::QuantumCircuit,
    index::Integer,
)::PauliProductMeasurement =
    qk_circuit_inst_pauli_product_measurement(qc.ptr, index; offset=qc.offset)

"""
    pauli_product_instruction(qc::QuantumCircuit, index::Integer)

Read the Pauli-based instruction at `index`, returning either a
`PauliProductRotation` or a `PauliProductMeasurement`.

Throws an `ArgumentError` if the instruction at `index` is neither.  Use
`qk_circuit_instruction_kind` to check first, or `pauli_product_instructions`
to collect every Pauli-based instruction in a circuit.
"""
function pauli_product_instruction(
    qc::QuantumCircuit,
    index::Integer,
)::Union{PauliProductRotation,PauliProductMeasurement}
    kind = qk_circuit_instruction_kind(qc, index)
    if kind === LibQiskit.QkOperationKind_PauliProductRotation
        return qk_circuit_inst_pauli_product_rotation(qc, index)
    elseif kind === LibQiskit.QkOperationKind_PauliProductMeasurement
        return qk_circuit_inst_pauli_product_measurement(qc, index)
    end
    throw(
        ArgumentError(
            "Instruction at index $index is not a Pauli-based instruction (kind: $kind).",
        ),
    )
end

"""
    pauli_product_instructions(qc::QuantumCircuit)

Return every Pauli-based instruction in `qc`, in circuit order, as a `Vector`
of `PauliProductRotation` and `PauliProductMeasurement`.

Instructions of any other kind are skipped, so for a circuit that has been
fully converted to Pauli-based form this returns one entry per instruction.
"""
function pauli_product_instructions(
    qc::QuantumCircuit,
)::Vector{Union{PauliProductRotation,PauliProductMeasurement}}
    retval = Union{PauliProductRotation,PauliProductMeasurement}[]
    for index in range(qc.offset, length=qk_circuit_num_instructions(qc))
        kind = qk_circuit_instruction_kind(qc, index)
        if kind === LibQiskit.QkOperationKind_PauliProductRotation
            push!(retval, qk_circuit_inst_pauli_product_rotation(qc, index))
        elseif kind === LibQiskit.QkOperationKind_PauliProductMeasurement
            push!(retval, qk_circuit_inst_pauli_product_measurement(qc, index))
        end
    end
    return retval
end

# The instruction names the Litinski transformation accepts, mirroring
# `SUPPORTED_INSTRUCTION_NAMES` in the Rust pass.  The pass reports unsupported
# instructions by panicking, which aborts the process rather than raising
# something catchable (Qiskit/qiskit#17179), so the names are duplicated here to
# check a circuit before handing it over.
#
# This whole guard exists only because of that upstream behavior and should be
# removed once the pass returns an error instead: there would then be nothing to
# duplicate, since the circuit could simply be handed over and the error
# surfaced.
#
# Drift against the pass's own list is handled asymmetrically, because only one
# direction is dangerous.  If the pass stops supporting a name listed here, a
# circuit using it reaches the pass and aborts; a test builds a circuit for each
# name so that failure happens in CI rather than in a user's session.  If the
# pass *gains* support for a name missing here, this guard rejects a circuit the
# pass would have accepted, which is merely a wrong error message and is left
# uncovered: detecting it would mean running the pass on instructions it may
# still reject, which aborts the test process instead of failing it.
const LITINSKI_SUPPORTED_OPERATIONS = Set([
    "id",
    "x",
    "y",
    "z",
    "h",
    "s",
    "sdg",
    "sx",
    "sxdg",
    "cx",
    "cz",
    "cy",
    "swap",
    "iswap",
    "ecr",
    "dcx",
    "t",
    "tdg",
    "rz",
    "rx",
    "ry",
    "p",
    "u1",
    "measure",
    "pauli_product_rotation",
    "pauli_product_measurement",
])

function check_litinski_supported(qc::QuantumCircuit)::Nothing
    unsupported = [
        name for
        (name, _) in qk_circuit_count_ops(qc) if name ∉ LITINSKI_SUPPORTED_OPERATIONS
    ]
    if !isempty(unsupported)
        throw(
            ArgumentError(
                "Unable to run the Litinski transformation: the circuit contains " *
                "instructions the pass does not support: " *
                join(sort(unsupported), ", ") *
                ".  Transpile into a Clifford + RZ basis first.",
            ),
        )
    end
    nothing
end

"""
    litinski_transformation!(qc::QuantumCircuit; fix_clifford::Bool=false)

Run the Litinski transformation on `qc` in place, returning `qc`.

The pass commutes every Clifford gate to the end of the circuit, converting
Pauli rotations into `PauliProductRotation` instructions and measurements into
`PauliProductMeasurement` instructions.  When `fix_clifford` is `true` the
Clifford gates are left at the end of the circuit; otherwise they are omitted.

The non-Clifford gates must be drawn from `T`, `Tdg`, `RZ`, `RX`, `RY`, `P`,
and `U1`; the suggested workflow is to transpile into a Clifford + `RZ` basis
first.  Read the result back with `pauli_product_instructions`.

Throws an `ArgumentError` if `qc` contains an instruction the pass does not
support, which it would otherwise report by aborting the process
([Qiskit/qiskit#17179](https://github.com/Qiskit/qiskit/issues/17179)).
"""
function litinski_transformation!(
    qc::QuantumCircuit;
    fix_clifford::Bool=false,
)::QuantumCircuit
    check_not_null(qc.ptr)
    check_litinski_supported(qc)
    LibQiskit.qk_transpiler_pass_standalone_litinski_transformation(qc.ptr, fix_clifford)
    return qc
end

"""
    convert_to_pauli_rotations!(qc::QuantumCircuit)

Convert `qc` in place into Pauli-based computation form, returning `qc`.

Standard gates become `PauliProductRotation` instructions and measurements
become `PauliProductMeasurement` instructions.  Unlike
`litinski_transformation!`, this does not commute Cliffords to the end of the
circuit.  Read the result back with `pauli_product_instructions`.
"""
function convert_to_pauli_rotations!(qc::QuantumCircuit)::QuantumCircuit
    check_not_null(qc.ptr)
    LibQiskit.qk_transpiler_pass_standalone_convert_to_pauli_rotations(qc.ptr)
    return qc
end

export PauliProduct, PauliProductRotation, PauliProductMeasurement, pauli_label
export pauli_product_instruction, pauli_product_instructions
export litinski_transformation!, convert_to_pauli_rotations!
