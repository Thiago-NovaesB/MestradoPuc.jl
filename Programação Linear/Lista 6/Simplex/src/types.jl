mutable struct Input
    A::Matrix{}
    b::Vector{}
    c::Vector{}
    n::Int
    m::Int
    rho::Float64
    alpha::Float64
    tol::Float64
    max_iter::Int
    verbose::Bool
end

Base.@kwdef mutable struct MidTerm
    termination_status::Int = 0
    iter::Int = 0
    d_x::Vector{Float64} = []
    d_p::Vector{Float64} = []
    d_s::Vector{Float64} = []
    z::Float64 = 0.0
    x::Vector{Float64} = []
    s::Vector{Float64} = []
    mu::Float64 = 0.0
 
end

struct Output
    x::Vector{Float64}
    z::Float64
    termination_status::Int
    base::Vector{Int}
    nbase::Vector{Int}
end
