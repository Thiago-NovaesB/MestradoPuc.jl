module Kalman

using JuMP, Ipopt, LinearAlgebra, MKL
using Ipopt
using LinearAlgebra
using MKL

include("types.jl")
include("load_data.jl")
include("filter.jl")

export create_filter

end # module
