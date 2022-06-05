function create_filter(y;
    Z, 
    T,
    d,
    c,
    R,
    Z_inf,
    Z_sup,
    T_inf,
    T_sup,
    d_inf,
    d_sup,
    c_inf,
    c_sup,
    R_inf,
    R_sup,
    Z_inf_t,
    Z_sup_t,
    T_inf_t,
    T_sup_t,
    d_inf_t,
    d_sup_t,
    c_inf_t,
    c_sup_t,
    R_inf_t,
    R_sup_t,
    constant_in_time::Bool = true,
    input_variables::Bool = false)

    input = Input(y, Z, T, d, c, R, Z_inf, Z_sup, T_inf, T_sup, d_inf, d_sup, c_inf, c_sup, R_inf, R_sup,
        Z_inf_t, Z_sup_t, T_inf_t, T_sup_t, d_inf_t, d_sup_t, c_inf_t, c_sup_t, R_inf_t, R_sup_t)

    options = Options(constant_in_time, input_variables)

    sizes = load_sizes(input, options)

    prb = Problem(input, options, sizes)

    return prb
end

function load_sizes(input::Input, options::Options)

    if options.constant_in_time && !options.input_variables
        n = size(input.y)[1]
        p = size(input.y)[2]
        m = size(input.R)[1]
        r = size(input.R)[2]
    if !options.constant_in_time && !options.input_variables
        n = size(input.y)[1]
        p = size(input.y)[2]
        m = size(input.R_t)[1]
        r = size(input.R_t)[2]
    if options.constant_in_time && options.input_variables
        n = size(input.y)[1]
        p = size(input.y)[2]
        m = size(input.R_inf)[1]
        r = size(input.R_inf)[2]
    else
        n = size(input.y)[1]
        p = size(input.y)[2]
        m = size(input.R_inf_t)[1]
        r = size(input.R_inf_t)[2]
    end

    sizes = Sizes(n, p, m, r)
    return sizes
end