function add_energy_storage!(prb::Problem)
    model = prb.model
    store_max = prb.data.store_max
    store_min = prb.data.store_min
    B = prb.data.B
    T = prb.data.T

    @variable(model, store_min <= energy_storage[1:B, 1:T] <= store_max)
end

function add_energy_sold!(prb::Problem)
    model = prb.model
    store_max = prb.data.store_max
    store_min = prb.data.store_min
    B = prb.data.B
    T = prb.data.T

    @variable(model, store_min <= energy_sold[1:B, 1:T] <= store_max)
end

function add_charging_battery!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T

    @variable(model, K[1:B, 1:T], Bin)
end

function add_swapping_battery!(prb::Problem)
    model = prb.model
    B = prb.data.B
    T = prb.data.T

    @variable(model, S[1:B, 1:T], Bin)
end

function add_energy_charger!(prb::Problem)
    model = prb.model
    store_max = prb.data.store_max
    store_min = prb.data.store_min
    B = prb.data.B
    T = prb.data.T

    @variable(model, store_min <= energy_charger[1:B, 1:T] <= store_max)
end