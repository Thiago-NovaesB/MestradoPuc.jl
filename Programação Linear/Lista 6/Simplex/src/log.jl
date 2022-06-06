function init_log(input::Simplex.Input)
    if input.verbose
        var = length(input.c)
        con = length(input.b)
        println("-----------Inicio do algoritmo Pontos interiores------------")
        println("O problema possui $var variaveis e $con restrições")
    end
end

function iteration_log(input::Simplex.Input,iter::Integer,z::Float64,dual_inf::Float64)
    if input.verbose
        println("-------------------------Iteração $(iter)-------------------------")
        println("Função objetivo: $(z)")
        println("Complementariedade dual: $(dual_inf)")
    end
end

function last_log(input::Simplex.Input, output::Simplex.Output)
    if input.verbose
        println("----------------------Fim do algoritmo----------------------")
        if output.termination_status == 1
            println("Status: Optimal")
            println("Função objetivo: $(output.z)")
        elseif output.termination_status == 2
            println("Status: Unbound")
            println("Função objetivo: Inf")
        elseif output.termination_status == 3
            println("Status: Infeasible")
            println("Função objetivo: -Inf")
        elseif output.termination_status == 0
            println("Status: Max iteration")
            println("Função objetivo: $(output.z)")
        end
    end
end