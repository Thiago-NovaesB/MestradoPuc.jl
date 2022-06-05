function create_filter(y;
    model,
    constant_in_time::Bool = true,
    input_variables::Bool = false)

    input = Input(model)

    options = Options(constant_in_time)

    sizes = load_sizes(input, options)

    prb = Problem(input, options, sizes)

    return prb
end

function load_sizes(input::Input, options::Options)

    model = input.model

    p, n = size(model[:y])
    m, r = size(model[:R])

    sizes = Sizes(n, p, m, r)
    return sizes
end