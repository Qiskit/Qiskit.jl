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

using Qiskit
using Qiskit.C
using Test
using Aqua
using Unitful

@testset "Qiskit.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Qiskit)
    end
    include("test_circuit.jl")
    include("test_operations.jl")
    include("test_target.jl")
    include("test_transpiler.jl")
    include("test_observable.jl")

    # The wrapper types (`QuantumCircuit`, `Target`, `TargetEntry`,
    # `SparseObservable`, transpile layouts) register finalizers that call the
    # corresponding `qk_*_free` C functions. Those finalizer bodies only run
    # when the garbage collector reclaims the objects, which is nondeterministic
    # and may not happen before the test process exits — leaving the free paths
    # showing as uncovered (and inconsistently so across CI matrix jobs). Force
    # a collection here so the finalizers run deterministically.
    GC.gc()
end
