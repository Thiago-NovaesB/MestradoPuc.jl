using LinearAlgebra, Random, JuMP, Ipopt, DataFrames, CSV, Plots, Optim, Statistics
Random.seed!(1);
# FK - 122/156 11.05.22

# ============================================================
# Ler dados 
# ============================================================
# Série teste
# n = 100;
# y = rand(n);
# Série real
y = CSV.read("data.csv", DataFrame)[!, "Valor"];
# y = y/1000
n = length(y);
# Formata série
y = [[x] for x in y];

# ============================================================
# MEB com tendência linear local e sazonalidade estocástica 
# ============================================================
# Z (1, 13)
Z = [1 0 1 0 1 0 1 0 1 0 1 0 1];
# T (13, 13)
T = zeros(13, 13);
T[1,1] = 1;
T[1,2] = 1;
T[2,2] = 1;
for j in 1:5 
    c = [[cos(pi*j/6), -sin(pi*j/6)] [sin(pi*j/6), cos(pi*j/6)]];
    T[2*j+1:2*j+2, 2*j+1:2*j+2] = c
end
T[13, 13] = -1;
# R (13, 13)
R = I;

# ============================================================
# Inicialização
# ============================================================
# Big Kappa
a = Vector{Vector{Real}}(undef, n+1);
a[1] = zeros(13);
P = Vector{Array{Real, 2}}(undef, n+1);
P[1] = diagm([1e6 for _ in 1:13]);

# Resultados armazenados para o smoother
F_aux = Vector{Any}(undef, n);
K_aux = Vector{Any}(undef, n);
V_aux = Vector{Any}(undef, n);

# ============================================================
# Estimação do Filtro de Kalman e cálculo da verossimilhança
# ============================================================
function get_likelihood(var_epsilon::X, var_eta::X, var_csi::X, var_omega::X) where {X}

    # H
    H = [var_epsilon];
    # Q
    Q = zeros(X, 13,13);
    Q[1,1] = var_eta;
    Q[2,2] = var_csi;
    for j in 3:13
        Q[j,j]=var_omega;
    end
    
    # FK
    likelihood = 0.0;
    for t in 1:n

        F = Z*P[t]*Z' + H;                        # (1,13)*(13,13)*(13,1) + (1,1) = (1,1)
        K = T*P[t]*Z' * ((F)^(-1));               # (13,13)*(13,13)*(13,1)*(1,1) = (13,1)
        V = y[t] - Z*a[t];                        # (1,1) - (1,13)*(13,1) = (1,1)

        a[t+1] = T*a[t] + K*V;                    # (13,13)*(13,1) + (13,1)*(1,1) = (13,1)
        P[t+1] = T*P[t] * (T - K*Z)' + R*Q*R';    # (13,13)*(13,13) * [(13,13) - (13,1)*(1,13)]' + (13,13)*(13,13)*(13,13) = (13,13)

        if t > 13
            likelihood += (-1/2)*log(abs(F[1])) + (-1/2)*(V[1]^2)/F[1];
        end

        # Resultados armazenados para o smoother    
        F_aux[t] = F;
        K_aux[t] = K;
        V_aux[t] = V;
    end
    return likelihood
end

function get_likelihood2(des)

    des_epsilon, des_eta, des_csi, des_omega = des
    var_epsilon = des_epsilon^2
    var_eta = des_eta^2
    var_csi = des_csi^2
    var_omega = des_omega^2
    # H
    H = [var_epsilon];
    # Q
    Q = zeros(13,13);
    Q[1,1] = var_eta;
    Q[2,2] = var_csi;
    for j in 3:13
        Q[j,j]=var_omega;
    end
    
    # FK
    skip = 13
    likelihood = -(n-skip)/2 * log(2*pi);
    for t in 1:n

        F = Z*P[t]*Z' + H;                        # (1,13)*(13,13)*(13,1) + (1,1) = (1,1)
        K = T*P[t]*Z' * ((F)^(-1));               # (13,13)*(13,13)*(13,1)*(1,1) = (13,1)
        V = y[t] - Z*a[t];                        # (1,1) - (1,13)*(13,1) = (1,1)

        a[t+1] = T*a[t] + K*V;                    # (13,13)*(13,1) + (13,1)*(1,1) = (13,1)
        P[t+1] = T*P[t] * (T - K*Z)' + R*Q*R';    # (13,13)*(13,13) * [(13,13) - (13,1)*(1,13)]' + (13,13)*(13,13)*(13,13) = (13,13)

        if t > skip
            likelihood += (-1/2)*log(F[1]) + (-1/2)*(V[1]^2)/F[1];
        end
        # Resultados armazenados para o smoother    
        F_aux[t] = F;
        K_aux[t] = K;
        V_aux[t] = V;
    end
    return -likelihood/(n-skip)
