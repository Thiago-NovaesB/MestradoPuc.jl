@kwdef mutable struct Data
    B::Int64
    C::Int64
    T::Int64
    Tarr::Vector{Int64}
    Tg::Vector{Int64}

    grid_price::Vector{Float64}
    swap_price::Float64
    pv_price::Float64
    energy_price::Float64
    selling_price::Float64
    D::Float64
    store_max::Float64
    store_min::Float64
    swap_min::Float64
    energy_arrived::Vector{Float64}
    store_init::Vector{Float64}
    bat_efficiency::Float64
    con_efficiency::Float64
    converter_rate::Float64
    pv_generation::Vector{Float64}
    grid_max::Float64
    charging_rate::Float64
    theta::Float64
    beta::Float64
    rho::Float64
    solver::Union{DataType,Nothing} = nothing
end

@kwdef mutable struct Cache

end

@kwdef mutable struct Output

end


@kwdef mutable struct Problem
    data::Data
    cache::Cache
    output::Output
    model::JuMP.Model
end

