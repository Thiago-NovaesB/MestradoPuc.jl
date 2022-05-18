function solve(input::Simplex.Input)

    midterm = MidTerm()
    if check_phase_1(input)
        midterm.base =  collect((input.n - input.m + 1):input.n)
        midterm.nbase = collect(1:(input.n-input.m))
        val, i = findmin(input.b)

        aux = midterm.base[i]
        push!(midterm.nbase, aux)
        midterm.base[i] = input.n + 1
        c_mem = copy(input.c)
        input.A = [input.A -ones(input.m)] #hcat(input.A,-ones(input.m)) 
        input.c = zeros(input.n + 1)
        input.c[end] = -1
        input.n = input.n + 1

        init_log1(input)
        while midterm.termination_status == 0 && midterm.iter < input.max_iter
            midterm = Simplex.iterate(input, midterm)
        end
        update_midterm!(input, midterm)
        if midterm.z < -input.tol
            midterm.termination_status = 3 #infeasible
            output = write_output(input, midterm)
            return output
        end
        midterm.iter = 0
        input.n = input.n - 1
        cache = findfirst(x->x==input.n + 1,midterm.nbase)
        input.c = c_mem
        input.A = input.A[:,1:input.n]
        midterm.termination_status = 0
        # if cache !== nothing
        #     deleteat!(midterm.nbase, cache)
        # else
        #     deleteat!(midterm.base, findfirst(x->x==input.n + 1,midterm.base))
        #     push!(midterm.base, midterm.nbase[1])
        #     deleteat!(midterm.nbase, 1)
        # end
        if cache !== nothing
            deleteat!(midterm.nbase, cache)
        else
            deleteat!(midterm.base, findfirst(x->x==input.n + 1,midterm.base))
            for (k,w) in enumerate(midterm.nbase)
                sol = input.A[:,midterm.base] \ input.A[:,w]
                if maximum(abs.(input.A[:,midterm.base]*sol-input.A[:,w])) > input.tol
                    push!(midterm.base, w)
                    deleteat!(midterm.nbase, k)
                    break
                end
            end
        end
    else
        midterm.base =  collect((input.n - input.m + 1):input.n)
        midterm.nbase = collect(1:(input.n-input.m))
    end
    
    
    init_log2(input)
    while midterm.termination_status == 0 && midterm.iter < input.max_iter
        midterm = Simplex.iterate(input, midterm)
    end
    update_midterm!(input, midterm)
    output = write_output(input, midterm)
    return output
end

function check_phase_1(input::Simplex.Input)
    b_min = minimum(input.b)
    return b_min < 0 
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
    # place = minimum(nbase[val .== midterm.red_cost])
    # midterm.j = findfirst(nbase .== place)

    if val <= tol
        midterm.termination_status = 1
        return midterm #optimal
    end
    midterm.j = findfirst(x->x>tol,midterm.red_cost)::Int64

    d = zeros(length(c))
    d_base = B \ N[:,midterm.j]
    d[base] = - d_base
    d[nbase[midterm.j]] = 1
    midterm.d = d
    d_base = max.(d_base, 0)
    r = max.(xB, tol) ./ d_base
    val = minimum(r)
    # place = minimum(base[val .== r])
    # midterm.i = findfirst(base .== place)
    midterm.i = argmin(r)
    
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