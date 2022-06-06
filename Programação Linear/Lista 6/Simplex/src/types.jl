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

struct Output
    x::Vector{}
    s::Vector{}
    p::Vector{}
    mu::Float64
    z::Float64
    termination_status::Int
    iter::Integer
end
