using ElectricVehicles
using HiGHS

prb = ElectricVehicles.Problem()
data = prb.data

data.B = 2
data.T = 5 
data.N = 3
data.Tarr = [1, 4]
data.grid_price = ones(5)
data.swap_price = 5.0
data.pv_price = 5.0
data.energy_price = 5.0
data.selling_price = 5.0
data.D = 3.0
data.store_max = 5.0
data.store_max = 3.0
data.energy_arrived = zeros(2)
data.store_init = ones(2)
data.bat_efficiency = 5.0
data.con_efficiency = 5.0
data.converter_rate = 0.5
data.pv_generation_max = ones(5)
data.grid_max = 5.0
data.charging_rate = 5.0
data.theta = 5.0
data.beta = 5.0
data.rho = 5.0
data.solver = HiGHS.Optimizer

ElectricVehicles.create_model!(prb)
ElectricVehicles.solve_model!(prb)

