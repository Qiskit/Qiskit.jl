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

@testset "Base.show method" begin
    obs = SparseObservable(3)
    io = IOBuffer()
    show(io, obs)
    output = String(take!(io))
    @test contains(output, "SparseObservable")
    @test contains(output, "num_qubits=3")
    @test contains(output, "num_terms=0")

    # Test with different qubit count
    obs5 = SparseObservable(5)
    io = IOBuffer()
    show(io, obs5)
    output = String(take!(io))
    @test contains(output, "num_qubits=5")
end
