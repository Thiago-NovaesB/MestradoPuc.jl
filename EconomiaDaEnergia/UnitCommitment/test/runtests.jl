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
        generation = value.(prb.model[:generation])
        @test generation[1,1] ≈ 50.0
        @test generation[2,1] ≈ 50.0
    end
end