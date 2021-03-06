function init_log1(input::Simplex.Input)
    if input.verbose
        var = length(input.c)
        con = length(input.b)
        println("---------------Inicio do algoritmo Simplex 1----------------")
        println("O problema possui $var variaveis e $con restrições")
    end
end

function init_log2(input::Simplex.Input)
    if input.verbose
        var = length(input.c)
        con = length(input.b)
        println("---------------Inicio do algoritmo Simplex 2----------------")
        println("O problema possui $var variaveis e $con restrições")
    end
end

function iteration_log(input::Simplex.Input,midterm::Simplex.MidTerm)
    if input.verbose

        println("-------------------------Iteração $(midterm.iter)-------------------------")
        println("Base: $(midterm.base)")
        println("Não-Base: $(midterm.nbase)")
        println("Deixa a base: $(midterm.base[midterm.i])")
        println("Entra na base: $(midterm.nbase[midterm.j])")
        println("Função objetivo: $(midterm.z)")
        println("Variaveis: $(midterm.x)")
        println("Custo reduzido: $(midterm.red_cost)")
    end
end

function last_log(input::Simplex.Input, output::Simplex.Output)
    if input.verbose
        println("----------------------Fim do algoritmo----------------------")
        if output.termination_status == 1
            println("Status: Optimal")
            println("Base: $(output.base)")
            println("Não-Base: $(output.nbase)")
            println("Função objetivo: $(output.z)")
            println("Variaveis: $(output.x)")
        elseif output.termination_status == 2
            println("Status: Unbound")
            println("Base: $(output.base)")
            println("Não-Base: $(output.nbase)")
            println("Função objetivo: Inf")
            println("Direção extrema: $(output.x)")
        elseif output.termination_status == 3
            println("Status: Infeasible")
        elseif output.termination_status == 0
            println("Status: Max iteration")
            println("Base: $(output.base)")
            println("Não-Base: $(output.nbase)")
            println("Função objetivo: $(output.z)")
            println("Variaveis: $(output.x)")
        end
    end
end