data = Trilevel.Data()

data.Gmax = [100, 20, 100]
data.C = [100, 150, 1000]
data.Fmax = [100,20,100,100,20,100]
data.demand = [0, 0, 100]
data.def = [0, 10, 0]
data.nter = 3
data.nlin = 6
data.nbus = 3
data.ter2bus = [1, 2, 3]
data.A = [-1 -1 0 -1 -1 0;
          0 1 -1 0 1 -1;
          1 0 1 1 0 1]
data.expG = [10, 10, 0]
data.contg = [1, 1, 1]
data.expL = [1, 1, 1, 1, 1, 1]
data.contl = [1, 1, 1, 1, 1, 1]

function g(data)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, 0 <= g[i=1:data.nter])
    @variable(model, f[1:data.nlin])

    @constraint(model, BALANCE[b = 1:data.nbus], sum(g[t] for t in 1:data.nter if data.ter2bus[t] == b) + sum(f[c] * data.A[b, c] for c in 1:data.nlin) == data.demand[b] + data.def[b])
    @constraint(model, GLIMIT[t = 1:data.nter], g[t] <= (data.Gmax[t] + data.expG[t])*data.contg[t])

    @constraint(model, FLIMIT1[i = 1:data.nlin], f[i] <= data.Fmax[i]*data.expL[i]*data.contl[i])
    @constraint(model, FLIMIT2[i = 1:data.nlin], f[i] >= -data.Fmax[i]*data.expL[i]*data.contl[i])

    @objective(model, Min, sum(data.C.*g))
    optimize!(model)
    @show objective_value(model)
    @show value.(g)
    @show value.(f)
    @show dual.(BALANCE)
    @show dual.(GLIMIT)
    @show dual.(FLIMIT1)
    @show dual.(FLIMIT2)
    return model
end


function gD(data)
    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, lambda1[1:3])
    @variable(model, lambda2[1:2] <= 0)
    @variable(model, lambda3[1:6] <= 0)
    @variable(model, lambda4[1:6] >= 0)

    @constraint(model, g[1:data.nter], 
    g1,  lambda1[1]                            + lambda2[1]              <= C[1]
    g2,              + lambda1[2]              + lambda2[2]              <= C[2]
    g3,                           + lambda1[3]                           <= C[3]
    f1, - lambda1[1]              + lambda1[3] + lambda3[1] + lambda4[1] == 0
    f2, - lambda1[1] + lambda1[2]              + lambda3[2] + lambda4[2] == 0
    f3,              - lambda1[2] + lambda1[3] + lambda3[3] + lambda4[3] == 0
    f4, - lambda1[1] +            + lambda1[3] + lambda3[4] + lambda4[4] == 0
    f5, - lambda1[1] + lambda1[2]              + lambda3[5] + lambda4[5] == 0
    f6,              - lambda1[2] + lambda1[3] + lambda3[6] + lambda4[6] == 0
    end)

    @objective(model, Max, lambda1[1]*u[10] + lambda1[2]*u[11] + lambda1[3]*(D+u[9]) +
                           lambda2[1]*(Gmax[1] + x[1])*u[7] + lambda2[2]*(Gmax[2] + x[2])*u[8] +
                           sum(lambda3[i]*Fmax[i]*u[i] for i = 1:3) + sum(lambda3[i]*Fmax[i]*x[i-1]*u[i] for i = 4:6) -
                           sum(lambda4[i]*Fmax[i]*u[i] for i = 1:3) - sum(lambda4[i]*Fmax[i]*x[i-1]*u[i] for i = 4:6)
                           )
    g = [g1,g2,g3]
    f = [f1,f2,f3,f4,f5,f6]
    @time optimize!(model)
    @show objective_value(model)
    @show value.(lambda1)
    @show value.(lambda2)
    @show value.(lambda3)
    @show value.(lambda4)
    @show dual.(g)
    @show dual.(f)
    return model
end

# function oracle_non_linear(x,k_line,k_generator,max_extra_demand)
#     model = Model(HiGHS.Optimizer)
#     # set_optimizer_attribute(model, "NonConvex", 2)
#     # set_optimizer_attribute(model, "Presolve", 0)
#     # set_silent(model)

#     @variables(model, begin
#         lambda1[1:3]
#         lambda2[1:2] <= 0
#         lambda3[1:6] <= 0
#         lambda4[1:6] >= 0
#     end)

#     @variable(model, u[1:11] >= 0)
#     @constraint(model, u[1:8] .∈ MOI.ZeroOne())
#     # N - k contigency for lines
#     @constraint(model, sum(u[i] for i = 1:6) >= 6 - k_line)
#     # N - k contigency for generators
#     @constraint(model, sum(u[i] for i = 7:8) >= 2 - k_generator)
#     # Maximum extra demand
#     # Added all extra demand in the bar that has deficit
#     # otherwise, it wont converge
#     @constraint(model, u[9] ≤ max_extra_demand)
#     @constraint(model, u[10] == 0)
#     @constraint(model, u[11] == 0)

