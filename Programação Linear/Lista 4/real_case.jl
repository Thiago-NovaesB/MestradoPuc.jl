using JuMP, GLPK, LinearAlgebra, Random
using Simplex
using BenchmarkTools, BenchmarkPlots, StatsPlots
Random.seed!(12)
optimizer = () -> GLPK.Optimizer()

p = 30
k = 10

e_p = rand(1:5,p)
cc_p = rand(1:9,p)
oc_p = rand(1:2,p)
ic_k = rand(1:30,k)
dd_k = rand(1:5,k)
du_k = rand(1:1,k)
r_k = [dd_k[i]*du_k[i] for i in 1:k]

lenvars = [p, p*k, k];
n = sum(lenvars)

# $X = [x_p, y_pk, z_p]$
var2X = Dict()
cumvars = cumsum(lenvars)
var2X["x_p"] = 1:cumvars[1]
var2X["y_pk"] = cumvars[1]+1:cumvars[2]
var2X["z_p"] = cumvars[2]+1:cumvars[3]

I_pp = Matrix(I,p,p)
I_kk = Matrix(I,k,k)

Z_pk = zeros(p,k)
Z_kp = zeros(k,p)

D = zeros(p,p*k)
for i in 1:p
    D[i,1+(i-1)*k:i*k] .= 1
end

E = zeros(k,p*k)
for i in 1:p
    E[:,1+(i-1)*k:i*k] = I_kk
end

A = [-I_pp D Z_pk; Z_kp E I_kk; Z_kp -E -I_kk]

b = vcat(e_p, r_k, -r_k)

c_y = zeros(p*k)

for i in 1:p, j in 1:k
    c_y[(i-1)*k+j] = du_k[j]*oc_p[i] 
end

c = -[cc_p' c_y' ic_k']

m = p+2*k

A = [A Matrix(I,m,m)]
c = vcat(c',zeros(m))

input = Simplex.create(A, b, c)
output = Simplex.solve(input)

# function reset_solver!(A, b, c)
    model_pl = Model(optimizer);
    m = size(A,1);
    n = size(A,2) - length(b);
    @variable(model_pl, X[1:n + m] >= 0);
    @constraint(model_pl, A*X .== b);
    @objective(model_pl, Max, c'X);
    optimize!(model_pl);
    @show objective_value(model_pl)
    @show output.z
# end

# bench2 = @benchmark reset_solver!($A, $b, $c)

# plot(bench1,yaxis=:log10,st=:box)
# plot!(bench2,yaxis=:log10,st=:box,xticks=(1:2,[" Simplex" "GLPK"]))