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
    if options.use_contingency
        add_reverse!(prb)
        add_deficit_pos!(prb)
        add_generation_cut!(prb)
        add_flow_pos!(prb)
        add_generation_pos!(prb)
        if options.use_kirchhoff
            add_theta_pos!(prb)
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
        add_KCL_pos!(prb)
        if options.use_kirchhoff
            add_KVL_pos!(prb)
        end
        if options.use_ramp
            add_RAMP_pos!(prb)
        end
        add_DEF_CUT_MAX!(prb)
        add_GEN_DEV!(prb)
    end
    nothing
end

function objective_function!(prb::Problem)
    model = prb.model
    data = prb.data
    size = prb.size
    options = prb.options

    g = model[:g]
    def = model[:def]

    FO = @expression(model, sum(g[i, t] * data.gen_cost[i] for i in 1:size.gen, t in 1:size.stages) + sum(def[j, t] * data.def_cost[j] for j in 1:size.bus, t in 1:size.stages))
    if options.use_commit
        on = model[:on]
        off = model[:off]
        add_to_expression!(FO, sum(on[i, t] * data.on_cost[i] + off[i, t] * data.off_cost[i] for i in 1:size.gen, t in 1:size.stages))
    end

    if options.use_contingency
        reserve_up = model[:reserve_up]
        reserve_down = model[:reserve_down]
        def_pos_max = model[:def_pos_max]
        g_cut_max = model[:g_cut_max]
        add_to_expression!(FO, sum(reserve_up[i, t] * data.reserve_up_cost[i] + reserve_down[i, t] * data.reserve_down_cost[i] for i in 1:size.gen, t in 1:size.stages) + sum(def_pos_max[j, t] * data.def_cost_rev[j] + g_cut_max[j, t] * data.gen_cut_cost[j] for j in 1:size.bus, t in 1:size.stages))
    end

    @objective(model, Min, FO)

end