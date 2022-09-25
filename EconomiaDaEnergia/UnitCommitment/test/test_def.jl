function teste_1()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;
    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = false;
    options.use_ramp = false;
    options.use_commit=false;
    options.use_up_down_time = false;
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 1;
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100 for i in 1:1]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_2()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;
    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = true;
    options.use_ramp = false;
    options.use_commit=false;
    options.use_up_down_time = false;
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 1;
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100 for _ in 1:1]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_3()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;

    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = true;
    options.use_ramp = true;
    options.use_commit=false;
    options.use_up_down_time = false;
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 24;
    data.ramp_down=[10, 10];
    data.ramp_up=[10, 10];
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [10+90*sin(pi*i/24) for i in 1:24]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_4()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;

    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = true;
    options.use_ramp = true;
    options.use_commit=true;
    options.use_up_down_time = false;
    data.turn_on_cost = [100, 100, 100];
    data.turn_off_cost = [100, 100, 100];
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 24;
    data.ramp_down=[10, 10];
    data.ramp_up=[10, 10];
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [10+90*sin(pi*i/24) for i in 1:24]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_5()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;
    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = true;
    options.use_ramp = true;
    options.use_commit=true;
    options.use_up_down_time = true;

    data.up_time = [2,2,2];
    data.down_time = [2,2,2];
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 24;
    data.turn_on_cost = [100, 100, 100];
    data.turn_off_cost = [100, 100, 100];
    data.ramp_down=[10, 10];
    data.ramp_up=[10, 10];
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [10+90*sin(pi*i/24) for i in 1:24]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end

function teste_6()
    prb = UnitCommitment.Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;
    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = true;
    options.use_ramp = true;
    options.use_commit=true;
    options.use_up_down_time = true;
    options.use_contingency = true;
    data.def_cost_rev = [500,500,500];
    data.gen_cut_cost = [500,500,500];
    size.K=2;
    data.contingency_gen = [true true
                            true false];

    data.contingency_lin = [true true
                            true true
                            false true];
    data.reserve_plus_cost = [50,75]
    data.reserve_minus_cost = [50,75]
    data.up_time = [2,2,2];
    data.down_time = [2,2,2];
    size.bus = 3;
    size.circ = 3;
    size.gen = 2;
    size.stages = 24;
    data.turn_on_cost = [100, 100, 100];
    data.turn_off_cost = [100, 100, 100];
    data.ramp_down=[10, 10];
    data.ramp_up=[10, 10];
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [10+90*sin(pi*i/24) for i in 1:24]]';
    data.def_cost = zeros(size.bus).+1000;
    data.gen2bus = [1,2]
    UnitCommitment.build_model(prb)
    UnitCommitment.solve_model(prb)
    return prb
end