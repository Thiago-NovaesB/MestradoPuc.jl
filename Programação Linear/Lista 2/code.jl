using Pkg
# Pkg.activate("..\\..");
using JuMP;
using GLPK;
using CSV;
using DataFrames;

df = CSV.read("Programação Linear\\Lista 2\\WDBC.dat", DataFrame);
X_train = Array(df[1:400,3:end])
Y_train = Array(df[1:400,2]) .== "B"

X_test = Array(df[401:end,3:end])
Y_test = Array(df[401:end,2]) .== "B"

model = Model(GLPK.Optimizer)
@variable(model, z[i = 1:30])
@variable(model, σ[i = 1:400])

@constraint(model, 0 .<= X_train * z .<= 1)
@constraint(model, σ .>= X_train * z - Y_train)
@constraint(model, σ .>= Y_train - X_train * z)

@objective(model, Min, sum(σ))
optimize!(model)

z = value.(z)
true_positive = 0
true_negative = 0
false_positive = 0
false_negative = 0

for i in 1:length(Y_test)
    if Y_test[i] == 1 && sum(z[j]*X_test[i,j] for j in 1:30) < 0.5
        false_positive += 1
    elseif Y_test[i] == 1 && sum(z[j]*X_test[i,j] for j in 1:30) >= 0.5
        true_negative += 1
    elseif Y_test[i] == 0 && sum(z[j]*X_test[i,j] for j in 1:30) < 0.5
        true_positive += 1        
    else
        false_negative += 1
    end
end

@show true_positive
@show true_negative
@show false_positive
@show false_negative

function questao_2()
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
end

function questao_3(use_bat::Bool)
    n = 10
    C_def_1 = 50
    C_def_2 = 100
    G_bat = 8*use_bat
    T = 24
    d = 60*[1 + sin(t/12) for t in 1:T]
    c = [2*i for i in 1:n]

    model = Model(GLPK.Optimizer)
    @variable(model, 0.0 <= B[t = 1:T] <= G_bat)
    @variable(model, -G_bat <= b[t = 1:T] <= G_bat)
    @variable(model, 0.0 <= g[i = 1:n,t = 1:T] <= 22 - 2*i )
    @variable(model, 0.0 <= f[t = 1:T] <= d[t] )
    @variable(model, z[t = 1:T])

    @constraint(model,[t = 1:T], z[t] >= C_def_1 * f[t] )
    @constraint(model,[t = 1:T], z[t] >= C_def_2 * f[t]  + 0.05*d[t]*(C_def_2 - C_def_1))
    @constraint(model, [t = 2:T], B[t] - B[t-1] == - b[t])
    @constraint(model, B[1] - B[T] == - b[1])
    @constraint(model, [i = 1:n, t = 2:T], -i <= g[i,t] - g[i,t-1] <= i)
    @constraint(model, [i = 1:n], -i <= g[i,1] - g[i,24] <= i)
    @constraint(model, [t = 1:T], sum(g[i,t] for i in 1:n) + b[t] == d[t] - f[t])

    @objective(model, Min, sum(c[i]*g[i,t] for i = 1:n, t = 1:T) + sum(z))
    optimize!(model)
    return objective_value(model)
end