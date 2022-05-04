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

#b
function simul_b()
    phi = [0.1, -0.1, 0.1]
    theta = [0.1, -0.2, 0.3, -0.4]
    c = 8
    L = 1000
    y = zeros(L)

    d = Normal(0, 0.1)
    x = rand(d, L*2)

    y[1] = 8 
    y[2] = 8.1
    y[3] = 8
    for i in 4:L
        y[i] = c + phi[1]*y[i-1]+ phi[2]*y[i-2] + phi[3]*y[i-3]
        + theta[1]*x[i+3] + theta[2]*x[i+2] + theta[2]*x[i+1] + theta[2]*x[i] + x[i+4]
    end

    return y
end
function plot_b()
    p = plot(simul_b())
    plot!(simul_b())
    plot!(simul_b())
    plot!(simul_b())
    plot!(simul_b())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\b.png")
end

plot_b()

#c
function simul_c()
    phi = [0.1, -0.1, 0.1]
    theta = [0.1, -0.2, 0.3, -0.4]
    c = 8
    L = 1000
    y = zeros(L)

    d = Normal(0, 0.1)
    x = rand(d, L*2)

    y[1] = 8 
    y[2] = 8.1
    y[3] = 8
    for i in 4:L
        y[i] = c + (1+phi[1])*y[i-1]+ (phi[2]-phi[2])*y[i-2] - phi[3]*y[i-3]
        + theta[1]*x[i-1] + x[i]
    end

    return y
end
function plot_c()
    p = plot(simul_c())
    plot!(simul_c())
    plot!(simul_c())
    plot!(simul_c())
    plot!(simul_c())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\c.png")
end

plot_c()

#d
function simul_d()
    mean = [0.,0.]
    C = [0.2 0;0 0.1]
    L = 1000
    phi = zeros(L)
    y = zeros(L)
    beta = 0.05
    alpha = 0.2
    phi[1] = 1
    y[1] = 1

    d = MvNormal(mean, C)
    x = rand(d, L)
    for i in 1:L-1
        phi[i+1] = beta + alpha*phi[i] + beta + x[1,i+1]
        y[i+1] = phi[i]*y[i] + x[2,i]
    end

    return y
end
function plot_d()
    p = plot(simul_d())
    plot!(simul_d())
    plot!(simul_d())
    plot!(simul_d())
    plot!(simul_d())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\d.png")
end

plot_d()

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

#j
function simul_j()
    mean = [0.,0.]
    C = [0.2 0;0 0.3]
    L = 1000
    mu = zeros(L)
    epsilon = zeros(L)
    y = zeros(L)
    mu[1] = 1

    phi = 0.7

    d = MvNormal(mean, C)
    x = rand(d, L*2)
    # y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
        epsilon[i+1] = phi*x[2,i] + x[2,i+1]
        mu[i+1] = mu[i] + x[1,i+1]
        y[i+1] = mu[i] + epsilon[i]
    end

    return y
end 
function plot_j()
    p = plot(simul_j())
    plot!(simul_j())
    plot!(simul_j())
    plot!(simul_j())
    plot!(simul_j())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\j.png")
end

plot_j()

#k
function simul_k()
    mean = [0.,0.]
    C = [0.2 0;0 0.3]
    L = 1000
    mu = zeros(L)
    epsilon = zeros(L)
    y = zeros(L)
    mu[1] = 1

    phi = 0.7

    d = MvNormal(mean, C)
    x = rand(d, L*2)
    # y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
        epsilon[i+1] = phi*epsilon[i] + x[2,i+1]
        mu[i+1] = mu[i] + x[1,i+1]
        y[i+1] = mu[i] + epsilon[i]
    end

    return y
end 
function plot_k()
    p = plot(simul_k())
    plot!(simul_k())
    plot!(simul_k())
    plot!(simul_k())
    plot!(simul_k())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\k.png")
end

plot_k()

#l
function simul_l()
    mean = [0.,0.,0.]
    C = [0.2 0 0;0 0.3 0;0 0 0.1]
    L = 1000
    mu = zeros(L)
    beta = zeros(L+2)
    y = zeros(L)
    mu[1] = 1
    beta[1] = 0.5
    beta[2] = 0.7
    beta[3] = 0.7

    phi = 0.7

    d = MvNormal(mean, C)
    x = rand(d, L*2)
    # y[1] = mu[1] + beta[1] + x[3,1]
    for i in 1:L-1
    beta[2] = 0.7
        beta[i+3] = 3phi*beta[i+2] - 3phi^2*beta[i+1] + phi^3*beta[i] + x[1,i]
        mu[i+1] = mu[i] + beta[i+3] + x[2,i]
        y[i+1] = mu[i+1] + x[3,i]
    end

    return y
end 
function plot_l()
    p = plot(simul_l())
    plot!(simul_l())
    plot!(simul_l())
    plot!(simul_l())
    plot!(simul_l())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\l.png")
end

plot_l()