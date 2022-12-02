using HiGHS, JuMP

T = 3
C = [100,1000]
G = [50,50]
V = 200
v_0 = 150
u_max = 150
inflow = 50
states = [[v_0]]
for _ in 1:T
   push!(states, [0,50,100,150]) 
end
FC = [Dict(states[t] .=> 0.0) for t in 1:T+1]

function subproblem(v_in, FC_t, t)
    values_fc = [FC_t[state] for state in states[t+1]]
    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, 0 <= v_out <= V)
    @variable(model, 0 <= u <= 150)
    @variable(model, 0 <= s <= v_in + 150)
    @variable(model, 0 <= g[i = 1:2] <= G[i])
    @variable(model, lambda[1:4], Bin)

    @constraint(model, sum(g) + u == 150)
    @constraint(model, v_out - v_in == inflow - u - s)
    @constraint(model, sum(lambda.*states[t+1]) == v_out)
    @constraint(model, sum(lambda) == 1)

    @objective(model, Min, sum(C.*g) + sum(lambda.*values_fc) + 1e-5s)
    optimize!(model)
    return model
end

for t in T:-1:1
    for (idx,state) in enumerate(states[t])
        model = subproblem(state, FC[t+1], t)
        set_silent(model)
        optimize!(model)
        FC[t][state] = objective_value(model)
    end
end