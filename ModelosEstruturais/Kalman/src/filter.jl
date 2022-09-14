function update_v_t()
    if constant_in_time
        midterm.v = y[t] - Z*a
    else
        midterm.v = y[t] - Z*a
    end
end