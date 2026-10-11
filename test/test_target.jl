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

    @testset "add_property! and add_instruction!" begin
        target = Qiskit.Target(2)
        entry = Qiskit.target_entry_gate(QkGate_X)

        # Each function returns the object it mutates
        @test Qiskit.add_property!(entry, [1], 1.8e-9, 0.8e-6) === entry
        @test Qiskit.add_property!(entry, [2], 1.8e-9, 0.8e-6) === entry
        @test entry.num_properties == 2
        @test Qiskit.add_instruction!(target, entry) === target
        @test target.num_instructions == 1

        # The entry is consumed
        @test entry.ptr == C_NULL

        # Reusing a consumed entry gives a clear error at the porcelain level
        msg = "This TargetEntry has already been added to a Target and can no longer be used."
        @test_throws msg Qiskit.add_property!(entry, [1], 0.0, 0.0)
        @test_throws msg Qiskit.add_instruction!(target, entry)
        @test target.num_instructions == 1

        # ... and at the C level, rather than aborting the process
        @test_throws "Ptr{QkTargetEntry} is NULL." qk_target_entry_add_property(
            entry,
            [1],
            0.0,
            0.0,
        )
        @test_throws "Ptr{QkTargetEntry} is NULL." qk_target_add_instruction(target, entry)

        # The chained form works
        target2 = Qiskit.Target(2)
        h_entry = Qiskit.target_entry_gate(QkGate_H)
        @test Qiskit.add_instruction!(
            target2,
            Qiskit.add_property!(h_entry, [1], 0.0, 0.0),
        ) === target2
        @test h_entry.ptr == C_NULL
        @test target2.num_instructions == 1
    end
end
