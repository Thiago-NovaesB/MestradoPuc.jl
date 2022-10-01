function teste_1()
    prb = UnitCommitment.Problem()
    data = prb.data
    options = prb.options
    size = prb.size
    options.solver = HiGHS.Optimizer
    options.use_kirchhoff = false
    options.use_ramp = false
    options.use_commit = false
    options.use_up_down_time = false
    size.bus = 3
    size.circ = 3
    size.gen = 2
    size.stages = 1
    data.gen_cost = [100, 150]
    data.g_max = [100, 20]
    data.g_min = [0, 0]
    data.A = [1 1 0
        0 -1 1
        -1 0 -1]
    data.f_max = [100, 20, 100]
    data.x = [1.0, 1.0, 1.0]
    data.demand = [zeros(size.stages) zeros(size.stages) [100 for _ in 1:1]]'
    data.def_cost = zeros(size.bus) .+ 1000
    data.gen2bus = [1, 2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_2()
    prb = UnitCommitment.Problem()
    data = prb.data
    options = prb.options
    size = prb.size
    options.solver = HiGHS.Optimizer
    options.use_kirchhoff = true
    options.use_ramp = false
    options.use_commit = false
    options.use_up_down_time = false
    size.bus = 3
    size.circ = 3
    size.gen = 2
    size.stages = 1
    data.gen_cost = [100, 150]
    data.g_max = [100, 20]
    data.g_min = [0, 0]
    data.A = [1 1 0
        0 -1 1
        -1 0 -1]
    data.f_max = [100, 20, 100]
    data.x = [1.0, 1.0, 1.0]
    data.demand = [zeros(size.stages) zeros(size.stages) [100 for _ in 1:1]]'
    data.def_cost = zeros(size.bus) .+ 1000
    data.gen2bus = [1, 2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_3()
    prb = UnitCommitment.Problem()
    data = prb.data
    options = prb.options
    size = prb.size

    options.solver = HiGHS.Optimizer
    options.use_kirchhoff = true
    options.use_ramp = false
    options.use_commit = false
    options.use_up_down_time = false
    options.use_contingency = true
    size.circ = 3
    size.stages = 1
    data.f_max = [100, 100, 100]
    data.x = [1.0, 1.0, 1.0]
    data.g_max = [100, 100]
    data.g_min = [0, 0]
    data.gen_cost = [100, 150]
    data.gen2bus = [1, 2]
    data.ramp_down = [50, 50]
    data.ramp_up = [50, 50]
    size.bus = 3
    size.gen = 2
    size.K = 5
    data.A = [1 1 0
        0 -1 1
        -1 0 -1]
    data.contingency_gen = [false true true true true
        true false true true true]

    data.contingency_lin = [true true false true true
        true true true false true 
        true true true true false]

    data.reserve_up_cost = [10, 15]
    data.reserve_down_cost = [10, 15]
    data.def_cost_rev = [1000,1000,1000];
    data.gen_cut_cost = [1000,1000,1000];

    data.demand = [zeros(size.stages) zeros(size.stages) [100 for _ in 1:1]]'
    data.def_cost = zeros(size.bus) .+ 1000

    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end