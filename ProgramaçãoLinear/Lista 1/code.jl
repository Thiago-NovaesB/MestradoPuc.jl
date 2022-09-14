using Pkg
Pkg.activate("..\\..");
using JuMP;
using Plots;
using GLPK;
using CSV;
using DataFrames;

df = CSV.read("eolica.csv", DataFrame);
data = df[:,2];
function L(data::Vector{Float64}, k::Int = 0)
    x = data[1:end-k]
    y = data[k+1:end]

    return x, y
end

function plot_shift(data::Vector{Float64}, k::Int = 0)
    x, y = L(data, k)
    p = plot(x, y, seriestype = :scatter, title = "k = $k")

    return p
end

function auto_regression_model(data::Vector{Float64}, K::Vector{Int} = [1])

    n = length(K)
    N = length(data)
    k_max = maximum(K)

    model = Model(GLPK.Optimizer)
    @variable(model, beta[1:n+1])
    @variable(model, error[1:N-k_max])

    @expression(model, AR[i = 1:N-k_max], 
        beta[1] + 
        sum(beta[j+1]*data[i + k_max - K[j]] for j = 1:n))

    @constraint(model, [i = 1:N-k_max], error[i] >= + data[i + k_max] - AR[i] )
    @constraint(model, [i = 1:N-k_max], error[i] >= - data[i + k_max] + AR[i] )

    @objective(model, Min, sum(error))

    optimize!(model)
    
    return model
end

function agregate(data::Vector{Float64}, s::Int)
    agregated = Float64[]
    location = 1
    size = length(data)

    while true
        if location+s-1 <= size
            interval = data[location:location+s-1]
            value =  sum(interval) / s
            push!(agregated, value)
            location = location+s
        else
            break
        end
    end

    return agregated
end

function season_model(data::Vector{Float64}, S::Vector{Int} = [8760], M::Vector{Int} = [1])

    N = length(data)
    m = length(S)

    model = Model(GLPK.Optimizer)
    @variable(model, error[1:N])
    @variable(model, theta[1:sum(M)])
    @variable(model, phi[1:sum(M)])
    @variable(model, level)
        
    @expression(model, ST[i = 1:N], level + sum(sum(
        theta[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*cos(2*pi*k*i/S[j]) + 
        phi[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*sin(2*pi*k*i/S[j]) 
        for k in 1:M[j]) for j = 1:m))

    @constraint(model, [i = 1:N], error[i] >= + data[i] - ST[i])
    @constraint(model, [i = 1:N], error[i] >= - data[i] + ST[i])

    @objective(model, Min, sum(error))

    optimize!(model)

    write_to_file(model, "teste.lp")
    
    return model
end

function complete_model(data::Vector{Float64}, K::Vector{Int} = [1], S::Vector{Int} = [8760], M::Vector{Int} = [1])

    n = length(K)
    N = length(data)
    k_max = maximum(K)
    m = length(S)

    model = Model(GLPK.Optimizer)
    @variable(model, beta[1:n+1])
    @variable(model, error[1:N-k_max])
    @variable(model, theta[1:sum(M)])
    @variable(model, phi[1:sum(M)])

    @expression(model, AR[i = 1:N-k_max], 
        beta[1] + 
        sum(beta[j+1]*data[i + k_max - K[j]] for j = 1:n))
        
    @expression(model, ST[i = 1:N-k_max], sum(sum(
        theta[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*cos(2*pi*k*i/S[j]) + 
        phi[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*sin(2*pi*k*i/S[j]) 
        for k in 1:M[j]) for j = 1:m))

    @expression(model, estimate[i = 1:N-k_max], AR[i] + ST[i])

    @constraint(model, [i = 1:N-k_max], error[i] >= + data[i + k_max] - estimate[i])
    @constraint(model, [i = 1:N-k_max], error[i] >= - data[i + k_max] + estimate[i])

    @objective(model, Min, sum(error))

    optimize!(model)
    
    return model
end

function r_square(data::Vector{Float64}, estimative::Vector{Float64})
    output = 1.0
    n = length(data)
    average = sum(data) / n
    
    output = 1.0 - sum((data[i] - estimative[i])^2 for i in 1:n) / sum((data[i] - average)^2 for i in 1:n) 

    return output
end

function mae(data::Vector{Float64}, estimative::Vector{Float64}, T::Int)
    output = 0.0

    K = length(data) - T
      
    for i in (T+1):(T+K)
        output += abs(data[i] - estimative[i]) / K
    end
    
    return output
end

function forecast(data::Vector{Float64}, K::Vector{Int} = [1], S::Vector{Int} = [8760], M::Vector{Int} = [1], T::Int = 0)
    model = complete_model(data[1:T], K, S, M)

    beta = value.(model[:beta])
    theta = value.(model[:theta])
    phi = value.(model[:phi])

    n_forecast = length(data) - T

    output = copy(data)
    n = length(beta) - 1
    m = length(S)

    for i in 1:n_forecast #T+1:length(data)
        AR = beta[1] + sum(beta[j+1]*output[T + i - K[j]] for j = 1:n)
        ST = sum(sum(theta[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*cos(2*pi*k*(T+i)/S[j]) + 
            phi[(j != 1 ? sum(M[l] for l = 1:j-1) : 0) + k]*sin(2*pi*k*(T+i)/S[j]) 
            for k in 1:M[j]) for j = 1:m)
        output[T+i] = AR + ST
    end

    return data, output, model
end