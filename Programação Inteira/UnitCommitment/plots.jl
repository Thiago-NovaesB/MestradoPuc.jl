########################################################
@userplot StackedArea

@recipe function f(pc::StackedArea)
    x, y = pc.args
    n = length(x)
    y = cumsum(y, dims=2)
    seriestype := :shape

    # create a filled polygon for each item
    for c=1:size(y,2)
        sx = vcat(x, reverse(x))
        sy = vcat(y[:,c], c==1 ? zeros(n) : reverse(y[:,c-1]))
        @series (sx, sy)
    end
end

################################################################

function plot(parameter, prb, num)

    mat = [value.(prb.model[:generation])' sum(value.(prb.model[:deficit]),dims = 1)']

    caso = string(num);
    if parameter == "STACK"

        x = [1:24;];
        labels_gen = ["Gen_"*string(i) for i in 1:(size(mat,2)-1)];
        labels = push!(labels_gen,"Deficit");
        labels = hcat(labels...);
        display(stackedarea(x,mat,title = "Generation Solution",labels = labels, legend = :outertopleft,xlabel = "Time (h)", ylabel = "GW"));

        savefig(joinpath(raw"D:\Dropbox (PSR)\PUC\prog_inteira\COMMIT","PRB_"*caso*".pdf"));

    end


end