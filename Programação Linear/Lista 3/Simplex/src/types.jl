struct Input
    A::Matrix{}
    b::Vector{}
    c::Vector{}
    base::Vector{Int}
    nbase::Vector{Int}
    tol::Float64
    max_iter::Int
    verbose::Int
end

struct Output
    x::Vector{Float64}
    z::Float64
    termination_status::Int
    base::Vector{Int}
    nbase::Vector{Int}

end
