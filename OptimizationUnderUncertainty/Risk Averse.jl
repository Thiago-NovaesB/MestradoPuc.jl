using Pkg
Pkg.activate(".")

using JuMP, HiGHS, Statistics, Plots, Random, Printf, LinearAlgebra, Distributions

optimizer = () -> HiGHS.Optimizer()

d = collect(60:1:150)
N = length(d)
p = (1/N)*ones(N);

function deterministic_equivalent_newsvendor_risk_averse(λ, α)
    m = Model(optimizer)
    set_silent(m)
    @variables(m,
    begin
        x ≥ 0
        z
        y[1:N] ≥ 0
        δ[1:N] ≥ 0
        w[1:N] ≥ 0
    end)

    @constraints(m,
    begin
        x ≤ 150
        ct1[s=1:N], y[s] ≤ d[s]
        ct2[s=1:N], y[s] + w[s] ≤ x
        ct3[s=1:N], δ[s] ≥ -25*y[s] -5*w[s] - z 
    end)

    @objective(m, Min, 10 * x + (1-λ)*sum(p[s]*(-25*y[s] -5*w[s]) for s = 1:N) + λ*(z + sum(p[s]*(δ[s]/(1-α)) for s = 1:N)))

    optimize!(m)

    value(x), objective_value(m)
end

λ = 0.30
α = 0.95
deterministic_equivalent_newsvendor_risk_averse(λ, α)

λs = collect(0.0:0.05:1.0)
α = 0.90
values = deterministic_equivalent_newsvendor_risk_averse.(λs, α)

plot(λs,last.(values),legend=:false)

function subproblem_newsvendor_stage2(x,ξ)
    m = Model(optimizer)
    set_silent(m)
    @variables(m, 
    begin
        y ≥ 0
        w ≥ 0
        x2 ≥ 0
    end)

    @constraints(m,
    begin
        y ≤ ξ
        y + w ≤ x2
  copy, x2 == x
    end)

    @objective(m, Min, -25 * y - 5 * w)
    optimize!(m)
    return m
end

function subproblem_newsvendor_stage1(α, λ)
    m = Model(optimizer)
    set_silent(m)
    @variables(m, 
    begin
        x ≥ 0
        θ[1:N] ≥ -1e8
        δ[1:N] ≥ 0
        z
    end)
    
    @constraints(m,
    begin
           x ≤ 150
[s = 1:N], δ[s] + z ≥ θ[s]
    end)
    aux = 
    @objective(m, Min, 10*x + (1-λ)*sum(p[s]*θ[s] for s = 1:N) + λ*z + λ*(sum(p[s]*(δ[s]/(1-α)) for s = 1:N)))
    return m
end

function CVAR(x,p,α)
    N = length(x)
    m = Model(optimizer)
    set_silent(m)
    @variable(m, q[1:N] ≥ 0)
    @constraint(m, sum(q) == 1)
    @constraint(m, [s = 1:N], q[s] ≤ p[s]/(1-α))
    @objective(m, Max, sum(q.*x))
    optimize!(m)
    return objective_value(m)
end

mutable struct Cut
    π::Union{Float64,Vector{Float64}}
    x::Union{Float64,Vector{Float64}}
    v::Float64
    s::Int64
end

function apply_cuts!(sub1::JuMP.Model, cuts::Vector{Cut})
    
    θ = sub1[:θ]
    x = sub1[:x]
    
    for cut in cuts
        @constraint(sub1, θ[cut.s] >= dot(cut.π,x .- cut.x) + cut.v)
    end
    
    return sub1
end

function benders_decomposition(subproblem1,subproblem2,Ω,p,α,λ;max_iterations = 10)
    LB = -Inf
    UB = +Inf
    cuts = Cut[]
    LBs = Float64[]
    UBs = Float64[]
    tol = 1e-3
    println("Iter |      LB      |      UB      |  Time")
    println("-"^42)
    t_1 = time_ns()
    N = length(p)
    vs = []
    x=0
    for iter in 1:max_iterations
        sub1 = subproblem1(α, λ)
        if iter > 1
            sub1 = apply_cuts!(sub1, cuts)
        end
        optimize!(sub1)
        x = value.(sub1[:x])
        z = value(sub1[:z])
        if iter > 1
            LB = objective_value(sub1)
            push!(LBs,LB)
        end
        πs = []
        vs = []
        
        for (s,ω) in enumerate(Ω)
            sub2 = subproblem2(x,ω)
            optimize!(sub2)
            
            @show π = dual.(sub2[:copy])
            push!(πs,π)
            
            @show v = objective_value(sub2)
            push!(vs,v)
            
            cut = Cut(π,x,v,s)
            push!(cuts,cut)
        end
        
        bar_v = sum(p[s]*vs[s] for s in 1:N)
        cvar = CVAR(vs,p,α)
        if iter > 1
            UB = 10*x + (1-λ)*bar_v + λ*cvar
            push!(UBs,UB)
        end
        
        t_2 = time_ns()
        time = (t_2-t_1)/1e9
        @printf("%3d  |  %10.3e  |  %10.3e  | %5.3f\n", iter, LB, UB, time)
        if abs(UB - LB) < tol
            break
        end
    end
    return cuts, LBs, UBs, x
end

λ = 0
α = 0.90
cuts, LBs, UBs, x = benders_decomposition(subproblem_newsvendor_stage1,subproblem_newsvendor_stage2,d,p,α,λ;max_iterations = 10);

λ = 0.50
α = 0.90
deterministic_equivalent_newsvendor_risk_averse(λ, α)


