using CSV
using DataFrames
using Plots
using GLPK
using JuMP
using Statistics
using HiGHS

include("types.jl");
include("model.jl");

prb = Problem()

