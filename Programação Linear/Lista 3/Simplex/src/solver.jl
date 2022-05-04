function solve(input::Simplex.Input)
    
    termination_status = 0 
    iter = 0
    max_iter = input.max_iter

    while termination_status == 0 && iter < max_iter
        termination_status, iter = Simplex.iterate(input, iter)
    end

    output = write_output(input, termination_status)

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
        return 1, iter #optimal
    end

    d = B \ N[:,j]

    d = max.(d, 0)

    r = xB ./ d

    val, i = findmin(r)

    if val == Inf
        return 2, iter #unbounded
    end

    base[i], nbase[j] = nbase[j], base[i] 
    return 0, iter #max iteration
end