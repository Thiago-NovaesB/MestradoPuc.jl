using ElectricVehicles
using HiGHS

prb = ElectricVehicles.Problem()
data = prb.data

data.B = 2
data.T = 3 
data.N_s = 3
data.N_k = 3
data.store_max = 5.0
data.store_max = 3.0
data.ramp_max = 5.0
data.converter_max = 0.5
data.battery_energy_price = 5.0
data.swap_price = 5.0
data.grid_sell_price = 3.0
data.grid_buy_price = 3.0
data.pv_price = 5.0
data.con_efficiency = 5.0
data.charger_efficiency = 0.99
data.pv_generation = ones(3)
data.D = 3.0
data.swap_min = 0.5
data.energy_arrived = [[0.5, 0.5], [0.5], [0.5]]
data.vehicles_arrived = [2, 1, 1]
data.store_init = ones(2)
data.rho = 5.0

data.solver = HiGHS.Optimizer

ElectricVehicles.create_model!(prb)
ElectricVehicles.solve_model!(prb)

