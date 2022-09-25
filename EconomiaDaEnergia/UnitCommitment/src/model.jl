function build_model(prb::Problem)
    
    options = prb.options
    prb.model = Model(options.solver)
    JuMP.MOI.set(prb.model, JuMP.MOI.Silent(), true)
    
    add_variables!(prb)
    add_constraints!(prb)
    objective_function!(prb)
    nothing
end

function solve_model(prb::Problem)
    
    optimize!(prb.model)
    nothing
end

function add_variables!(prb::Problem)
    
    options = prb.options
    
    add_generation!(prb)
    add_flow!(prb)
    add_deficit!(prb)
    if options.use_commit
        add_comt!(prb)
        add_turn_on!(prb)
        add_turn_off!(prb)
    end
    if options.use_kirchhoff 
        add_theta!(prb)
    end
    if  options.use_contingency
        add_reverse!(prb)
        add_deficit_k!(prb)
        add_generation_cut!(prb)
        add_flow_k!(prb)
        add_generation_k!(prb)
        if options.use_kirchhoff
            add_theta_k!(prb)
        end
    end
    nothing
end

function add_constraints!(prb::Problem)
    
    options = prb.options

    add_KCL!(prb)
    if options.use_kirchhoff  
        add_KVL!(prb)
    end
    if options.use_ramp
        add_RAMP!(prb)
    end
    if options.use_commit
        add_COMMIT!(prb)
        if options.use_up_down_time
            add_TIMES!(prb)
        end
    end
    if options.use_contingency
        add_KCL_k!(prb)
        if options.use_kirchhoff  
            add_KVL_k!(prb)
        end
        if options.use_ramp
            add_RAMP_k!(prb)
        end
        add_DEF_CUT_MAX!(prb)
        add_GEN_DEV!(prb)
    end
    nothing
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