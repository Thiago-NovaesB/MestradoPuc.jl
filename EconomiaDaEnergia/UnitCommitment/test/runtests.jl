using Test
using UnitCommitment
using HiGHS
using JuMP

include("test_def.jl")

@testset "All Cases" begin
    @testset "Case01" begin
        prb = teste_1()
        generation = value.(prb.model[:generation])
        @test generation[1,1] ≈ 100.0
        @test generation[2,1] ≈ 0.0
    end
    @testset "Case02" begin
        prb = teste_2()
        generation = value.(prb.model[:generation])
        @test generation[1,1] ≈ 80.0
        @test generation[2,1] ≈ 20.0
    end
    @testset "Case03" begin
        prb = teste_3()
    end
    @testset "Case04" begin
        prb = teste_4()
    end
    @testset "Case05" begin
        prb = teste_5()
    end
    @testset "Case06" begin
        prb = teste_6()
    end
end