mutable struct Input
    A::Matrix{}
    b::Vector{}
    c::Vector{}
    n::Int
    m::Int
    tol::Float64
    max_iter::Int
    verbose::Bool
end

Base.@kwdef mutable struct MidTerm
    termination_status::Int = 0
    iter::Int = 0
    d::Vector{} = []
    base::Vector{Int} = []
    nbase::Vector{Int} = []
    i::Int = 0
    j::Int = 0
    z::Float64 = 0.0
    x::Vector{Float64} = []
    red_cost::Vector{Float64} = []
end

struct Output
    x::Vector{Float64}
    z::Float64
    termination_status::Int
    base::Vector{Int}
    nbase::Vector{Int}
end
