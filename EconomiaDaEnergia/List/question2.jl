using HiGHS, JuMP, LinearAlgebra, Statistics, Printf

T = 3
C = [100,1000]
Gmax = [50,50]
Vmax = 200
V0 = 150
d = 150

a = 50
available_states = vcat([V0],
    repeat([[0,50,100,150]],T)
    )

FC = [Dict(available_states[t] .=> 0.0) for t in 1:T+1] # Initialize FCF structure
all_values = [zeros(length(available_states[t]), 6) for t in 1:T+1]

function subproblem(v_in, FC_t, t)
    N = length(available_states[t+1])
    values_fc = [FC_t[state] for state in available_states[t+1]]
    model = Model(HiGHS.Optimizer)

    @variable(model, 0 <= g[i = 1:2] <= Gmax[i])
    @variable(model, 0 <= v_out <= Vmax)
    @variable(model, 0 <= s)
    @variable(model, 0 <= u <= 150)
    @variable(model, 0 <= lambda[1:N] <= 1)

    @constraint(model, sum(g) + u == 150)
    @constraint(model, v_out + u + s == v_in + a)
    @constraint(model, sum(lambda.*available_states[t+1]) == v_out)
    @constraint(model, sum(lambda) == 1)

    @objective(model, Min, C'g + 1e-5s + sum(lambda.*values_fc;init=0))
    return model
end

function get_results(model::JuMP.Model)
    return [objective_value(model) JuMP.value(model[:g][1]) JuMP.value(model[:g][2]) JuMP.value(model[:u]) JuMP.value(model[:v_out])]
end

for t in T:-1:1
    for (idx,state) in enumerate(available_states[t])
        model = subproblem(state, FC[t+1],t)
        set_silent(model)
        optimize!(model)
        all_values[t][idx,:] = round.([state get_results(model)...])
        FCF_cost = objective_value(model)
        FC[t][state] = FCF_cost
    end
end

cabecalho = ["v_in" "obj" "g1" "g2" "u" "v_out"]
for t in 1:T
    println("\nFunção custo futuro período $t")
    @printf "%6s %6s %6s %5s %6s %6s\n" cabecalho...
    Base.print_matrix(stdout, all_values[t])
    println()
end