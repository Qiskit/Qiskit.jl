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

obs = SparseObservable(5)
@test qk_obs_num_terms(obs) == 0
@test qk_obs_num_qubits(obs) == 5

@testset "BitTerm labels" begin
    @test qk_bitterm_label(QkBitTerm_X) == 'X'
    @test qk_bitterm_label(QkBitTerm_Y) == 'Y'
    @test qk_bitterm_label(QkBitTerm_Z) == 'Z'
    @test qk_bitterm_label(QkBitTerm_Plus) == '+'
    @test qk_bitterm_label(QkBitTerm_Minus) == '-'
    @test qk_bitterm_label(QkBitTerm_Right) == 'r'
    @test qk_bitterm_label(QkBitTerm_Left) == 'l'
    @test qk_bitterm_label(QkBitTerm_Zero) == '0'
    @test qk_bitterm_label(QkBitTerm_One) == '1'
end

@testset "Base.show" begin
    obs = SparseObservable(3)

    # Compact form
    io = IOBuffer()
    show(io, obs)
    @test String(take!(io)) == "SparseObservable(3; 0 terms)"

    # text/plain form for REPL display
    io = IOBuffer()
    show(io, MIME"text/plain"(), obs)
    output = String(take!(io))
    @test startswith(output, "SparseObservable with 3 qubits")
    @test contains(output, "terms: 0")

    # NULL path
    obs5 = SparseObservable(5)
    qk_obs_free(obs5)
    io = IOBuffer()
    show(io, obs5)
    @test String(take!(io)) == "SparseObservable(NULL)"
end
