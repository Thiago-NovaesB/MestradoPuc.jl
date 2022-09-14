
function add_max_profit!(prb::Problem)
    model = prb.model
    swap_price = prb.data.swap_price
    energy_price = prb.data.energy_price
    selling_price = prb.data.energy_price
    pv_price = prb.data.pv_price
    con_efficiency = prb.data.con_efficiency
    T = prb.data.T
    D = prb.data.D
    grid_price = prb.data.grid_price

    energy_sold = model[:energy_sold]
    S = model[:S]
    pv_generation = model[:pv_generation]
    energy_sold_grid = model[:energy_sold_grid]
    energy_bought_grid = model[:energy_bought_grid]

    @objective(model, Max, sum(swap_price*S + energy_price*energy_sold)
                            + sum( energy_sold_grid[t]*selling_price*con_efficiency*D for t in T)
                            - sum( energy_bought_grid[t]*grid_price[t]*D for t = 1:T)
                            - sum( pv_price*pv_generation[t]*D for t in T)
                            ) 
    
end