using Pkg
# Pkg.activate("..\\..");
using JuMP;
using GLPK;

g_max = [5.0, 20.0, 12.0]
f_max = [20.0, 20.0, 5.0]
f_c1_max = [0.0, 20.0, 5.0]
f_c2_max = [20.0, 0.0, 5.0]
f_c3_max = [20.0, 20.0, 0.0]
c = [100.0, 150.0, 200.0]
c_d = 5000
d = 15

model = Model(GLPK.Optimizer)
@variable(model, 0.0 <= g[i = 1:3] <= g_max[i])
@variable(model, 0.0 <= g_d)
@variable(model, -f_max[i] <= f[i = 1:3] <= f_max[i])
# @variable(model, -f_c1_max[i] <= f_c1[i = 1:3] <= f_c1_max[i])
# @variable(model, -f_c2_max[i] <= f_c2[i = 1:3] <= f_c2_max[i])
# @variable(model, -f_c3_max[i] <= f_c3[i = 1:3] <= f_c3_max[i])

@constraint(model, g[1] + f[1] - f[3] == 0.0)
@constraint(model, g[2] + f[2] - f[1] == 0.0)
@constraint(model, g[3] + f[3] - f[2] + g_d == d)
# @constraint(model, g[1] - f_c1[3] == 0.0)
# @constraint(model, g[2] + f_c1[2] == 0.0)
# @constraint(model, g[1] + f_c3[1] == 0.0)
# @constraint(model, g[3] - f_c3[2] + g_d == d)
# @constraint(model, g[2] - f_c2[1] == 0.0)
# @constraint(model, g[3] + f_c2[3] + g_d == d)

@objective(model, Min, sum(c[i]*g[i] for i = 1:3) + c_d*g_d)
optimize!(model)