function primal(data)
    model = Model(Gurobi.Optimizer)
    set_silent(model)
    @variable(model, 0 <= g[i=1:data.nter])
    @variable(model, f[1:data.nlin])

    @constraint(model, lambda1[b = 1:data.nbus], sum(g[t] for t in 1:data.nter if data.ter2bus[t] == b) + sum(f[c] * data.A[b, c] for c in 1:data.nlin) == data.demand[b])
    @constraint(model, lambda2[t = 1:data.nter], g[t] <= (data.Gmax[t] + data.expG[t])*data.contg[t])

    @constraint(model, lambda3[i = 1:data.nlin], f[i] <= data.Fmax[i]*(data.expL[i]+data.exist[i])*data.contl[i])
    @constraint(model, lambda4[i = 1:data.nlin], f[i] >= -data.Fmax[i]*(data.expL[i]+data.exist[i])*data.contl[i])

    @objective(model, Min, sum(data.C.*g))
    optimize!(model)
    @show objective_value(model)
    @show JuMP.dual.(lambda1)
    @show JuMP.dual.(lambda2)
    @show JuMP.dual.(lambda3)
    @show JuMP.dual.(lambda4)
    @show JuMP.value.(g)
    @show JuMP.value.(f)
    return model
end

function dual(data)
    model = Model(Gurobi.Optimizer)
    set_silent(model)

    @variable(model, lambda1[1:data.nbus])
    @variable(model, lambda2[1:data.nter] <= 0)
    @variable(model, lambda3[1:data.nlin] <= 0)
    @variable(model, lambda4[1:data.nlin] >= 0)

    @constraint(model, g[i = 1:data.nter], data.C[i] >= lambda1[i] + lambda2[data.ter2bus[i]])
    @constraint(model, f[i = 1:data.nlin], 0 == lambda3[i] + lambda4[i] + sum(lambda1[b]*data.A[b, i] for b in 1:data.nbus))

    @objective(model, Max, sum(lambda1[i]*(data.demand[i]) for i in 1:data.nbus) +
                           sum(lambda2[i]*(data.Gmax[i] + data.expG[i])*data.contg[i] for i in 1:data.nbus) +
                           sum(lambda3[i]*data.Fmax[i]*data.contl[i]*(data.expL[i]+data.exist[i]) for i = 1:data.nlin) -
                           sum(lambda4[i]*data.Fmax[i]*data.contl[i]*(data.expL[i]+data.exist[i]) for i = 1:data.nlin)
                           )
    optimize!(model)
    @show objective_value(model)
    @show value.(lambda1)
    @show value.(lambda2)
    @show value.(lambda3)
    @show value.(lambda4)
    @show JuMP.dual.(g)
    @show JuMP.dual.(f)

    @show JuMP.dual.(lambda4)
    return model
end

function oracle(data)

    # Cria o modelo
    model = Model(Gurobi.Optimizer) 
    set_silent(model)

    # Variáveis
    @variable(model, pi_1[1:data.nter] <= 0)
    @variable(model, pi_2[1:data.nbus])
    @variable(model, pi_3[1:data.nlin] <= 0)
    @variable(model, pi_4[1:data.nlin] >= 0)

    # Variáveis - contingência
    @variable(model, uG[1:data.nter], Bin)
    @variable(model, uL[1:data.nlin], Bin)

    # Restrições
    @constraint(model, g[i = 1:data.nter], pi_1[i] + sum(pi_2[b] for b in 1:data.nbus if data.ter2bus[i] == b) <= data.C[i])
    @constraint(model, def[i = 1:data.nbus], pi_2[i] <= data.def_cost)
    @constraint(model, f[i = 1:data.nlin], sum(data.A[:,i] .* pi_2) + pi_3[i] + pi_4[i] == 0)
    
    # Restrições - contingência
    @constraint(model, sum(uG) + sum(uL) >= data.nter + data.nlin - data.k)

    # Função objetivo
    obj_1 = @expression(model, sum(pi_1 .* (data.Gmax + data.expG) .* uG))
    obj_2 = @expression(model, sum(data.demand .* pi_2))
    obj_3 = @expression(model, sum(pi_3 .* data.Fmax .* (data.expL+data.exist) .* uL))
    obj_4 = @expression(model, -sum(pi_4 .* data.Fmax .* (data.expL+data.exist) .* uL))
    @objective(model, Max, obj_1 + obj_2 + obj_3 + obj_4)

    optimize!(model)
    @show value.(uG)
    @show value.(uL)
    return objective_value(model), value.(uG).*value.(pi_1), value.(uL).*data.Fmax.*(value.(pi_3)-value.(pi_4))#, value.(uG), value.(uL)

end