end

r = optimize(get_likelihood2, [sqrt(var(y)[1]), sqrt(var(y)[1]), 1.0, 1.0], LBFGS(),Optim.Options(show_trace=true)) #NelderMead

model = Model(Ipopt.Optimizer);

register(model, :get_likelihood, 4, get_likelihood; autodiff = true);

psi = Vector{VariableRef}(undef, 4);
psi[1] = @variable(model, var_epsilon >= 0.0, start = 1.0);
psi[2] = @variable(model, var_eta >= 0.0, start = 1.0);
psi[3] = @variable(model, var_csi >= 0.0, start = 1.0);
psi[4] = @variable(model, var_omega >= 0.0, start = 1.0);
# psi[1] = @variable(model, var_epsilon >= 0.0, start = 2.4371e5);
# psi[2] = @variable(model, var_eta >= 0.0, start = 2.4371e7);
# psi[3] = @variable(model, var_csi >= 0.0, start = 24371.5);
# psi[4] = @variable(model, var_omega >= 0.0, start = 24371.5);
@NLobjective(model, Max, get_likelihood(psi...));

set_optimizer_attribute(model, "max_iter", 200);
set_time_limit_sec(model, 120.0);

JuMP.optimize!(model);

# ============================================================
# FK ótimo
# ============================================================

a_otimo = Vector{Vector{Real}}(undef, n);
a_otimo[1] = zeros(13);
for index in 2:n
    a_otimo[index] = [];
    for i in 1:13
        push!(a_otimo[index], a[index][i]);
    end
end

# ============================================================
# Suavizador
# ============================================================
# Pega dados do FK
F_otimo = [x[1] for x in F_aux];

K_otimo = [[y for y in x] for x in K_aux];

V_otimo = zeros(n);
V_otimo[1] = V_aux[1][1];
V_otimo[2:end] = [x[1] for x in V_aux[2:end]];

P_otimo = P;
P_otimo[2:end] = [[y for y in x] for x in P[2:end]];

# Suavizador
r = Vector{Vector{Real}}(undef, n+1);
r[end] = zeros(13);
N = Vector{Array{Real, 2}}(undef, n+1);
N[end] = zeros(13,13);

for t in n:-1:1

    L = T - K_otimo[t]*Z;                                               # (13,13) - (13,1)*(1,13) = (13,13)
    r[t] = vec(Z' * ((F_otimo[t])^(-1)) * V_otimo[t] + L'*r[t+1]);      # (13,1)*(1,1)*(1,1) + (13,13)*(13,1) = (13,1)

    N[t] = Z' * ((F_otimo[t])^(-1)) * Z + L' * N[t+1] * L;              # (13,1)*(1,1)*(1,13) + (13,13)*(13,13)*(13,13) = (13,13)

end
for t in 1:n
    alpha_hat[t] = a_otimo[t] + P_otimo[t+1]*r[t];                      # (13,1) + (13,13)*(13,1) = (13,1)
    V_true = P_otimo[t+1] - P_otimo[t+1]*N[t]*P_otimo[t+1];  # (13,13) - (13,13)*(13,13)*(13,13) = (13,13)
end
# alpha_hat = a_otimo + P_otimo[2:end]*r[1:end-1];                      # (13,1) + (13,13)*(13,1) = (13,1)
# V_true = P_otimo[2:end] - P_otimo[2:end]*N[1:end-1]*P_otimo[2:end];  # (13,13) - (13,13)*(13,13)*(13,13) = (13,13)


# ============================================================
# Plot
# ============================================================

# Y
plot([x[1] for x in y], label = "Real")
plot!([(Z*x)[1] for x in a_otimo], label = "FK")
plot!([(Z*x)[1] for x in alpha_hat], label = "Smoother")

psi_val = value.(psi);
println("Level: $(psi_val[2])")
println("Slope: $(psi_val[3])")
println("Seasonal: $(psi_val[4])")
println("Irregular: $(psi_val[1])")

if false
    
    # Seasonality
    plot([(Z[:, 3:end]*x[3:end])[1] for x in alpha_hat], label = "Seasonality")

    # Level
    plot([x[1] for x in y], label = "Real")
    plot!([(Z[:, 1]*x[1])[1] for x in alpha_hat], label = "Level")

    # Slope
    plot([x[2] for x in alpha_hat], label = "Slope")
end