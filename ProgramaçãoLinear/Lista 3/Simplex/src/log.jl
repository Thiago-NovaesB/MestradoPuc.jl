function init_log(input::Simplex.Input)
    if input.verbose == 1
        var = length(input.c)
        con = length(input.b)
        println("----------------Inicio do algoritmo Simplex-----------------")
        println("O problema possui $var variaveis e $con restrições")
    end
end

function iteration_log(input::Simplex.Input, iter::Int, base::Vector{Int}, nbase::Vector{Int}, i::Int, j::Int, z::Float64, x::Vector{Float64}, red_cost::Vector{Float64})
    if input.verbose == 1
        println("-------------------------Iteração $iter-------------------------")
        println("Base: $base")
        println("Não-Base: $nbase")
        println("Deixa a base: $i")
        println("Entra na base: $j")
        println("Função objetivo: $z")
        println("Variaveis: $x")
        println("Custo reduzido: $red_cost")
    end
end

function last_log(input::Simplex.Input, termination_status::Int, base::Vector{Int}, nbase::Vector{Int}, z::Float64, x::Vector{Float64})
    if input.verbose == 1
        println("----------------------Fim do algoritmo----------------------")
        if termination_status == 1
            println("Status: Optimal")
            println("Base: $base")
            println("Não-Base: $nbase")
            println("Função objetivo: $z")
            println("Variaveis: $x")
        else
            println("Status: Unbound")
            println("Base: $base")
            println("Não-Base: $nbase")
            println("Função objetivo: Inf")
            println("Direção extrema: $x")
        end
    end
end