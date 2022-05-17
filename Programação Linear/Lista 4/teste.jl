using JuMP, GLPK, LinearAlgebra
using Simplex
optimizer = () -> GLPK.Optimizer()

C_t = [35,70]
G_max = [150,150]
V_max = [150,150]
demand = 300
v0 = [40,50]

nhyd = length(V_max)
nter = length(G_max)
lenvars = [nhyd,nhyd,nter,nhyd];
n = sum(lenvars)
k = nhyd + 1 # Dimensão da incerteza + 1

# $X = [vols, ghs, gts, spills]$
var2X = Dict()
cumvars = cumsum(lenvars)
var2X["vols"] = 1:cumvars[1]
var2X["ghs"] = cumvars[1]+1:cumvars[2]
var2X["gts"] = cumvars[2]+1:cumvars[3]
var2X["s"] = cumvars[3]+1:cumvars[4]

A = []
# vol_i < 200
for vol in var2X["vols"]
    e = zeros(n)
    e[vol] += 1
    push!(A, e)
end
# 0 < vol_i 
for vol in var2X["vols"]
    e = zeros(n)
    e[vol] -= 1
    push!(A, e)
end
# 0 < gh_i
for gh in var2X["ghs"]
    e = zeros(n)
    e[gh] -= 1
    push!(A, e)
end
# gt_i < Gmax_i
for gt in var2X["gts"]
    e = zeros(n)
    e[gt] += 1
    push!(A, e)
end
# 0 < gt_i
for gt in var2X["gts"]
    e = zeros(n)
    e[gt] -= 1
    push!(A, e)
end
# 0 < s
for s in var2X["s"]
    e = zeros(n)
    e[s] -= 1
    push!(A, e)
end
# gt + gh == D
e = zeros(n)
e[vcat(var2X["ghs"],var2X["gts"])] .+= 1
push!(A, e)
e = zeros(n)
e[vcat(var2X["ghs"],var2X["gts"])] .-= 1
push!(A, e)
# vol = v0 - gh - s + omega
for hyd in 1:length(V_max)
    e = zeros(n)
    e[vcat(var2X["vols"][hyd],var2X["ghs"][hyd],var2X["s"][hyd])] .+= 1
    push!(A, e)
    e = zeros(n)
    e[vcat(var2X["vols"][hyd],var2X["ghs"][hyd],var2X["s"][hyd])] .-= 1
    push!(A, e)
end
A = Matrix(hcat(A...)')
m = size(A,1)

b = vcat([V_max, zeros(nhyd), zeros(nhyd), G_max, zeros(nter),zeros(nhyd), demand, -demand, collect(Iterators.flatten(zip(v0,-v0)))]...)
B = zeros(length(b),k)
B[:,1] = b
# Add inflows to B matrix
for idx_ω in 1:nhyd
    # Positive ineq
    idx_x = nhyd-idx_ω
    B[end-(idx_x+1)*nhyd+1,idx_ω+1] += 1
    # Negative ineq
    B[end-idx_x*nhyd,idx_ω+1] -= 1
end

ξ = ξ = [[1,10,10],[1,20,20]] #[[1,10,10],[1,20,10],[1,30,10],[1,10,20],[1,10,30],[1,20,20],[1,30,30]]
nscen = length(ξ)
P = ones(nscen).*1/nscen

b_(i) = B*ξ[i]
A_ξ = zeros(size(A).*nscen)
sizes = [size(A) .* i for i = 0:nscen]
for i in 1:length(sizes)-1
    A_ξ[sizes[i][1]+1:sizes[i+1][1],sizes[i][2]+1:sizes[i+1][2]] .= A
end
b_ξ = vcat([B*ξ[i] for i in eachindex(ξ)]...)
C = zeros(n)
C[var2X["gts"],1] = C_t
c_ξ = vcat([C*P[i] for i in eachindex(ξ)]...)

m = size(A_ξ,1)
A = [A_ξ I]
c = -vcat([c_ξ,zeros(m)]...);
b = b_ξ
input = Simplex.create(A, b, c)
output = Simplex.solve(input)


model_pl = Model(optimizer)
m = size(A,1)
n = size(A,2) - length(b)
@variable(model_pl, X[1:n + m] >= 0)
@constraint(model_pl, A*X .== b)
@objective(model_pl, Max, c'X)
@time optimize!(model_pl)
@show objective_value(model_pl)