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

module Qiskit

using Compat

module C

libdir = joinpath(@__DIR__, "..", "lib")
include(joinpath(libdir, "LibQiskit.jl"))

using Qiskit_jll

libqiskit = Qiskit_jll.libqiskit

include("c_exit_code.jl")
include("c_circuit.jl")
include("c_target.jl")
include("c_transpile.jl")
include("c_observable.jl")

end # module C

import .C: libqiskit

include("circuit.jl")
include("target.jl")
include("transpile.jl")
include("observable.jl")

end # module Qiskit
