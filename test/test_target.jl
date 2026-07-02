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

@testset "Target" begin
    target = Qiskit.Target(4)
    target2 = copy(target)

    @testset "Base.show for Target" begin
        # Compact form
        io = IOBuffer()
        show(io, target)
        @test String(take!(io)) == "Target(4; 0 instructions)"

        # text/plain form for REPL display
        io = IOBuffer()
        show(io, MIME"text/plain"(), target)
        output = String(take!(io))
        @test startswith(output, "Target with 4 qubits")
        @test contains(output, "instructions: 0")

        # NULL path
        target10 = Qiskit.Target(10)
        qk_target_free(target10)
        io = IOBuffer()
        show(io, target10)
        @test String(take!(io)) == "Target(NULL)"
    end

    @testset "Base.show for TargetEntry" begin
        entry = Qiskit.target_entry_gate(QkGate_X)

        # Compact form: no positional constructor args, so annotation only
        io = IOBuffer()
        show(io, entry)
        @test String(take!(io)) == "TargetEntry(; 0 properties)"

        # text/plain form
        io = IOBuffer()
        show(io, MIME"text/plain"(), entry)
        output = String(take!(io))
        @test startswith(output, "TargetEntry")
        @test contains(output, "properties: 0")

        # NULL path
        qk_target_entry_free(entry)
        io = IOBuffer()
        show(io, entry)
        @test String(take!(io)) == "TargetEntry(NULL)"
    end
end
