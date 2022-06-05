struct Input

    y
    
    Z
    T
    d
    c
    R
end

struct Options
    constant_in_time::Bool
end

Base.@kwdef mutable struct Sizes
    n::Integer = 0
    p::Integer = 0
    m::Integer = 0
    r::Integer = 0

end

struct Problem
    input::Input
    options::Options
    sizes::Sizes
end

Base.@kwdef mutable struct MidTerm

end

Base.@kwdef mutable struct Output
end