#     # @variables(model, begin
#     #     z1[1:3,1:11]
#     #     z2[1:2,1:11] <= 0
#     #     z3[1:6,1:11] <= 0
#     #     z4[1:6,1:11] >= 0
#     # end)

#     @constraints(model, begin
#     g1,  lambda1[1]                            + lambda2[1]              <= C[1]
#     g2,              + lambda1[2]              + lambda2[2]              <= C[2]
#     g3,                           + lambda1[3]                           <= C[3]
#     f1, - lambda1[1]              + lambda1[3] + lambda3[1] + lambda4[1] == 0
#     f2, - lambda1[1] + lambda1[2]              + lambda3[2] + lambda4[2] == 0
#     f3,              - lambda1[2] + lambda1[3] + lambda3[3] + lambda4[3] == 0
#     f4, - lambda1[1] +            + lambda1[3] + lambda3[4] + lambda4[4] == 0
#     f5, - lambda1[1] + lambda1[2]              + lambda3[5] + lambda4[5] == 0
#     f6,              - lambda1[2] + lambda1[3] + lambda3[6] + lambda4[6] == 0
#     end)

#     @objective(model, Max, lambda1[1]*u[10] + lambda1[2]*u[11] + lambda1[3]*(D+u[9]) +
#                            lambda2[1]*(Gmax[1] + x[1])*u[7] + lambda2[2]*(Gmax[2] + x[2])*u[8] +
#                            sum(lambda3[i]*Fmax[i]*u[i] for i = 1:3) + sum(lambda3[i]*Fmax[i]*x[i-1]*u[i] for i = 4:6) -
#                            sum(lambda4[i]*Fmax[i]*u[i] for i = 1:3) - sum(lambda4[i]*Fmax[i]*x[i-1]*u[i] for i = 4:6)
#                            )
#     g = [g1,g2,g3]
#     f = [f1,f2,f3,f4,f5,f6]
#     @expression(model, b_alpha,
#         [lambda2[1]*u[7], 
#         lambda2[2]*u[8],
#         [lambda3[i]*Fmax[i]*u[i] for i = 4:6]...])
#     @time optimize!(model)
#     @show objective_value(model)
#     @show value.(lambda1)
#     @show value.(lambda2)
#     @show value.(lambda3)
#     @show value.(lambda4)
#     @show value.(u)
#     # @show dual.(g)
#     # @show dual.(f)
#     @show termination_status(model)
#     return objective_value(model), value.(b_alpha)
# end

# function oracle_linearized(x,k_line,k_generator,max_extra_demand)
#     M = maximum(C)
#     model = Model(HiGHS.Optimizer)
#     # set_optimizer_attribute(model, "NonConvex", 2)
#     # set_optimizer_attribute(model, "Presolve", 0)
#     set_silent(model)

#     @variables(model, begin
#         lambda1[1:3]
#         lambda2[1:2] <= 0
#         lambda3[1:6] <= 0
#         lambda4[1:6] >= 0
#     end)

#     @variable(model, u[1:11] >= 0)
#     @constraint(model, u[1:8] .∈ MOI.ZeroOne())
#     # N - k contigency for lines
#     @constraint(model, sum(u[i] for i = 1:6) >= 6 - k_line)
#     # N - k contigency for generators
#     @constraint(model, sum(u[i] for i = 7:8) >= 2 - k_generator)
#     # Maximum extra demand
#     # Added all extra demand in the bar that has deficit
#     # otherwise, it wont converge
#     @constraint(model, u[9] ≤ max_extra_demand)
#     @constraint(model, u[10] == 0)
#     @constraint(model, u[11] == 0)

#     @variables(model, begin
#         z1[1:3,1:11]
#         z2[1:2,1:11] <= 0
#         z3[1:6,1:11] <= 0
#         z4[1:6,1:11] >= 0
#     end)

#     @constraints(model, begin
#         [i = 1:2, j=7:8], z2[i,j] - lambda2[i] <= (1-u[j])*M
#         [i = 1:2, j=7:8], -(1-u[j])*M <= z2[i,j] - lambda2[i]
#         [i = 1:2, j=7:8], z2[i,j] <= u[j]*M
#         [i = 1:2, j=7:8], -u[j]*M <= z2[i,j]
#     end)
#     @constraints(model, begin
#         [i = 1:6, j=1:6], z3[i,j] - lambda3[i] <= (1-u[j])*M
#         [i = 1:6, j=1:6], -(1-u[j])*M <= z3[i,j] - lambda3[i]
#         [i = 1:6, j=1:6], z3[i,j] <= u[j]*M
#         [i = 1:6, j=1:6], -u[j]*M <= z3[i,j]
#     end)
#     @constraints(model, begin
#         [i = 1:6, j=1:6], z4[i,j] - lambda4[i] <= (1-u[j])*M
#         [i = 1:6, j=1:6], -(1-u[j])*M <= z4[i,j] - lambda4[i]
#         [i = 1:6, j=1:6], z4[i,j] <= u[j]*M
#         [i = 1:6, j=1:6], -u[j]*M <= z4[i,j]
#     end)

