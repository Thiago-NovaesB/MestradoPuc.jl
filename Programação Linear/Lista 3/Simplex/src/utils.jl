function create(A::Matrix{}, b::Vector{}, c::Vector{},
                      base::Vector{Int}, nbase::Vector{Int}; tol::Float64 = 1E-6, max_iter::Int = 1000,
                      verbose::Int = 1)
        input = Simplex.Input(A,b,c,base,nbase,tol,max_iter,verbose)
    return input
end

function write_output(input::Input, termination_status::Int)

    A = input.A
    b = input.b
    c = input.c
    base = input.base
    nbase = input.nbase
    B = view(A,:,base)
    x = B \ b
    z = c[base]'x

    output = Simplex.Output(x, z, termination_status, base, nbase)
    return output
end