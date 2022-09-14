function add_battery_balance!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T
    D = prb.data.D
    bat_efficiency = prb.data.bat_efficiency
    store_init = prb.data.store_init

    energy_storage = model[:energy_storage]
    energy_charger = model[:energy_charger]
    energy_sold = model[:energy_sold]

    @constraint(model, battery_balance_0[b = 1:B], energy_storage[b, 1] == store_init[b] + energy_charger[b, 1]*D*bat_efficiency - energy_sold[b, 1]) 
    @constraint(model, battery_balance[b = 1:B, t = 2:T], energy_storage[b, t] == energy_storage[b, t-1] + energy_charger[b, t]*D*bat_efficiency - energy_sold[b, t]) 
end

function add_energy_sold_balance!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T
    store_init = prb.data.store_init
    energy_arrived = prb.data.energy_arrived

    energy_storage = model[:energy_storage]
    energy_sold = model[:energy_sold]
    S = model[:S]

    @constraint(model, energy_sold_balance_0[b = 1:B], energy_sold[b, 1] == (store_init[b] + energy_arrived[1])*S[b,1]) 
    # @constraint(model, energy_sold_balance[b = 1:B, t = 2:T], energy_sold[b, t] == (energy_storage[b, t-1] + energy_arrived[t])*S[b,t]) #TODO
end

function add_final_storage!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T
    store_max = prb.data.store_max
    rho = prb.data.rho
    
    energy_storage = model[:energy_storage]

    @constraint(model, final_storage[b = 1:B], energy_storage[b, T] >= rho*store_max ) 
end

function add_choose_action!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T

    S = model[:S]
    K = model[:K]

    @constraint(model, choose_action[b = 1:B, t = 1:T], K[b, t] + S[b, t] <= 1) 
end

function add_min_swap!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T
    store_init = prb.data.store_init
    swap_min = prb.data.swap_min

    S = model[:S]
    energy_storage = model[:energy_storage]

    @constraint(model, min_swap_0[b = 1:B], store_init[b] >= swap_min*S[b,1]) 
    @constraint(model, min_swap[b = 1:B, t = 1:T-1], energy_storage[b, t] >= swap_min*S[b,t+1]) 
end

function add_swap_battery!(prb::Problem)
    model = prb.model
    B = prb.data.B
    Tarr = prb.data.Tarr

    S = model[:S]

    @constraint(model, swap_battery_0[t in Tarr], sum(S[:,t]) <= 1) 
    @constraint(model, swap_battery_1[b = 1:B, t in Tarr], S[b,t] == 0) #TODO
end

function add_max_charges!(prb::Problem)
    model = prb.model
    N = prb.data.N
    T = prb.data.T

    K = model[:K]

    @constraint(model, max_charges[t in 1:T], sum(K[:,t]) <= N) 
end

function add_max_charger!(prb::Problem)
    model = prb.model
    charging_rate = prb.data.charging_rate
    T = prb.data.T
    B = prb.data.B

    K = model[:K]
    energy_charger = model[:energy_charger]

    @constraint(model, max_charger[b in 1:B, t in 1:T], energy_charger[b,t] <= charging_rate*K[b,t]) 
end

function add_disponible_converter_energy!(prb::Problem)
    model = prb.model
    converter_rate = prb.data.converter_rate
    T = prb.data.T
    
    energy_charger = model[:energy_charger]

    @constraint(model, disponible_converter_energy[t in 1:T], sum(energy_charger[:,t]) <= converter_rate) 
end

function add_energy_balance!(prb::Problem)
    model = prb.model
    T = prb.data.T
    con_efficiency = prb.data.con_efficiency
    
    energy_charger = model[:energy_charger]
    energy_sold_grid = model[:energy_sold_grid]
    energy_bought_grid = model[:energy_bought_grid]
    pv_generation = model[:pv_generation]
    

    @constraint(model, energy_balance[t in 1:T], sum(energy_charger[:,t]) + energy_sold_grid[t] == energy_bought_grid[t]*con_efficiency + pv_generation[t]) 
end