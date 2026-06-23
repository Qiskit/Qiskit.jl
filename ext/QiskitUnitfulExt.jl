module QiskitUnitfulExt

import Unitful
import Qiskit: QuantumCircuit, DelayInstructionClosure, delay!
import Qiskit.C: qk_circuit_delay, QkDelayUnit_S, QkDelayUnit_MS, QkDelayUnit_US, QkDelayUnit_NS, QkDelayUnit_PS

"""
    delay!(qc::QuantumCircuit, qubit::Integer, duration::Unitful.Time)::Nothing

Append a delay on `qubit` whose length is given as a Unitful quantity (e.g.
`1.0u"μs"`). Uses the unit specified by the user. Mutates `qc`.

# Supported units
- `s` (seconds)
- `ms` (milliseconds)
- `μs` (microseconds)
- `ns` (nanoseconds)
- `ps` (picoseconds)

Other units are not supported.
"""
function delay!(qc::QuantumCircuit, qubit::Integer, duration::Unitful.Time)::Nothing
    # Extract the numeric value and unit the user specified
    val = Unitful.ustrip(duration)
    u = Unitful.unit(duration)

    # Map to a Qiskit-supported unit
    if u == Unitful.s
        qk_unit = QkDelayUnit_S
    elseif u == Unitful.ms
        qk_unit = QkDelayUnit_MS
    elseif u == Unitful.μs
        qk_unit = QkDelayUnit_US
    elseif u == Unitful.ns
        qk_unit = QkDelayUnit_NS
    elseif u == Unitful.ps
        qk_unit = QkDelayUnit_PS
    else
        throw(ArgumentError("unsupported Unitful duration unit: $(u)"))
    end

    qk_circuit_delay(qc, qubit, val, qk_unit)
    return nothing
end

# Property-style sugar forwards to the canonical `delay!`.
(cl::DelayInstructionClosure)(qubit::Integer, duration::Unitful.Time)::Nothing =
    delay!(cl.qc, qubit, duration)

end
