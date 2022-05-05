function solve(input::Simplex.Input)
    
    termination_status = 0 
    iter = 0
    max_iter = input.max_iter
    d = []
    init_log(input)
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
    iteration_log(input, iter, base, nbase, base[i], nbase[j], z, x_opt, red_cost)
    base[i], nbase[j] = nbase[j], base[i] 
    return 0, iter, d #max iteration
end