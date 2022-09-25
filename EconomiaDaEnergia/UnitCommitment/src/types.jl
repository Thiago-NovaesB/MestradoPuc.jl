@kwdef mutable struct Options
    solver::Union{DataType,Nothing}=nothing
    use_kirchhoff::Bool
    use_ramp::Bool
    use_commit::Bool
    use_up_down_time::Bool
    use_contingency::Bool
end

@kwdef mutable struct Data
    g_max::Vector{Float64}
    g_min::Vector{Float64}
    f_max::Vector{Float64}
    gen2bus::Vector{Int}
    A::Matrix{Int}
    demand::Matrix{Float64}
    gen_cost::Vector{Float64}
    def_cost::Vector{Float64}
    ramp_up::Vector{Float64}
    ramp_down::Vector{Float64}
    up_time::Vector{Int}
    down_time::Vector{Int}
    turn_on_cost::Vector{Float64}
    turn_off_cost::Vector{Float64}
    contingency_gen::Matrix{Bool}
    contingency_lin::Matrix{Bool}
    reserve_plus_cost::Vector{Float64}
    reserve_minus_cost::Vector{Float64}
    def_cost_rev::Vector{Float64}
    gen_cut_cost::Vector{Float64}
end

@kwdef mutable struct Size
    stages::Int
    bus::Int
    circ::Int
    gen::Int
    K::Int
end

@kwdef mutable struct Output
end

@kwdef mutable struct Problem
    options::Options
    data::Data
    size::Size
    output::Output
    model::JuMP.Model
end