using Simplex

A = [2 1 1 0; 1 2 0 1]
b = [4, 4]
c = [4, 3, 0, 0]
base = [3, 4]
nbase = [1, 2]

input = Simplex.create(A, b, c, base, nbase)

output = Simplex.solve(input)

@show output