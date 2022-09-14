using LinearAlgebra, DataFrames, CSV, Plots, Optim, Statistics, Distributions

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
s = 6
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

# have_date = Vector{Bool}(undef, n)
# have_date .= true

# have_date[14:19] .= false
# have_date[46:51] .= false
# have_date[78:83] .= false
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

V_standard = (V_aux ./ sqrt.(F_aux))[13:end]

p = plot(V_standard, label = "Inovação padronizada", legend=:bottomright)
savefig("figs\\inov.png")
p = histogram(V_standard,bins=15)
savefig("figs\\hist.png")
p = plot(autocor(V_standard))
savefig("figs\\FAC_inov.png")
p = plot(autocor((V_standard).^2))
savefig("figs\\FAC_inov2.png")



#F
fStat = sum((V_standard[80:end]).^2) / sum((V_standard[1:40]).^2)  
fDist = FDist(40, 40)
fCdf = cdf(fDist, fStat)
pValue = 1 - fCdf
 

#chi
fStat = 120/6*skewness(V_standard).^2 + 120/24*kurtosis(V_standard).^2
fDist = Chi(2)
fCdf = cdf(fDist, fStat)
pValue = 1 - fCdf

 value = (y_insample[14:19]-y_fill[14:19]).^2 + (y_insample[46:51] - y_fill[46:51]).^2 + (y_insample[78:83] - y_fill[78:83]).^2



 suave = [dot(Z[3:end],x[3:end]) for x in alpha_hat]
 janeiro = [1+12*i for i = 0:9]
 janeiro = suave[janeiro]
 feveveiro = [2+12*i for i = 0:9]
 feveveiro = suave[feveveiro]
 marco = [3+12*i for i = 0:9]
 marco = suave[marco]
 abril = [4+12*i for i = 0:9]
 abril = suave[abril]
 maio = [5+12*i for i = 0:9]
 maio = suave[maio]
 junho = [6+12*i for i = 0:9]
 junho = suave[junho]
 julho = [7+12*i for i = 0:9]
 julho = suave[julho]
 agosto = [8+12*i for i = 0:9]
 agosto = suave[agosto]
 setembro = [9+12*i for i = 0:9]
 setembro = suave[setembro]
 outubro = [10+12*i for i = 0:9]
 outubro = suave[outubro]
 novembro = [11+12*i for i = 0:9]
 novembro = suave[novembro]
 dezembro = [12+12*i for i = 0:9]
 dezembro = suave[dezembro]

 plot(janeiro, label = "janeiro")
 savefig("figs\\janeiro.png")
 plot(feveveiro, label = "feveveiro")
 savefig("figs\\feveveiro.png")
 plot(marco, label = "marco")
 savefig("figs\\marco.png")
 plot(abril, label = "abril")
 savefig("figs\\abril.png")
 plot(maio, label = "maio")
 savefig("figs\\maio.png")
 plot(junho, label = "junho")
 savefig("figs\\junho.png")
 plot(julho, label = "julho")
 savefig("figs\\julho.png")
 plot(agosto, label = "agosto")
 savefig("figs\\agosto.png")
 plot(setembro, label = "setembro")
 savefig("figs\\setembro.png")
 plot(outubro, label = "outubro")
 savefig("figs\\outubro.png")
 plot(novembro, label = "novembro")
 savefig("figs\\novembro.png")
 plot(dezembro, label = "dezembro")
 savefig("figs\\dezembro.png")

a_prev = zeros(12)

for t in 1:12
    F = Z'*P[]*Z + H;                        
    K = T*P[t]*Z*0.0 * ((F)^(-1));               
    V = y_insample[t] - Z'*a[t];                        

    a[t+1] = T*a[t];                    
    P[t+1] = T*P[t]; 
end
n = 132
a = Vector{Vector{Real}}(undef, n+1);
a[1] = zeros(m);
P = Vector{Array{Real, 2}}(undef, n+1);
P[1] = diagm([1e6 for _ in 1:m]);

# Resultados armazenados para o smoother
F_aux = Vector{Any}(undef, n);
K_aux = Vector{Any}(undef, n);
V_aux = Vector{Any}(undef, n);

have_date = Vector{Bool}(undef, n)
have_date .= true

have_date[121:132] .= false
function get_minus_log_likelihood_prev(des)

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
        K = T*P[t]*Z*have_date[t] * ((F)^(-1));               
        V = y[t] - Z'*a[t];                        

        a[t+1] = T*a[t] + K*V;                    
        P[t+1] = T*P[t] * (T - K*Z')' + R*Q*R'; 

        if t > m
            likelihood += (-log(2*pi)/2 + (-1/2)*log(F[1]) + (-1/2)*(V[1]^2)/F[1])*have_date[t];
        end
        # Resultados armazenados para o smoother    
        F_aux[t] = F;
        K_aux[t] = K;
        V_aux[t] = V;
    end
    return -likelihood/(n-m)
end

plot(y[121:132], label = "Original",legend=:bottomright)
plot!([dot(Z,x) for x in a[121:132]], label = "FK")
plot!([dot(Z,x) for x in a[121:132]] + 1.96*sqrt.(F_aux[121:132]), label = "FK + 1.96dp")
plot!([dot(Z,x) for x in a[121:132]] - 1.96*sqrt.(F_aux[121:132]), label = "FK - 1.96dp")
savefig("figs\\prev.png")