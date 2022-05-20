function create(A::Matrix{}, b::Vector{}, c::Vector{}
                ; tol::Float64 = 1E-3, max_iter::Int = 100,
                verbose::Bool = true)
        n = length(c)
        m = length(b)
        input = Simplex.Input(A,b,c,n,m,tol,max_iter,verbose)
    return input
end

function update_midterm!(input::Input, midterm::MidTerm)
    A = input.A
    b = input.b
    c = input.c
    base = midterm.base
    B = view(A,:,base)
    x = B \ b
    midterm.z = c[base]'x

    x_opt = zeros(input.n)
    x_opt[base] = x

    midterm.x = x_opt
    nothing
end

function write_output(input::Input, midterm::MidTerm)

    if midterm.termination_status == 2
        output = Simplex.Output(midterm.d, Inf, midterm.termination_status, midterm.base, midterm.nbase)
        last_log(input, output)
    elseif midterm.termination_status == 1
        output = Simplex.Output(midterm.x, midterm.z, midterm.termination_status, midterm.base, midterm.nbase)
        last_log(input, output)
    elseif midterm.termination_status == 3
        output = Simplex.Output(midterm.x, midterm.z, midterm.termination_status, midterm.base, midterm.nbase)
        last_log(input, output)
    elseif midterm.termination_status == 0
        output = Simplex.Output(midterm.x, midterm.z, midterm.termination_status, midterm.base, midterm.nbase)
        last_log(input, output)
    end
    return output
end