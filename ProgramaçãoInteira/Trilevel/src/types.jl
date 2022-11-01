@kwdef mutable struct Data
    obj::Float64
    Gmax::Vector{Float64}
    expGmax::Vector{Float64}
    C::Vector{Float64}
    Fmax::Vector{Float64}
    demand::Vector{Float64}
    nter::Int
    nlin::Int
    nbus::Int
    ter2bus::Vector{Int}
    A::Matrix{Int}
    expG::Vector{Float64}
    contg::Vector{Int}
    expL::Vector{Int}
    exist::Vector{Int}
    contl::Vector{Int}
    k::Int
    bigM::Float64
    max_extra_demand::Int
    def_cost::Float64
    exp_cost_g::Vector{Float64}
    exp_cost_l::Vector{Float64}
end