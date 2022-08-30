
function create_variables!(prb::Problem)

    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;
    
    if options.use_commit
        @variable(model, 0 <= generation[i in 1:size.gen, 1:size.stages] <= data.g_max[i]);
    else
        @variable(model, data.g_min[i] <= generation[i in 1:size.gen, 1:size.stages] <= data.g_max[i]);
    end
    
    @variable(model, -data.f_max[i] <= flow[i in 1:size.circ, 1:size.stages] <= data.f_max[i]);
    @variable(model, deficit[1:size.bus, 1:size.stages] >= 0.0);
    @variable(model, comt[1:size.gen, 1:size.stages],Bin);
    @variable(model, 0 <= turn_on[1:size.gen, 1:size.stages] <= 1);
    @variable(model, 0 <= turn_off[1:size.gen, 1:size.stages] <= 1);
    

    if options.use_kirchhoff 
        @variable(model, theta[1:size.bus, 1:size.stages]);
    end
end

function create_constraints!(prb::Problem)

    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;

    generation = model[:generation];
    flow = model[:flow];
    deficit = model[:deficit];
    comt = model[:comt];
    turn_on = model[:turn_on];
    turn_off = model[:turn_off];


    ################ KCL constraint 
    @constraint(model,KCL[i in 1:size.bus, t in 1:size.stages], sum(generation[j,t] for j in 1:size.gen if data.gen2bus[j] == i) +
                                                     sum(flow[j,t]*data.A[i,j] for j in 1:size.circ)  
                                                     + deficit[i,t] == data.demand[i,t]);
    ################ KVL constraint 
    if options.use_kirchhoff   
        theta = model[:theta];                                       
        @constraint(model,KVL[i in 1:size.circ, t in 1:size.stages], flow[i,t] == sum(theta[j,t]*data.A[j,i] for j in 1:size.bus));
    end

    ################ RAMP constraint 
    ### olhar restrição para Gmin != 0
    if options.use_ramp &&  options.use_commit
        @constraint(model, RAMP_UP[t in 1:size.stages, g in 1:size.gen], turn_on[g,mod1(t+1,size.stages)]*data.g_max[g] + data.ramp_up[g]*comt[g,t] >= generation[g,mod1(t+1,size.stages)] - generation[g,t]);

        @constraint(model, RAMP_DOWN[t in 1:size.stages, g in 1:size.gen], -data.ramp_down[g]*comt[g,mod1(t+1,size.stages)] -turn_off[g,mod1(t+1,size.stages)]*data.g_min[g] <= generation[g,mod1(t+1,size.stages)] - generation[g,t]);

    elseif options.use_ramp
        @constraint(model, RAMP_UP[t in 1:size.stages, g in 1:size.gen], data.ramp_up[g] >= generation[g,mod1(t+1,size.stages)] - generation[g,t]);

        @constraint(model, RAMP_DOWN[t in 1:size.stages, g in 1:size.gen], -data.ramp_down[g] <= generation[g,mod1(t+1,size.stages)] - generation[g,t]);
    end

    

    ################ COMMIT
    if options.use_commit
        @constraint(model, COMMIT_UP[g in 1:size.gen, t in 1:size.stages], data.g_max[g]*comt[g,t] >= generation[g,t]);
        @constraint(model, COMMIT_DOWN[g in 1:size.gen, t in 1:size.stages], generation[g,t] >= data.g_min[g]*comt[g,t]);

        @constraint(model, STA_COMMIT_CONST[g in 1:size.gen, t in 1:size.stages], turn_on[g,mod1(t+1,size.stages)] - turn_off[g,mod1(t+1,size.stages)] == comt[g,mod1(t+1,size.stages)] - comt[g,t]); 
        @constraint(model, STA_turn_on[g in 1:size.gen, t in 1:size.stages], turn_on[g,mod1(t+1,size.stages)] + turn_off[g,mod1(t+1,size.stages)] <= comt[g,mod1(t+1,size.stages)] + comt[g,t]); 
        @constraint(model, STA_turn_off[g in 1:size.gen, t in 1:size.stages], turn_on[g,mod1(t+1,size.stages)] + turn_off[g,mod1(t+1,size.stages)] + comt[g,mod1(t+1,size.stages)] + comt[g,t] <= 2); 
    end

    ################ UP_time

    if options.use_up_down_time
        @constraint(model, UP_TIME[g in 1:size.gen, t in 1:size.stages], sum(turn_on[g,mod1(i,size.stages)] for i in t+1:t+data.up_time[g]) <= comt[g,mod1(t+data.up_time[g],size.stages)]);
        @constraint(model, DOWN_TIME[g in 1:size.gen, t in 1:size.stages], sum(turn_off[g,mod1(i,size.stages)] for i in t+1:t+data.down_time[g]) <= 1 - comt[g,mod1(t+data.up_time[g],size.stages)]);
    end

end

function objective_function!(prb::Problem)
    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;

    generation = model[:generation];
    flow = model[:flow];
    deficit = model[:deficit];
    comt = model[:comt];
    turn_on = model[:turn_on];
    turn_off = model[:turn_off];

    FO = @expression(model, sum(generation[i,t]*data.gen_cost[i] for i in 1:size.gen, t in 1:size.stages) + sum(deficit[j,t]*data.def_cost[j] for j in 1:size.bus, t in 1:size.stages));
    if options.use_commit
        add_to_expression!(FO, sum(turn_on[g,t]*data.turn_on_cost[g] + turn_off[g,t]*data.turn_off_cost[g] for g in 1:size.gen, t in 1:size.stages))
    end
    @objective(model,Min, FO);

end

function create_model!(prb::Problem)

    data = prb.data;
    size = prb.size;
    options = prb.options;

    prb.model = Model(options.solver)

    create_variables!(prb);

    create_constraints!(prb)
    
    objective_function!(prb)
end
