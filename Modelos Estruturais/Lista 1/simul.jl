using Pkg
using JuMP;
using Plots;
using Distributions
using Random

#a
function simul_a()
    a_1 = 0
    p_1 = 1
    mean = [0.,0.]
    C = [0.2 0; 0 0.3]
    L = 1000
    mu = zeros(L)
    y = zeros(L)

    d = Normal(a_1, p_1)
    mu[1] = rand(d, 1)[1]

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + x[2,1]
    for i in 1:L-1
        mu[i+1] = mu[i] + x[1,i+1]
        y[i+1] = mu[i] + x[2,i+1]
    end

    return y
end
function plot_a()
    p = plot(simul_a())
    plot!(simul_a())
    plot!(simul_a())
    plot!(simul_a())
    plot!(simul_a())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\a.png")
end

plot_a()

#e
function simul_e()
    mean = [0.,0., 0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.25]
    L = 1000
    mu = zeros(L)
    psi = zeros(L)
    y = zeros(L)
    beta = 0.05
    phi = 0.2
    theta = -0.5
    mu[1] = 1
    psi[1] = 0.9

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + psi[1] + x[3,1]
    for i in 1:L-1
        mu[i+1] = mu[i] + beta + x[1,i+1]
        psi[i+1] = phi*psi[i] + theta*x[2,i] + x[2,i+1]
        y[i+1] = mu[i] + psi[i] + x[3,i]
    end

    return y
end 
function plot_e()
    p = plot(simul_e())
    plot!(simul_e())
    plot!(simul_e())
    plot!(simul_e())
    plot!(simul_e())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\e.png")
end

plot_e()

#f
function simul_f()
    mean = [0.,0., 0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.25]
    L = 1000
    mu = zeros(L)
    psi = zeros(L)
    y = zeros(L)
    mu[1] = 1
    psi[1] = 0.9

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + psi[1] + x[3,1]
    for i in 1:L-1
        mu[i+1] = mu[i] + x[1,i+1]
        psi[i+1] = psi[i] + x[2,i+1]
        y[i+1] = mu[i] + psi[i] + x[3,i]
    end

    return y
end 
function plot_f()
    p = plot(simul_f())
    plot!(simul_f())
    plot!(simul_f())
    plot!(simul_f())
    plot!(simul_f())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\f.png")
end

plot_f()

#g
function simul_g()
    mean = [0.,0., 0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.25]
    L = 1000
    mu = zeros(L)
    beta = zeros(L)
    y = zeros(L)
    mu[1] = 1
    beta[1] = 0.9

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
        beta[i+1] = beta[i] + x[2,i+1]
        mu[i+1] = mu[i] + beta[i] + x[1,i+1]
        y[i+1] = mu[i] + x[3,i]
    end

    return y
end 
function plot_g()
    p = plot(simul_g())
    plot!(simul_g())
    plot!(simul_g())
    plot!(simul_g())
    plot!(simul_g())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\g.png")
end

plot_g()

#h
function simul_h()
    mean = [0.,0., 0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.25]
    L = 1000
    mu = zeros(L)
    beta = zeros(L)
    y = zeros(L)
    mu[1] = 1
    beta[1] = 0.9

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
        beta[i+1] = beta[i] + x[2,i+1]
        mu[i+1] = mu[i] + x[1,i+1]
        y[i+1] = mu[i] + x[3,i]
    end

    return y
end 
function plot_h()
    p = plot(simul_h())
    plot!(simul_h())
    plot!(simul_h())
    plot!(simul_h())
    plot!(simul_h())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\h.png")
end

plot_h()

#i
function simul_i()
    mean = [0.,0., 0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.25]
    L = 1000
    mu = zeros(L)
    beta = zeros(L)
    y = zeros(L)
    mu[1] = 1
    beta[1] = 0.9

    phi = 0.7
    gamma = -0.9

    d = MvNormal(mean, C)
    x = rand(d, L)
    y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
        beta[i+1] = gamma*beta[i] + x[2,i+1]
        mu[i+1] = phi*mu[i] + x[1,i+1]
        y[i+1] = mu[i] + x[3,i]
    end

    return y
end 
function plot_i()
    p = plot(simul_i())
    plot!(simul_i())
    plot!(simul_i())
    plot!(simul_i())
    plot!(simul_i())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\i.png")
end

plot_i()