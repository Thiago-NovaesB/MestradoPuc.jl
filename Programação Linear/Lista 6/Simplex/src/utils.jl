function create(A::Matrix{}, b::Vector{}, c::Vector{}
                ; rho::Float64 = 0.95, alpha::Float64 = 0.95, tol::Float64 = 1E-3, max_iter::Int = 1000,
                verbose::Bool = true)
        n = length(c)
        m = length(b)
        input = Simplex.Input(A,b,c,n,m,rho,alpha,tol,max_iter,verbose)
    return input
end