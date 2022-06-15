using LinearAlgebra, DataFrames, CSV, Plots, Optim, Statistics, StatsBase

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

function diff(y, t)
    out = zeros(length(y)-t)
    for i in 1:length(y)-t
        out[i] = y[i+t] - y[i]
    end
    return out
end

p = plot(y_insample,label = "y",legend=:bottomright)
savefig("figs\\y.png")
p = plot(autocov(y_insample),label = "FAC")
savefig("figs\\FAC.png")
p = plot(autocov(diff(y_insample, 1)),label = "FAC y\'")
savefig("figs\\FAC y\'.png")
p = plot(autocov(diff(y_insample, 12)),label = "FAC y\' (12)")
savefig("figs\\FAC y\' (12).png")