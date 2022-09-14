function loglike(x)
    l = 0
    H .= H.^2
    Q .= Q.^2
    for t in 1:n
        v = y[t] - Z*a - d
        F = Z*P*Z' + Diagonal(H)
        a_t = a + P*Z'*F^(-1)*v
        a = T*a_t + c
        P_t = P - P*Z'*F^(-1)*Z*P
        P = T*P_t*T' + R*Diagonal(Q)*R'

        l += -1/2*logabsdet(F) - 1/2 v'*F*v
    end
    return l
end