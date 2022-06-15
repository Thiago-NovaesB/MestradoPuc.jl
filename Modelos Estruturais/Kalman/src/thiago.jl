using LinearAlgebra, DataFrames, CSV, Plots, Optim, Statistics

# ============================================================
# Ler dados 
# ============================================================
data = CSV.read("MER_T07_01.csv", DataFrame);
YYYYMM = data[!,"YYYYMM"]
index = mod.(YYYYMM,100) .!= 13 
Value = data[!,"Value"]
y = parse.(Float64,Value[index][1:588])
y_insample = y[1:120]
y_outofsample =y[121:132]
n = length(y_insample)

# ============================================================
# MEB com tendência linear local e sazonalidade estocástica 
# ============================================================

function MEE(s::Int)
    if s == 6
        m = 2*s + 1
    else
        m = 2*s + 2
    end
    Z = [1 0 1 0 1 0 1 0 1 0 1 0 1];
    Z = Z[1:m]
    T = zeros(m, m);
    T[1,1] = 1;
    T[1,2] = 1;
    T[2,2] = 1;
    for j in 1:s
        if j == 6
            break
        else
            c = [[cos(pi*j/6), -sin(pi*j/6)] [sin(pi*j/6), cos(pi*j/6)]];
            T[2*j+1:2*j+2, 2*j+1:2*j+2] = c
        end
    end
    if s == 6
        T[m, m] = -1;
    end
    R = I;
    return Z, T, R, m
end
s = 3
Z, T, R, m = MEE(s)
# ============================================================
# Inicialização
# ============================================================
# Big Kappa
a = Vector{Vector{Real}}(undef, n+1);
a[1] = zeros(m);
P = Vector{Array{Real, 2}}(undef, n+1);
P[1] = diagm([1e6 for _ in 1:m]);

# Resultados armazenados para o smoother
F_aux = Vector{Any}(undef, n);
K_aux = Vector{Any}(undef, n);
V_aux = Vector{Any}(undef, n);

# ============================================================
# Estimação do Filtro de Kalman e cálculo da log verossimilhança
# ============================================================

function get_minus_log_likelihood(des)

    des_epsilon, des_eta, des_csi, des_omega = des
    var_epsilon = des_epsilon^2
    var_eta = des_eta^2
    var_csi = des_csi^2
    var_omega = des_omega^2
    # H
    H = var_epsilon;
    # Q
    Q = zeros(m,m);
    Q[1,1] = var_eta;
    Q[2,2] = var_csi;
    for j in 3:m
        Q[j,j]=var_omega;
    end
    # FK
    likelihood = 0.0;
    for t in 1:n

        F = Z'*P[t]*Z + H;                        
        K = T*P[t]*Z * ((F)^(-1));               
        V = y_insample[t] - Z'*a[t];                        

        a[t+1] = T*a[t] + K*V;                    
        P[t+1] = T*P[t] * (T - K*Z')' + R*Q*R'; 

        if t > m
            likelihood += -log(2*pi)/2 + (-1/2)*log(F[1]) + (-1/2)*(V[1]^2)/F[1];
        end
        # Resultados armazenados para o smoother    
        F_aux[t] = F;
        K_aux[t] = K;
        V_aux[t] = V;
    end
    return -likelihood/(n-m)
end

res = optimize(get_minus_log_likelihood, [sqrt(var(y_insample)), sqrt(var(y_insample)), 1.0, 1.0], LBFGS(),Optim.Options(show_trace=true)) #NelderMead

function AIC(ll,q,n,w)
    return (1/(n-q))*(-2*(n-q)*ll+2*(q+w))
end
ll = -res.minimum*(n-m)
@show ll
@show AIC(ll ,m,n,4)
# ============================================================
# Suavizador
# ============================================================

# Suavizador
r = Vector{Vector{Real}}(undef, n+1);
r[end] = zeros(m);
N = Vector{Array{Real, 2}}(undef, n+1);
N[end] = zeros(m,m);
alpha_hat = Vector{Vector{Real}}(undef, n);
V_true = Vector{Matrix{Real}}(undef, n);


for t in n:-1:1
    L = T - K_aux[t]*Z';                                              
    r[t] = Z * ((F_aux[t])^(-1)) * V_aux[t] + L'*r[t+1];     
    N[t] = Z * ((F_aux[t])^(-1)) * Z' + L' * N[t+1] * L;            
end
for t in 1:n
    alpha_hat[t] = a[t] + P[t+1]*r[t];                     
    V_true[t] = P[t+1] - P[t+1]*N[t]*P[t+1]; 
end

# ============================================================
# Plot
# ============================================================

# Y
plot(y_insample, label = "Real", legend=:bottomright)
plot!([dot(Z,x) for x in a], label = "FK")
plot!([dot(Z,x) for x in alpha_hat], label = "Smoother")

savefig("figs\\filter_$(s).png")

psi_val = res.minimizer.^2;
println("Level: $(psi_val[2])")
println("Slope: $(psi_val[3])")
println("Seasonal: $(psi_val[4])")
println("Irregular: $(psi_val[1])")

# Seasonality
plot([dot(Z[3:end],x[3:end]) for x in alpha_hat], label = "Seasonality")
savefig("figs\\seasonality_$(s).png")
# Level
plot([x for x in y_insample], label = "Real")
plot!([dot(Z[1],x[1]) for x in alpha_hat], label = "Level")
savefig("figs\\level_$(s).png")

# Slope
plot([x[2] for x in alpha_hat], label = "Slope")
savefig("figs\\slope_$(s).png")
