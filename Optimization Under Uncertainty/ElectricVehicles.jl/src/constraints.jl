function add_energy_balance!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T
    D = prb.data.D

    energy_storage = model[:energy_storage]
    energy_charger = model[:energy_charger]
    energy_sold = model[:energy_sold]

    @constraint(model, energy_balance_0[b = 1:B], energy_storage[b, 1] == store_init[b] + energy_charger[b, 1]*D - energy_sold[b, 1]) 
    @constraint(model, energy_balance[b = 1:B, t = 2:T], energy_storage[b, t] == energy_storage[b, t-1] + energy_charger[b, t]*D - energy_sold[b, t]) 
end

function add_choose_action!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T

    S = model[:S]
    K = model[:K]

    @constraint(model, choose_action[b = 1:B, t = 1:T], K[b, t] + S[b, t] <= 1) 
end