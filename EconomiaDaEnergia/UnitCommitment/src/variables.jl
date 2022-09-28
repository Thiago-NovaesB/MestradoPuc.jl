function add_generation!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size

    @variable(model, 0 <= generation[i in 1:size.gen, 1:size.stages] <= data.g_max[i])
end

function add_flow!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, -data.f_max[i] <= flow[i in 1:size.circ, 1:size.stages] <= data.f_max[i])
end

function add_deficit!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, deficit[1:size.bus, 1:size.stages] >= 0.0)
end

function add_comt!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, comt[1:size.gen, 1:size.stages], Bin)
end

function add_turn_on!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= turn_on[1:size.gen, 1:size.stages] <= 1)
end

function add_turn_off!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, 0 <= turn_off[1:size.gen, 1:size.stages] <= 1)
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

    @variable(model, data.ramp_up[g] >= reserve_plus[g in 1:size.gen, t in 1:size.stages] >= 0)
    @variable(model, data.ramp_down[g] >= reserve_minus[g in 1:size.gen, t in 1:size.stages] >= 0)
end

function add_deficit_k!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, deficit_k[i in 1:size.bus, 1:size.stages, k=1:size.K] >= 0)
    @variable(model, deficit_k_max[i in 1:size.bus, 1:size.stages])
end

function add_generation_cut!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, generation_cut[i in 1:size.bus, 1:size.stages, k=1:size.K] >= 0)
    @variable(model, generation_cut_max[1:size.bus, 1:size.stages])
end

function add_flow_k!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, -data.f_max[i] * data.contingency_lin[i, k] <= flow_k[i in 1:size.circ, 1:size.stages, k=1:size.K] <= data.f_max[i] * data.contingency_lin[i, k])
end

function add_generation_k!(prb::Problem)
    model = prb.model
    size = prb.size
    data = prb.data

    @variable(model, 0 <= generation_k[i in 1:size.gen, 1:size.stages, 1:size.K] <= data.g_max[i])
end

function add_theta_k!(prb::Problem)
    model = prb.model
    size = prb.size

    @variable(model, theta_k[1:size.bus, 1:size.stages, k=1:size.K])
end