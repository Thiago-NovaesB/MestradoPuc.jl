
function create_variables!(prb::Problem)

    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;
    
    if options.use_commit
        @variable(model, 0 <= generation[i in 1:size.gen, 1:size.stages] <= data.g_max[i]);
        @variable(model, comt[1:size.gen, 1:size.stages],Bin);
        @variable(model, 0 <= turn_on[1:size.gen, 1:size.stages] <= 1);
        @variable(model, 0 <= turn_off[1:size.gen, 1:size.stages] <= 1);
    else
        @variable(model, data.g_min[i] <= generation[i in 1:size.gen, 1:size.stages] <= data.g_max[i]);
    end
    
    @variable(model, -data.f_max[i] <= flow[i in 1:size.circ, 1:size.stages] <= data.f_max[i]);
    @variable(model, deficit[1:size.bus, 1:size.stages] >= 0.0);
    

    if  options.use_contingency
        @variable(model,data.ramp_up[g] >= reserve_plus[g in 1:size.gen, t in 1:size.stages] >=0);
        @variable(model,data.ramp_down[g] >= reserve_minus[g in 1:size.gen, t in 1:size.stages] >=0);
    end

    
    if options.use_kirchhoff 
        @variable(model, theta[1:size.bus, 1:size.stages]);
    end

    if options.use_contingency


        if options.use_commit
            @variable(model, 0 <= generation_k[i in 1:size.gen, 1:size.stages, 1:size.K] <= data.g_max[i]);
        else
            @variable(model, data.g_min[i] <= generation_k[i in 1:size.gen, 1:size.stages, 1:size.K] <= data.g_max[i]);
        end

        @variable(model, -data.f_max[i]*data.contingency_lin[i,k] <= flow_k[i in 1:size.circ, 1:size.stages, k = 1:size.K] <= data.f_max[i]*data.contingency_lin[i,k]);

        @variable(model, deficit_k[i in 1:size.bus, 1:size.stages, k = 1:size.K]>=0);

        @variable(model, deficit_k_max[i in 1:size.bus, 1:size.stages]);

        @variable(model, generation_cut[i in 1:size.bus, 1:size.stages, k = 1:size.K]>=0)

        @variable(model, generation_cut_max[1:size.bus, 1:size.stages]);

        if options.use_kirchhoff 
            @variable(model, theta_k[1:size.bus, 1:size.stages, k = 1:size.K]);
        end

    end
    
end

