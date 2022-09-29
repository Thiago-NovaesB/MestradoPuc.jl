function add_generation!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size

    @variable(model, 0 <= g[i in 1:size.gen, 1:size.stages] <= data.g_max[i])
end

function add_flow!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, -data.f_max[i] <= f[i in 1:size.circ, 1:size.stages] <= data.f_max[i])
end

function add_deficit!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= def[1:size.bus, 1:size.stages])
end

function add_comt!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, c[1:size.gen, 1:size.stages], Bin)
end

function add_turn_on!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= on[1:size.gen, 1:size.stages] <= 1)
end

function add_turn_off!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= off[1:size.gen, 1:size.stages] <= 1)
end

function add_theta!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, theta[1:size.bus, 1:size.stages])
end

function add_reverse!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, 0 <= reserve_up[g in 1:size.gen, t in 1:size.stages] <= data.ramp_up[g])
    @variable(model, 0 <= reserve_down[g in 1:size.gen, t in 1:size.stages] <= data.ramp_down[g])
end

function add_deficit_pos!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= def_pos[i in 1:size.bus, 1:size.stages, k=1:size.K])
    @variable(model, 0 <= def_pos_max[i in 1:size.bus, 1:size.stages])
end

function add_generation_cut!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= g_cut[i in 1:size.bus, 1:size.stages, k=1:size.K])
    @variable(model, 0 <= g_cut_max[1:size.bus, 1:size.stages])
end

function add_flow_pos!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, -data.f_max[i] * data.contingency_lin[i, k] <= f_pos[i in 1:size.circ, 1:size.stages, k=1:size.K] <= data.f_max[i] * data.contingency_lin[i, k])
end

function add_generation_pos!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, 0 <= g_pos[i in 1:size.gen, 1:size.stages, 1:size.K] <= data.g_max[i])
end

function add_theta_pos!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, theta_pos[1:size.bus, 1:size.stages, k=1:size.K])
end