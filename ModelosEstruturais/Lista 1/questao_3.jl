using Pkg
using JuMP;
using Plots;
using Distributions
using Random

#l
function simul_3()
    sigma2epsilon = 0.1
    sigma2eta = 0.2
    sigma2zeta = 0.3
    sigma2omegas = 0.1
    sigma2omegaa = 0.25

    L = 1000

    d = Normal(0, sigma2epsilon)
    epsilon = rand(d, L)
    d = Normal(0, sigma2eta)
    eta = rand(d, L)
    d = Normal(0, sigma2zeta)
    zeta = rand(d, L)
    d = Normal(0, sigma2omegas)
    omegaS1 = rand(d, L)
    d = Normal(0, sigma2omegas)
    omegaS2 = rand(d, L)
    d = Normal(0, sigma2omegaa)
    omegaA1 = rand(d, L)
    d = Normal(0, sigma2omegaa)
    omegaA2 = rand(d, L)

    mu = zeros(L)
    beta = zeros(L)
    y = zeros(L)
    mu[1] = 1
    beta[1] = 0.5

    gammaS1 = zeros(L, 3)
    gammaS2 = zeros(L, 3)
    gammaA1 = zeros(L, 182)
    gammaA2 = zeros(L, 182)

    for i in 1:L-1
        beta[i+1] = beta[i] + zeta[i] 
        mu[i+1] = mu[i] + beta[i] + eta[i] 
        for j = 1:3
            gammaS1[i+1,j] = cos(2*pi/3)*gammaS1[i,j] + sin(2*pi/3)*gammaS2[i,j] + omegaS1[i]
            gammaS2[i+1,j] = -sin(2*pi/3)*gammaS1[i,j] + cos(2*pi/3)*gammaS2[i,j] + omegaS2[i]
        end
        for j = 1:182
            gammaA1[i+1,j] = cos(2*pi/182)*gammaA1[i,j] + sin(2*pi/182)*gammaA2[i,j] + omegaA1[i]
            gammaA2[i+1,j] = -sin(2*pi/182)*gammaA1[i,j] + cos(2*pi/182)*gammaA2[i,j] + omegaA2[i]
        end
        y[i] = mu[i] + sum(gammaS1[i,:]) + sum(gammaA1[i,:]) + epsilon[i]
    end

    return y
end 
function plot_3()
    p = plot(simul_3())
    plot!(simul_3())
    plot!(simul_3())
    plot!(simul_3())
    plot!(simul_3())
    savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\3.png")
end

plot_3()