function create_cont_constraints!(prb::Problem)
    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;

    generation = model[:generation];
    generation_k = model[:generation_k];
    flow_k = model[:flow_k];
    
    deficit = model[:deficit];

    reserve_plus = model[:reserve_plus];
    reserve_minus = model[:reserve_minus];

    deficit = model[:deficit];
    deficit_k = model[:deficit_k];
    deficit_k_max = model[:deficit_k_max];
    generation_cut = model[:generation_cut];
    generation_cut_max = model[:generation_cut_max];

    ############### defecit + gen cut
    @constraint(model, DEF_MAX[i in 1:size.bus, t in 1:size.stages, k = 1:size.K], deficit_k_max[i,t] >= deficit_k[i,t,k]);
    @constraint(model, GEN_MAX[i in 1:size.bus, t in 1:size.stages, k = 1:size.K], generation_cut_max[i,t] >= generation_cut[i,t,k]);
    
    
    ############### KCL constraint 
    @constraint(model,KCL_k[i in 1:size.bus, t in 1:size.stages, k = 1:size.K], sum(generation_k[j,t,k]  for j in 1:size.gen if data.gen2bus[j] == i) +
                                                     sum(flow_k[j,t,k]*data.A[i,j] for j in 1:size.circ) +
                                                     deficit_k[i,t,k] - generation_cut[i,t,k] == data.demand[i,t]);
    ############### KVL constraint 
    if options.use_kirchhoff   
        theta_k = model[:theta_k];                                       
        @constraint(model,KVL_k[i in 1:size.circ, t in 1:size.stages, k = 1:size.K], flow_k[i,t,k] == data.contingency_lin[i,k]*sum(theta_k[j,t,k]*data.A[j,i] for j in 1:size.bus));
    end

    ############### generation deviation

    @constraint(model, GEN_DEV_MIN[g in 1:size.gen, t in 1:size.stages, k = 1:size.K], (generation[g,t]-reserve_minus[g,t])*data.contingency_gen[g,k] <= generation_k[g,t,k]);

    @constraint(model, GEN_DEV_MAX[g in 1:size.gen, t in 1:size.stages, k = 1:size.K], (generation[g,t]+reserve_plus[g,t])*data.contingency_gen[g,k] >= generation_k[g,t,k]);

    ################ RAMP constraint 
    ### olhar restrição para Gmin != 0
    if options.use_ramp &&  options.use_commit

        comt = model[:comt];
        turn_on = model[:turn_on];
        turn_off = model[:turn_off];
        @constraint(model, RAMP_UP_k[t in 1:size.stages, g in 1:size.gen, k = 1:size.K] , turn_on[g,mod1(t+1,size.stages)]*data.g_max[g] + data.ramp_up[g]*comt[g,t] >= generation_k[g,mod1(t+1,size.stages),k] - generation_k[g,t,k] );

        @constraint(model, RAMP_DOWN_k[t in 1:size.stages, g in 1:size.gen, k = 1:size.K], -data.ramp_down[g]*comt[g,mod1(t+1,size.stages)] -turn_off[g,mod1(t+1,size.stages)]*data.g_min[g] <= generation_k[g,mod1(t+1,size.stages),k] - generation_k[g,t,k]);

    elseif options.use_ramp
        @constraint(model, RAMP_UP_k[t in 1:size.stages, g in 1:size.gen, k = 1:size.K], data.ramp_up[g] >= generation_k[g,mod1(t+1,size.stages),k] - generation_k[g,t,k]);

        @constraint(model, RAMP_DOWN_k[t in 1:size.stages, g in 1:size.gen, k = 1:size.K], -data.ramp_down[g] <= generation_k[g,mod1(t+1,size.stages),k] - generation_k[g,t,k]);
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

    ################ KCL constraint 
    @constraint(model,KCL[i in 1:size.bus, t in 1:size.stages], sum(generation[j,t]  for j in 1:size.gen if data.gen2bus[j] == i) +
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
        comt = model[:comt];
        turn_on = model[:turn_on];
        turn_off = model[:turn_off];
        @constraint(model, RAMP_UP[t in 1:size.stages, g in 1:size.gen] , turn_on[g,mod1(t+1,size.stages)]*data.g_max[g] + data.ramp_up[g]*comt[g,t] >= generation[g,mod1(t+1,size.stages)] - generation[g,t]);

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

    ################ contingency

    if options.use_contingency

        create_cont_constraints!(prb)

        
    end


end

function objective_function!(prb::Problem)
    model = prb.model;
    data = prb.data;
    size = prb.size;
    options = prb.options;

    generation = model[:generation];
    deficit = model[:deficit];
    
    FO = @expression(model, sum(generation[i,t]*data.gen_cost[i] for i in 1:size.gen, t in 1:size.stages) + sum(deficit[j,t]*data.def_cost[j] for j in 1:size.bus, t in 1:size.stages));
    if options.use_commit
        turn_on = model[:turn_on];
        turn_off = model[:turn_off];
        add_to_expression!(FO, sum(turn_on[g,t]*data.turn_on_cost[g] + turn_off[g,t]*data.turn_off_cost[g] for g in 1:size.gen, t in 1:size.stages))
    end

    if options.use_contingency
        reserve_plus = model[:reserve_plus];
        reserve_minus = model[:reserve_minus];
        deficit_k_max = model[:deficit_k_max];
        generation_cut_max = model[:generation_cut_max];
        add_to_expression!(FO, sum(reserve_plus[i,t]*data.reserve_plus_cost[i] + reserve_minus[i,t]*data.reserve_minus_cost[i]  for i in 1:size.gen, t in 1:size.stages) + sum(deficit_k_max[j,t]*data.def_cost_rev[j] + generation_cut_max[j,t]*data.gen_cut_cost[j] for j in 1:size.bus, t in 1:size.stages));
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
