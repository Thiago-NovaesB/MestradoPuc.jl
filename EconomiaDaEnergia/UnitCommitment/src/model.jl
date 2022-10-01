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

    add_generation!(prb)
    add_flow!(prb)
    add_deficit!(prb)
    add_comt!(prb)
    add_turn_on!(prb)
    add_turn_off!(prb)
    add_theta!(prb)
    add_reserve!(prb)
    add_deficit_pos!(prb)
    add_generation_cut!(prb)
    add_flow_pos!(prb)
    add_generation_pos!(prb)
    add_theta_pos!(prb)
    nothing
end

function add_constraints!(prb::Problem)

    add_KCL!(prb)
    add_KVL!(prb)
    add_RAMP!(prb)
    add_COMMIT!(prb)
    add_TIMES!(prb)
    add_KCL_pos!(prb)
    add_KVL_pos!(prb)
    add_RAMP_pos!(prb)
    add_DEF_CUT_MAX!(prb)
    add_GEN_DEV!(prb)
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