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

    @testset "Base.show method for Target" begin
        io = IOBuffer()
        show(io, target)
        output = String(take!(io))
        @test contains(output, "Target")
        @test contains(output, "num_qubits=4")
        @test contains(output, "num_instructions=0")

        # Test with different qubit count
        target10 = Qiskit.Target(10)
        io = IOBuffer()
        show(io, target10)
        output = String(take!(io))
        @test contains(output, "num_qubits=10")

        qk_target_free(target10)
        io = IOBuffer()
        show(io, target10)
        @test String(take!(io)) == "Target()"
    end

    @testset "Base.show method for TargetEntry" begin
        entry = Qiskit.target_entry_gate(QkGate_X)
        io = IOBuffer()
        show(io, entry)
        output = String(take!(io))
        @test contains(output, "TargetEntry")
        @test contains(output, "num_properties")

        qk_target_entry_free(entry)
        io = IOBuffer()
        show(io, entry)
        @test String(take!(io)) == "TargetEntry()"
    end
end
