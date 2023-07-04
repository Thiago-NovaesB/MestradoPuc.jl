using JuMP
using Ipopt
using LinearAlgebra
using Plots

r = [0.0068, 0.0098, 0.0095, -0.0126, 0.0255, 0.0102]
v = [0.0, 0.0068, 0.0084, 0.3449, 0.3916, 0.0369]

function pareto(theta)
    m = Model(Ipopt.Optimizer)
    set_silent(m)
    @variable(m, x[1:6] >= 0)
    @expression(m, E, r'x)
    @expression(m, R, x'diagm(v.^2)x)
    @constraint(m, sum(x)<=5000)
    @objective(m, Min, -E*theta+R*(1-theta))
    optimize!(m)
    return value(E), value(R)
end

function pareto2(theta)
    m = Model(Ipopt.Optimizer)
    set_silent(m)
    @variable(m, x[1:6] >= 0)
    @expression(m, E, r'x)
    @expression(m, R, x'diagm(v.^2)x)
    @constraint(m, sum(x)<=5000)
    @objective(m, Min, -E*theta+R*(1-theta))
    optimize!(m)
    return value.(x)
end

x = []
y = []
thetas = []
for i in range(-5, 0, length=10000)
    append!(thetas, 10^i)
end

for theta in thetas
    @show theta
    E, R = pareto(theta)
    append!(x, R)
    append!(y, E)
end

plt = plot(x, y, title="Pareto curve", label="Pareto", legend=false)
xlabel!("risk")
ylabel!("return")

savefig(plt, "test.png")

thetas = []
for i in 1:10
    append!(thetas, i/10)
end

for theta in thetas
    @show pareto2(theta)
end
