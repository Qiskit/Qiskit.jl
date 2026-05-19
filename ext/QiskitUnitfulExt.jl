module QiskitUnitfulExt

import Unitful
import Qiskit: DelayInstructionClosure
import Qiskit.C: qk_circuit_delay, QkDelayUnit_S, QkDelayUnit_MS, QkDelayUnit_US, QkDelayUnit_NS, QkDelayUnit_PS

"""
    (cl::DelayInstructionClosure)(qubit::Integer, duration::Unitful.Quantity)::Nothing

Method for Unitful quantities. Uses the unit specified by the user.

# Arguments
- `qubit`: The qubit index
- `duration`: A Unitful.jl quantity (e.g., `1.0u"μs"`)

# Supported units
- `s` (seconds)
- `ms` (milliseconds)
- `μs` (microseconds)
- `ns` (nanoseconds)
- `ps` (picoseconds)

Other units will be converted to the nearest supported unit.
"""
function (cl::DelayInstructionClosure)(qubit::Integer, duration::Unitful.Quantity)::Nothing
    # Extract the numeric value and unit the user specified
    val = Unitful.ustrip(duration)
    u = Unitful.unit(duration)
    
    # Map to a Qiskit-supported unit
    if u == Unitful.s
        qk_unit = QkDelayUnit_S
        final_duration = val
    elseif u == Unitful.ms
        qk_unit = QkDelayUnit_MS
        final_duration = val
    elseif u == Unitful.μs
        qk_unit = QkDelayUnit_US
        final_duration = val
    elseif u == Unitful.ns
        qk_unit = QkDelayUnit_NS
        final_duration = val
    elseif u == Unitful.ps
        qk_unit = QkDelayUnit_PS
        final_duration = val
    else
        # For unsupported units, convert to seconds and use the seconds unit
        duration_s = Unitful.uconvert(Unitful.s, duration) |> Unitful.ustrip
        qk_unit = QkDelayUnit_S
        final_duration = duration_s
    end
    
    qk_circuit_delay(cl.qc, qubit, final_duration, qk_unit)
    return nothing
end

end
