function create(A::Matrix{}, b::Vector{}, c::Vector{}
                ; rho::Float64 = 0.95, alpha::Float64 = 0.95, tol::Float64 = 1E-3, max_iter::Int = 100,
                verbose::Bool = true)
        n = length(c)
        m = length(b)
        input = Simplex.Input(A,b,c,n,m,rho,alpha,tol,max_iter,verbose)
    return input
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