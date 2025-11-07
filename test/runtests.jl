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

@testset "Qiskit.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Qiskit)
    end
    include("test_circuit.jl")
    include("test_target.jl")
    include("test_transpiler.jl")
    include("test_observable.jl")
end
