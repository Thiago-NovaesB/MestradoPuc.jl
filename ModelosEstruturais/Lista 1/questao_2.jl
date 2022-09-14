using Pkg
using JuMP;
using Plots;
using Distributions
using Random
using StatsBase

function create_serie()
    serie = zeros(120).+7
    d = Normal(0.0, 0.3)
    for t in 1:120
        serie[t] += cos(2*pi*t/12 + 6) + rand(d, 1)[1]
    end
    return serie
end

function create_dummy()
    A = zeros(120, 12)

    A[:,1] .= 1

    for i in 1:120
        col = mod(i,12)
        if col != 0
            A[i,col+1] = 1
        end
    end
    return A
end

function create_trig()
    A = zeros(120, 12)

    A[:,1] .= 1

    for t in 1:120, i = 2:12
        use_cos = (mod(i,2) == 0)

        j = (use_cos ? i/2 : i/2 - 0.5) 
        if use_cos
            A[t,i] = cos(pi/6*j*t)
        else
            A[t,i] = sin(pi/6*j*t)
        end
    end
    return A
end

function solve_MQO(A,b)
    x = A'A \ A'b
    return x
end

b = create_serie()
Ad = create_dummy()
At = create_trig()
xd = solve_MQO(Ad,b)
xt = solve_MQO(At,b)

yd = Ad*xd
yt = At*xt

minimum(isapprox.(yd,yt))

p = plot(autocov(yd - b))

savefig(p,"Modelos Estruturais\\Lista 1\\imagens\\FAC.png")