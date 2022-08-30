using JuMP
using HiGHS

include("types.jl");
include("model.jl");

function teste_1()
    prb = Problem();
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
    size.stages = 24;
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.g_min = [0, 0];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100 for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

function teste_2()
    prb = Problem();
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
    size.stages = 24;
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.g_min = [0, 0];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100 for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

function teste_3()
    prb = Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;

    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = false;
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
    data.g_min = [0, 0];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 10i for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

function teste_4()
    prb = Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;

    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = false;
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
    data.g_min = [15, 10];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 10i for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

function teste_5()
    prb = Problem();
    data = prb.data;
    options = prb.options;
    size = prb.size;
    options.solver = HiGHS.Optimizer;
    options.use_kirchhoff = false;
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
    data.g_min = [15, 10];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100*(mod(i,3)) for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

function teste_6()
    prb = Problem();
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
    data.ramp_down=[100, 100];
    data.ramp_up=[100, 100];
    data.gen_cost = [100, 150];
    data.g_max = [100, 20];
    data.g_min = [15, 10];
    data.A = [1 1 0
            0 -1 1
            -1 0 -1];
    data.f_max = [100,20,100];
    data.demand = [zeros(size.stages) zeros(size.stages) [ 100*(mod(i,3)) for i in 1:24]]';
    data.def_cost = zeros(size.bus,size.stages).+1000;
    data.gen2bus = [1,2]
    create_model!(prb)
    optimize!(prb.model)
    return prb
end

prb_1 = teste_1();
@show value.(prb_1.model[:generation]);

prb_2 = teste_2();
@show value.(prb_2.model[:generation]);

prb_3 = teste_3();
@show value.(prb_3.model[:generation]);

prb_4 = teste_4();
@show value.(prb_4.model[:generation]);

prb_5 = teste_5();
@show value.(prb_5.model[:generation]);

prb_6 = teste_6();
@show value.(prb_6.model[:generation]);