function oracle_linear(data)

    # Cria o modelo
    model = Model(Gurobi.Optimizer) 
    set_silent(model)

    # Variáveis

    @variable(model, pi_1[1:data.nter] <= 0)
    @variable(model, pi_2[1:data.nbus])
    @variable(model, pi_3[1:data.nlin] <= 0)
    @variable(model, pi_4[1:data.nlin] >= 0)

    # Variáveis - contingência

    @variable(model, uG[1:data.nter], Bin)
    @variable(model, uL[1:data.nlin], Bin)
    @variable(model, wG[1:data.nter])
    @variable(model, wL[1:data.nlin])
    @variable(model, zL[1:data.nlin])

    # Restrições
    @constraint(model, g[i = 1:data.nter], pi_1[i] + sum(pi_2[b] for b in 1:data.nbus if data.ter2bus[i] == b) <= data.C[i])
    @constraint(model, def[i = 1:data.nbus], pi_2[i] <= data.def_cost)
    @constraint(model, f[i = 1:data.nlin], sum(data.A[:,i] .* pi_2) + pi_3[i] + pi_4[i] == 0)
        

    # Restrições - contingência
    @constraint(model, sum(uG) + sum(uL) >= data.nter + data.nlin - data.k)

    @constraint(model, [i = 1:data.nter], wG[i] <= data.bigM * uG[i])
    @constraint(model, [i = 1:data.nter], wG[i] >= -data.bigM * uG[i])
    @constraint(model, [i = 1:data.nter], wG[i] - pi_1[i] <= data.bigM * (1 - uG[i]))
    @constraint(model, [i = 1:data.nter], wG[i] - pi_1[i] >= -data.bigM * (1 - uG[i]))
    @constraint(model, [i = 1:data.nlin], wL[i] <= data.bigM * uL[i])
    @constraint(model, [i = 1:data.nlin], wL[i] >= -data.bigM * uL[i])
    @constraint(model, [i = 1:data.nlin], wL[i] - pi_3[i] <= data.bigM * (1 - uL[i]))
    @constraint(model, [i = 1:data.nlin], wL[i] - pi_3[i] >= -data.bigM * (1 - uL[i]))
    @constraint(model, [i = 1:data.nlin], zL[i] <= data.bigM * uL[i])
    @constraint(model, [i = 1:data.nlin], zL[i] >= -data.bigM * uL[i])
    @constraint(model, [i = 1:data.nlin], zL[i] - pi_4[i] <= data.bigM * (1 - uL[i]))
    @constraint(model, [i = 1:data.nlin], zL[i] - pi_4[i] >= -data.bigM * (1 - uL[i]))

    # Função objetivo
    obj_1 = @expression(model, sum(wG .* (data.Gmax + data.expG)))
    obj_2 = @expression(model, sum(data.demand .* pi_2))
    obj_3 = @expression(model, sum(wL .* data.Fmax .* (data.expL+data.exist)))
    obj_4 = @expression(model, -sum(zL .* data.Fmax .* (data.expL+data.exist)))
    @objective(model, Max, obj_1 + obj_2 + obj_3 + obj_4)

    optimize!(model)

    return objective_value(model), value.(wG), (value.(wL)-value.(zL)).*data.Fmax#, value.(uG), value.(uL)
end

function create_master(data)
    master = Model(Gurobi.Optimizer)
    set_silent(master)
    @variable(master, 0 <= expG[i = 1:data.nter] <= data.expGmax[i])
    @variable(master, expL[1:data.nlin], Bin)
    @constraint(master,[i = 1:data.nlin], expL[i] + data.exist[i] <= 1)
    @variable(master, δ >= 0)

    @objective(master, Min, sum(expG.*data.exp_cost_g) + sum(expL.*data.exp_cost_l) + δ)
    
    return master
end

function add_cut!(master, data, fk, grad_1, grad_2)

    δ = master[:δ]
    expG = master[:expG]
    expL = master[:expL]
    @constraint(master, δ >= fk + dot(grad_1,expG - data.expG) + dot(grad_2,expL - data.expL))
    
end

function solve_master!(master, data)

    optimize!(master)
    data.expG = value.(master[:expG])
    data.expL = value.(master[:expL])
    data.obj = objective_value(master)
    return nothing
end

function trilevel_model(data, oracle::Function = Trilevel.oracle, maxiters::Int = 100, tol::Float64 = 1e-3)

    master = create_master(data)
    UB = Inf
    LB = -Inf
    for i in 1:maxiters

        Trilevel.solve_master!(master, data)
        fk, grad_1, grad_2 = oracle(data)
        Trilevel.add_cut!(master, data, fk, grad_1, grad_2)
        UB = fk + sum(data.expG.*data.exp_cost_g) + sum(data.expL.*data.exp_cost_l)
        LB = data.obj
        println("iter $i")
        println("UB $UB")
        println("LB $LB")
        println("data.expG $(data.expG)")
        println("data.expL $(data.expL)")


        if UB - LB < tol
            break
        end
    end
    return master, data
end