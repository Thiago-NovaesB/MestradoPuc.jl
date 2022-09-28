function add_KCL!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation = model[:generation]
    flow = model[:flow]
    deficit = model[:deficit]

    @constraint(model, KCL[i in 1:size.bus, t in 1:size.stages], sum(generation[j, t] for j in 1:size.gen if data.gen2bus[j] == i) +
                                                                 sum(flow[j, t] * data.A[i, j] for j in 1:size.circ) + deficit[i, t] == data.demand[i, t])
end

function add_KVL!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    flow = model[:flow]
    theta = model[:theta]

    @constraint(model, KVL[i in 1:size.circ, t in 1:size.stages], flow[i, t] == sum(theta[j, t] * data.A[j, i] for j in 1:size.bus) / data.x[i])
end

function add_RAMP!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation = model[:generation]

    @constraint(model, RAMP_UP[t in 1:size.stages, g in 1:size.gen], data.ramp_up[g] >= generation[g, mod1(t + 1, size.stages)] - generation[g, t])
    @constraint(model, RAMP_DOWN[t in 1:size.stages, g in 1:size.gen], -data.ramp_down[g] <= generation[g, mod1(t + 1, size.stages)] - generation[g, t])
end

function add_COMMIT!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation = model[:generation]
    comt = model[:comt]
    turn_on = model[:turn_on]
    turn_off = model[:turn_off]

    @constraint(model, COMMIT_UP[g in 1:size.gen, t in 1:size.stages], data.g_max[g] * comt[g, t] >= generation[g, t])
    @constraint(model, STA_COMMIT_CONST[g in 1:size.gen, t in 1:size.stages], turn_on[g, mod1(t + 1, size.stages)] - turn_off[g, mod1(t + 1, size.stages)] == comt[g, mod1(t + 1, size.stages)] - comt[g, t])
    @constraint(model, STA_turn_on[g in 1:size.gen, t in 1:size.stages], turn_on[g, mod1(t + 1, size.stages)] + turn_off[g, mod1(t + 1, size.stages)] <= comt[g, mod1(t + 1, size.stages)] + comt[g, t])
    @constraint(model, STA_turn_off[g in 1:size.gen, t in 1:size.stages], turn_on[g, mod1(t + 1, size.stages)] + turn_off[g, mod1(t + 1, size.stages)] + comt[g, mod1(t + 1, size.stages)] + comt[g, t] <= 2)
end

function add_TIMES!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    comt = model[:comt]
    turn_on = model[:turn_on]
    turn_off = model[:turn_off]

    @constraint(model, UP_TIME[g in 1:size.gen, t in 1:size.stages], sum(turn_on[g, mod1(i, size.stages)] for i in t+1:t+data.up_time[g]) <= comt[g, mod1(t + data.up_time[g], size.stages)])
    @constraint(model, DOWN_TIME[g in 1:size.gen, t in 1:size.stages], sum(turn_off[g, mod1(i, size.stages)] for i in t+1:t+data.down_time[g]) <= 1 - comt[g, mod1(t + data.up_time[g], size.stages)])
end

function add_KCL_k!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation_k = model[:generation_k]
    flow_k = model[:flow_k]
    deficit = model[:deficit]
    deficit = model[:deficit]
    deficit_k = model[:deficit_k]
    generation_cut = model[:generation_cut]

    @constraint(model, KCL_k[i in 1:size.bus, t in 1:size.stages, k=1:size.K], sum(generation_k[j, t, k] for j in 1:size.gen if data.gen2bus[j] == i) +
                                                                               sum(flow_k[j, t, k] * data.A[i, j] for j in 1:size.circ) + deficit_k[i, t, k] - generation_cut[i, t, k] == data.demand[i, t])
end

function add_KVL_k!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    flow_k = model[:flow_k]
    deficit = model[:deficit]
    deficit = model[:deficit]
    theta_k = model[:theta_k]

    @constraint(model, KVL_k[i in 1:size.circ, t in 1:size.stages, k=1:size.K], flow_k[i, t, k] == data.contingency_lin[i, k] * sum(theta_k[j, t, k] * data.A[j, i] for j in 1:size.bus) / data.x[i])
end

function add_RAMP_k!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation_k = model[:generation_k]
    deficit = model[:deficit]
    deficit = model[:deficit]

    @constraint(model, RAMP_UP_k[t in 1:size.stages, g in 1:size.gen, k=1:size.K], data.ramp_up[g] >= generation_k[g, mod1(t + 1, size.stages), k] - generation_k[g, t, k])
    @constraint(model, RAMP_DOWN_k[t in 1:size.stages, g in 1:size.gen, k=1:size.K], -data.ramp_down[g] <= generation_k[g, mod1(t + 1, size.stages), k] - generation_k[g, t, k])
end

function add_DEF_CUT_MAX!(prb::Problem)
    model = prb.model
    size = prb.size
    deficit = model[:deficit]
    deficit = model[:deficit]
    deficit_k = model[:deficit_k]
    deficit_k_max = model[:deficit_k_max]
    generation_cut = model[:generation_cut]
    generation_cut_max = model[:generation_cut_max]

    @constraint(model, DEF_MAX[i in 1:size.bus, t in 1:size.stages, k=1:size.K], deficit_k_max[i, t] >= deficit_k[i, t, k])
    @constraint(model, GEN_MAX[i in 1:size.bus, t in 1:size.stages, k=1:size.K], generation_cut_max[i, t] >= generation_cut[i, t, k])
end

function add_GEN_DEV!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    generation = model[:generation]
    generation_k = model[:generation_k]
    deficit = model[:deficit]
    reserve_plus = model[:reserve_plus]
    reserve_minus = model[:reserve_minus]
    deficit = model[:deficit]

    @constraint(model, GEN_DEV_MIN[g in 1:size.gen, t in 1:size.stages, k=1:size.K], (generation[g, t] - reserve_minus[g, t]) * data.contingency_gen[g, k] <= generation_k[g, t, k])
    @constraint(model, GEN_DEV_MAX[g in 1:size.gen, t in 1:size.stages, k=1:size.K], (generation[g, t] + reserve_plus[g, t]) * data.contingency_gen[g, k] >= generation_k[g, t, k])
end
