function plot_lindo(U; buf=fill((0.0,0.0), (size(u,2), size(u,3))), label="", kwargs...)

    for i = 1:size(U,2), j = 1:size(U,3)
        buf[i,j] = (U[3,i,j], U[4,i,j])
    end

    Plots.scatter(reshape(buf, size(buf,1)*size(buf,2)); label=label, kwargs...)
end

function render(
    sol;
    fps=10,
    xlims=(0.0,size(sol.u[1],2)+1),
    ylims=(-(size(sol.u[1],3)+1), 0.0),
    buf = fill((0.0,0.0), (size(sol.u[1],2), size(sol.u[1],3))))

    tmax = sol.t[end]
    M = size(sol.u[1], 2)
    N = size(sol.u[1], 3)

    Juno.progress(name = "Rendering...") do id

        anim = @animate for t = 0.0:1.0/fps:tmax
            plot_lindo(sol(t), buf=buf, xlims=xlims, ylims=ylims)
            @info "Rendering..." progress=t/tmax _id=id
        end

        g = gif(anim, "$(pwd())/img/$(M)x$(N).gif", fps=fps)
        mp4(anim, "$(pwd())/img/$(M)x$(N).mp4", fps=fps)

        display(g)
        @info "Rendering..." progress="done" _id=id
    end
end