#     # Linearizing lambda1[3]*u[9]
#     # We transform the continuous var u[9] in integer one
#     # with binary expansion: u[9] = sum 2^i * z_i
#     Mu = Int64(ifelse(max_extra_demand >= 1, ceil(log2(max_extra_demand)+1), 0.0))
#     prod_u9_l3 = 0
#     if Mu > 0
#         @variable(model, w[1:Mu])
#         @variable(model, z_u9[1:Mu])
#         @constraints(model, begin
#                     u[9] == sum(2^i*z_u9[i] for i = 1:Mu;init=0)
#             [i = 1:Mu], w[i] - lambda1[3] <= (1-z_u9[i])*M
#             [i = 1:Mu], -(1-z_u9[i])*M <= w[i] - lambda1[3]
#             [i = 1:Mu],  w[i] <= z_u9[i]*M
#             [i = 1:Mu], -z_u9[i]*M <= w[i]
#         end)
#         prod_u9_l3 = sum(2^i*w[i] for i = 1:Mu;init=0)
#     else
#         @constraint(model, u[9] == 0)
#     end
#     @constraints(model, begin
#         [i = 1:3, j=10:11], z1[i,j] == 0
#         [i = 1:2, j=10:11], z2[i,j] == 0
#         [i = 1:6, j=10:11], z3[i,j] == 0
#         [i = 1:6, j=10:11], z4[i,j] == 0
#     end)

#     @constraints(model, begin
#     g1,  lambda1[1]                            + lambda2[1]              <= C[1]
#     g2,              + lambda1[2]              + lambda2[2]              <= C[2]
#     g3,                           + lambda1[3]                           <= C[3]
#     f1, - lambda1[1]              + lambda1[3] + lambda3[1] + lambda4[1] == 0
#     f2, - lambda1[1] + lambda1[2]              + lambda3[2] + lambda4[2] == 0
#     f3,              - lambda1[2] + lambda1[3] + lambda3[3] + lambda4[3] == 0
#     f4, - lambda1[1] +            + lambda1[3] + lambda3[4] + lambda4[4] == 0
#     f5, - lambda1[1] + lambda1[2]              + lambda3[5] + lambda4[5] == 0
#     f6,              - lambda1[2] + lambda1[3] + lambda3[6] + lambda4[6] == 0
#     end)

#     @objective(model, Max, lambda1[3]*D + prod_u9_l3 +
#                            z2[1,7]*(Gmax[1] + x[1]) + z2[2,8]*(Gmax[2] + x[2]) +
#                            sum(z3[i,i]*Fmax[i] for i = 1:3) + sum(z3[i,i]*Fmax[i]*x[i-1] for i = 4:6) -
#                            sum(z4[i,i]*Fmax[i] for i = 1:3) - sum(z4[i,i]*Fmax[i]*x[i-1] for i = 4:6)
#                            )
#     g = [g1,g2,g3]
#     f = [f1,f2,f3,f4,f5,f6]
#     @expression(model, b_alpha,
#         [lambda2[1]*u[7], 
#         lambda2[2]*u[8],
#         [lambda3[i]*Fmax[i]*u[i] for i = 4:6]...])
#     @time optimize!(model)
#     @show objective_value(model)
#     @show value.(lambda1)
#     @show value.(lambda2)
#     @show value.(lambda3)
#     @show value.(lambda4)
#     @show value.(u)
#     # @show dual.(g)
#     # @show dual.(f)
#     return objective_value(model), value.(b_alpha)
# end

# x = [10,10,1,1,1]
# k_line,k_generator,max_extra_demand = 1,1,10
# println("="^100)
# println("NON LINEAR")
# println("="^100)
# fk, grad_fk = oracle_non_linear(x,k_line,k_generator,max_extra_demand);
# @show fk, grad_fk
# println("="^100)
# println("LINEARIZED")
# println("="^100)
# fk, grad_fk = oracle_linearized(x,k_line,k_generator,max_extra_demand);
# @show fk, grad_fk
# # model = oracle_non_linear_quad2bin(x,k_line,k_generator,max_extra_demand);
# println()

# u = [0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 
#      0.0, 1.0, 
#      0.0, 0.0, 0.0]
# u = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 10.0]
# u = value.(model[:u])
# # x = [0,10,0,0,0]
# # @show u
# # @show x
# println("="^100)
# println("PRIMAL")
# println("="^100)
# g(x,u);

# println("="^100)
# println("DUAL")
# println("="^100)
# model_dual = gD(x,u)
# println()