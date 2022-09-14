function create(A::Matrix{}, b::Vector{}, c::Vector{},
                      base::Vector{Int}, nbase::Vector{Int}; tol::Float64 = 1E-6, max_iter::Int = 1000,
                      verbose::Int = 1)
        input = Simplex.Input(A,b,c,base,nbase,tol,max_iter,verbose)
    return input
end

function write_output(input::Input, termination_status::Int, d::Vector{})

    A = input.A
    b = input.b
    c = input.c
    base = input.base
    nbase = input.nbase
    B = view(A,:,base)
    x = B \ b
    z = c[base]'x

    x_opt = zeros(length(c))
    x_opt[base] = x
    if termination_status == 2
        output = Simplex.Output(d, Inf, termination_status, base, nbase)
        last_log(input, termination_status, base, nbase, z, d)
    else
        output = Simplex.Output(x_opt, z, termination_status, base, nbase)
        last_log(input, termination_status, base, nbase, z, x_opt)
    end
    return output
end