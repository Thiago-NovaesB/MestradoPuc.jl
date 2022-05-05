function solve(input::Simplex.Input)
    
    termination_status = 0 
    iter = 0
    max_iter = input.max_iter
    d = []
    if input.verbose == 1
        init_log(input)
    end
    while termination_status == 0 && iter < max_iter
        termination_status, iter, d = Simplex.iterate(input, iter)
    end

    output = write_output(input, termination_status, d)

    return output
end

function iterate(input::Simplex.Input, iter::Int)

    iter += 1

    A = input.A
    b = input.b
    c = input.c
    base = input.base
    nbase = input.nbase
    tol = input.tol
    verbose = input.verbose

    B = view(A,:,base)
    N = view(A,:,nbase)

    xB = B \ b

    y = B' \ c[base]

    red_cost = c[nbase] - N'*y
    
    val, j = findmax(red_cost)

    if val <= tol
        return 1, iter, [] #optimal
    end

    d = zeros(length(c))

    d_base = B \ N[:,j]

    d[base] = - d_base
    d[nbase[j]] = 1

    d_base = max.(d_base, 0)

    r = xB ./ d_base

    val, i = findmin(r)

    if val == Inf
        return 2, iter, d #unbounded
    end
    z = c[base]'xB
    x_opt = zeros(length(c))
    x_opt[base] = xB
    if input.verbose == 1
        iteration_log(input, iter, base, nbase, base[i], nbase[j], z, x_opt, red_cost)
    end
    base[i], nbase[j] = nbase[j], base[i] 
    return 0, iter, d #max iteration
end