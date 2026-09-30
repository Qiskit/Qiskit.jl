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

@testset "Parameter" begin
    @testset "Construction" begin
        p = Parameter("theta")
        @test string(p) == "theta"
        @test isa(p, Parameter)

        p2 = Parameter(3.14)
        @test as_real(p2) ≈ 3.14

        p3 = Parameter(2.5 + 1.0im)
        @test isa(p3, Parameter)

        p4 = Parameter(42)
        @test as_real(p4) ≈ 42.0
    end

    @testset "Copy and equality" begin
        a = Parameter("a")
        b = copy(a)
        @test a == b

        c = Parameter("c")
        @test a != c
    end

    @testset "Arithmetic" begin
        a = Parameter("a")
        b = Parameter("b")

        c = a + b
        @test isa(c, Parameter)

        c = a - b
        @test isa(c, Parameter)

        c = a * b
        @test isa(c, Parameter)

        c = a / b
        @test isa(c, Parameter)

        c = a^b
        @test isa(c, Parameter)

        c = -a
        @test isa(c, Parameter)
    end

    @testset "Arithmetic with reals" begin
        a = Parameter("a")

        c = a + 2.0
        @test isa(c, Parameter)

        c = 2.0 + a
        @test isa(c, Parameter)

        c = a - 1.5
        @test isa(c, Parameter)

        c = 1.5 - a
        @test isa(c, Parameter)

        c = a * 3.0
        @test isa(c, Parameter)

        c = 3.0 * a
        @test isa(c, Parameter)

        c = a / 2.0
        @test isa(c, Parameter)

        c = 2.0 / a
        @test isa(c, Parameter)

        c = a^2
        @test isa(c, Parameter)

        c = 2^a
        @test isa(c, Parameter)
    end

    @testset "Unary functions" begin
        a = Parameter("a")

        @test isa(sin(a), Parameter)
        @test isa(cos(a), Parameter)
        @test isa(tan(a), Parameter)
        @test isa(asin(a), Parameter)
        @test isa(acos(a), Parameter)
        @test isa(atan(a), Parameter)
        @test isa(log(a), Parameter)
        @test isa(exp(a), Parameter)
        @test isa(abs(a), Parameter)
        @test isa(sign(a), Parameter)
        @test isa(conj(a), Parameter)
    end

    @testset "Numeric evaluation" begin
        p = Parameter(2.5)
        @test as_real(p) ≈ 2.5

        p2 = Parameter(1.0 + 2.0im)
        @test as_real(p2) ≈ 1.0
    end

    @testset "Show" begin
        p = Parameter("theta")
        io = IOBuffer()
        show(io, p)
        @test String(take!(io)) == "Parameter(theta)"

        p2 = Parameter(3.14)
        io = IOBuffer()
        show(io, p2)
        @test String(take!(io)) == "Parameter(3.14)"
    end

    @testset "Parameterized circuit gates" begin
        qc = QuantumCircuit(2, 0)
        theta = Parameter("theta")

        qc.rz(theta, 1)
        @test qc.num_instructions == 1
        @test qc.data[1].name == "rz"
        # Symbolic params return NaN via as_real
        @test isnan(qc.data[1].params[1])

        qc.rx(theta, 2)
        @test qc.num_instructions == 2
        @test qc.data[2].name == "rx"

        qc_copy = copy(qc)
        @test qc_copy.num_instructions == 2
    end

    @testset "Parameterized !-suffixed functions" begin
        qc = QuantumCircuit(2, 0)
        theta = Parameter("theta")

        rz!(qc, theta, 1)
        @test qc.num_instructions == 1
        @test qc.data[1].name == "rz"
    end

    @testset "Expression as gate parameter" begin
        qc = QuantumCircuit(2, 0)
        theta = Parameter("theta")
        expr = 2 * theta + 1.0

        qc.rz(expr, 1)
        @test qc.num_instructions == 1
        @test qc.data[1].name == "rz"
    end
end
