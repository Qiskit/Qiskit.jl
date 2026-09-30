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

    @testset "A failed add_instruction still consumes the entry" begin
        target = Qiskit.Target(2)

        first_entry = Qiskit.target_entry_gate(QkGate_H)
        qk_target_entry_add_property(first_entry, [1], 0.0, 0.0)
        qk_target_add_instruction(target, first_entry)
        @test first_entry.ptr == C_NULL

        # Adding the same gate again fails, but still Qiskit will take ownership of the
        # entry, so our pointer must be cleared.
        duplicate = Qiskit.target_entry_gate(QkGate_H)
        qk_target_entry_add_property(duplicate, [1], 0.0, 0.0)
        @test_throws "Instruction already exists in the Target" qk_target_add_instruction(
            target,
            duplicate,
        )
        @test duplicate.ptr == C_NULL

        # Freeing it again is then a no-op, as it is for any spent entry.
        qk_target_entry_free(duplicate)
        @test duplicate.ptr == C_NULL
    end
end
