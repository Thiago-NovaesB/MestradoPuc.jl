struct Input

    y
    
    Z
    T
    d
    c
    R

    Z_t
    T_t
    d_t
    c_t
    R_t

    Z_inf
    Z_sup
    T_inf
    T_sup
    d_inf
    d_sup
    c_inf
    c_sup
    R_inf
    R_sup

    Z_inf_t
    Z_sup_t
    T_inf_t
    T_sup_t
    d_inf_t
    d_sup_t
    c_inf_t
    c_sup_t
    R_inf_t
    R_sup_t
end

struct Options
    constant_in_time::Bool
    input_variables::Bool
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
