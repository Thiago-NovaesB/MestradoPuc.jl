function solve(input::Simplex.Input)
    n = input.n
    m = input.m
    rho = input.rho
    alpha = input.alpha
    A = input.A
    b = input.b
    c = input.c

    nx = (1:n)
    np = (n+1:m+n)
    ns = (m+n+2:m+2n)

    x = ones(n)
    s = ones(n)
    p = ones(m)

    while true
        mu = rho*x'*s/n

        F = [A zeros(m,m) zeros(n,n);
            zeros(n,m) A' I(n);
            Diagonal(s) zeros(n,m) Diagonal(x)]

        g = [A*x - b; A'p + s + c; x.*s .-mu]

        d = - F \ g
        @show d

        d_x = d[nx]
        d_p = d[np]
        d_s = d[ns]

        beta_x = min(1.0, alpha*minimum(max.(0.0, -x/d_x)))
        beta_p = min(1.0, alpha*minimum(max.(0.0, -p/d_p)))
        beta_s = min(1.0, alpha*minimum(max.(0.0, -s/d_s)))

        x += beta_x * d_x
        p += beta_p * d_s
        s += beta_s * d_p

    end
end

function iterate(input::Simplex.Input, midterm::Simplex.MidTerm)

    midterm.iter += 1
    A = input.A
    b = input.b
    c = input.c
    base = midterm.base
    nbase = midterm.nbase
    tol = input.tol
    B = view(A,:,base)
    N = view(A,:,nbase)
    xB = B \ b
    y = B' \ c[base]
    midterm.red_cost = c[nbase] - N'*y
    val = maximum(midterm.red_cost)
    
    if val <= tol
        midterm.termination_status = 1
        return midterm #optimal
    end
    midterm.j = findfirst(x->x>tol,midterm.red_cost)

    d = zeros(length(c))
    d_base = B \ N[:,midterm.j]
    d[base] = - d_base
    d[nbase[midterm.j]] = 1
    midterm.d = d
    d_base = max.(d_base, 0)
    r = max.(xB, tol) ./ d_base
    val, midterm.i = findmin(r)
    
    if val == Inf
        midterm.termination_status = 2
        return midterm #unbounded
    end
    midterm.z = c[base]'xB
    midterm.x = zeros(input.n)
    midterm.x[base] = xB
    iteration_log(input, midterm)
    base[midterm.i], nbase[midterm.j] = nbase[midterm.j], base[midterm.i] 
    return midterm #max iteration
end