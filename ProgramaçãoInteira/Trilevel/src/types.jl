@kwdef mutable struct Data
    Gmax::Vector{Float64}
    C::Vector{Float64}
    Fmax::Vector{Float64}
    demand::Vector{Float64}
    def::Vector{Float64}
    nter::Int
    nlin::Int
    nbus::Int
    ter2bus::Vector{Int}
    A::Matrix{Int}
    expG::Vector{Float64}
    contg::Vector{Int}
    expL::Vector{Int}
    contl::Vector{Int}
end