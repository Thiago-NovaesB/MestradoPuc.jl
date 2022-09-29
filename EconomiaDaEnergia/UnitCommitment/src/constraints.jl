function add_KCL!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g = model[:g]
    f = model[:f]
    def = model[:def]

    @constraint(model, KCL[i in 1:size.bus, t in 1:size.stages], sum(g[j, t] for j in 1:size.gen if data.gen2bus[j] == i) + sum(f[j, t] * data.A[i, j] for j in 1:size.circ) + def[i, t] == data.demand[i, t])
end

function add_KVL!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    f = model[:f]
    theta = model[:theta]

    @constraint(model, KVL[i in 1:size.circ, t in 1:size.stages], f[i, t] == sum(theta[j, t] * data.A[j, i] for j in 1:size.bus) / data.x[i])
end

function add_RAMP!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g = model[:g]

    @constraint(model, RAMP_UP[t in 1:size.stages, i in 1:size.gen], data.ramp_up[i] >= g[i, mod1(t + 1, size.stages)] - g[i, t])
    @constraint(model, RAMP_DOWN[t in 1:size.stages, i in 1:size.gen], -data.ramp_down[i] <= g[i, mod1(t + 1, size.stages)] - g[i, t])
end

function add_COMMIT!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g = model[:g]
    c = model[:c]
    on = model[:on]
    off = model[:off]

    @constraint(model, COMMIT_UP[i in 1:size.gen, t in 1:size.stages], data.g_max[g] * c[i, t] >= g[i, t])
    @constraint(model, STA_COMMIT_CONST[i in 1:size.gen, t in 1:size.stages], on[i, mod1(t + 1, size.stages)] - off[i, mod1(t + 1, size.stages)] == c[i, mod1(t + 1, size.stages)] - c[i, t])
    @constraint(model, STA_on[i in 1:size.gen, t in 1:size.stages], on[i, mod1(t + 1, size.stages)] + off[i, mod1(t + 1, size.stages)] <= c[i, mod1(t + 1, size.stages)] + c[i, t])
    @constraint(model, STA_off[i in 1:size.gen, t in 1:size.stages], on[i, mod1(t + 1, size.stages)] + off[i, mod1(t + 1, size.stages)] + c[i, mod1(t + 1, size.stages)] + c[i, t] <= 2)
end

function add_TIMES!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    c = model[:c]
    on = model[:on]
    off = model[:off]

    @constraint(model, UP_TIME[i in 1:size.gen, t in 1:size.stages], sum(on[i, mod1(j, size.stages)] for j in t+1:t+data.up_time[i]) <= c[i, mod1(t + data.up_time[i], size.stages)])
    @constraint(model, DOWN_TIME[i in 1:size.gen, t in 1:size.stages], sum(off[i, mod1(j, size.stages)] for j in t+1:t+data.down_time[i]) <= 1 - c[i, mod1(t + data.up_time[i], size.stages)])
end

function add_KCL_pos!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g_pos = model[:g_pos]
    f_pos = model[:f_pos]
    def = model[:def]
    def = model[:def]
    def_pos = model[:def_pos]
    g_cut = model[:g_cut]

    @constraint(model, KCL_pos[i in 1:size.bus, t in 1:size.stages, k=1:size.K], sum(g_pos[j, t, k] for j in 1:size.gen if data.gen2bus[j] == i) + sum(f_pos[j, t, k] * data.A[i, j] for j in 1:size.circ) + def_pos[i, t, k] - g_cut[i, t, k] == data.demand[i, t])
end

function add_KVL_pos!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    f_pos = model[:f_pos]
    def = model[:def]
    def = model[:def]
    theta_pos = model[:theta_pos]

    @constraint(model, KVL_pos[i in 1:size.circ, t in 1:size.stages, k=1:size.K], f_pos[i, t, k] == data.contingency_lin[i, k] * sum(theta_pos[j, t, k] * data.A[j, i] for j in 1:size.bus) / data.x[i])
end

function add_RAMP_pos!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g_pos = model[:g_pos]
    def = model[:def]
    def = model[:def]

    @constraint(model, RAMP_UP_pos[t in 1:size.stages, i in 1:size.gen, k=1:size.K], data.ramp_up[g] >= g_pos[i, mod1(t + 1, size.stages), k] - g_pos[i, t, k])
    @constraint(model, RAMP_DOWN_pos[t in 1:size.stages, i in 1:size.gen, k=1:size.K], -data.ramp_down[g] <= g_pos[i, mod1(t + 1, size.stages), k] - g_pos[i, t, k])
end

function add_DEF_CUT_MAX!(prb::Problem)
    model = prb.model
    size = prb.size
    def = model[:def]
    def = model[:def]
    def_pos = model[:def_pos]
    def_pos_max = model[:def_pos_max]
    g_cut = model[:g_cut]
    g_cut_max = model[:g_cut_max]

    @constraint(model, DEF_MAX[i in 1:size.bus, t in 1:size.stages, k=1:size.K], def_pos_max[i, t] >= def_pos[i, t, k])
    @constraint(model, GEN_MAX[i in 1:size.bus, t in 1:size.stages, k=1:size.K], g_cut_max[i, t] >= g_cut[i, t, k])
end

function add_GEN_DEV!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    g = model[:g]
    g_pos = model[:g_pos]
    def = model[:def]
    reserve_up = model[:reserve_up]
    reserve_down = model[:reserve_down]
    def = model[:def]

    @constraint(model, GEN_DEV_MIN[i in 1:size.gen, t in 1:size.stages, k=1:size.K], (g[i, t] - reserve_down[i, t]) * data.contingency_gen[i, k] <= g_pos[i, t, k])
    @constraint(model, GEN_DEV_MAX[i in 1:size.gen, t in 1:size.stages, k=1:size.K], (g[i, t] + reserve_up[i, t]) * data.contingency_gen[i, k] >= g_pos[i, t, k])
end
