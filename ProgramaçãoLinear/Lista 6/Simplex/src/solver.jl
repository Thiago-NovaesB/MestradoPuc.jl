function solve(input::Simplex.Input)

    init_log(input)
    n = input.n
    m = input.m
    rho = input.rho
    alpha = input.alpha
    A = input.A
    b = input.b
    c = input.c

    nx = (1:n)
    np = (n+1:m+n)
    ns = (m+n+1:m+2n)

    x = ones(n)
    s = ones(n)
    p = ones(m)
    mu = rho*x'*s/n

    for iter in 1:input.max_iter

        F = [A zeros(m,m) zeros(m,n);
            zeros(n,n) A' I(n);
            Diagonal(s) zeros(n,m) Diagonal(x)]

        g = [A*x - b; A'p + s + c; x.*s .- mu]

        d = - F \ g

        d_x = d[nx]
        d_p = d[np]
        d_s = d[ns]

        filter_x = d_x .< 0.0
        filter_p = d_p .< 0.0
        filter_s = d_s .< 0.0

        if sum(filter_x) == 0
            output = Output(x,s,p,mu,-Inf,2,iter)
            last_log(input, output)
            return output
        end 
        
        if sum(filter_s) == 0
            output = Output(x,s,p,mu,Inf,3,iter)
            last_log(input, output)
            return output
        end

        beta_x = min(1.0, alpha*minimum((-x./d_x)[filter_x]))
        beta_p = min(1.0, alpha*minimum((-p./d_p)[filter_p]))
        beta_s = min(1.0, alpha*minimum((-s./d_s)[filter_s]))

        x += beta_x * d_x
        p += beta_p * d_p
        s += beta_s * d_s
        z = c'x
        dual_inf = x'*s/n

        iteration_log(input,iter,z,dual_inf)
        mu = rho*dual_inf
        if mu < input.tol
            output = Output(x,s,p,mu,z,1,iter)
            last_log(input, output)
            return output
        end
    end
    z = c'x
    output = Output(x,s,p,mu,z,0,input.max_iter)
    last_log(input, output)
    return output
end