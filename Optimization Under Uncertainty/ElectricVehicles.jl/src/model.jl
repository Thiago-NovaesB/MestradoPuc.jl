function add_variables!(prb::Problem)
    
    add_energy_storage!(prb)
    add_energy_sold!(prb)
    add_charging_battery!(prb)
    add_swapping_battery!(prb)
    add_energy_charger!(prb)
    nothing
end

function add_constraints!(prb::Problem)
    
    add_energy_balance!(prb)
    nothing
end