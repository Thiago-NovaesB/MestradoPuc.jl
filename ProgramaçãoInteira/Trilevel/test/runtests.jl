using Trilevel
using Gurobi
using HiGHS

function create_data()
    data = Trilevel.Data()

    data.Gmax = [100, 20, 100]
    data.expGmax = [10, 10, 0]
    data.C = [100, 150, 1000]
    data.def_cost = 1000.0
    data.Fmax = [100,20,100,100,20,100]
    data.demand = [0, 0, 100]
    data.def = [0, 10, 0]
    data.nter = 3
    data.nlin = 6
    data.nbus = 3
    data.ter2bus = [1, 2, 3]
    data.A = [-1 -1 0 -1 -1 0;
            0 1 -1 0 1 -1;
            1 0 1 1 0 1]
    data.expG = [0, 0, 0]
    data.contg = [1, 1, 1]
    data.exist = [1, 1, 1, 0, 0, 0]
    data.expL = [0, 0, 0, 0, 0, 0]
    data.contl = [1, 1, 1, 1, 1, 1]

    data.k = 1
    data.bigM = 1e3
    data.max_extra_demand = 10
    return data
end

data = create_data()
master = Trilevel.create_master(data)
Trilevel.trilevel_model(data)