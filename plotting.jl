function plot_lindo(U; label="", kwargs...)
    Plots.scatter(reshape(U[3,:,:], size(U,2)*size(U,3)), reshape(U[4,:,:], size(U,2)*size(U,3)); label=label, kwargs...)
end

function render(
    sol;
    fps=10,
    xlims=(0.0,size(sol.u[1],2)+1),
    ylims=(-(size(sol.u[1],3)+1), 0.0))

    tmax = sol.t[end]
    M = size(sol.u[1], 2)
    N = size(sol.u[1], 3)

    Juno.progress(name = "Rendering...") do id

        anim = @animate for t = 0.0:1.0/fps:tmax
            plot_lindo(sol(t), xlims=xlims, ylims=ylims)
            @info "Rendering..." progress=t/tmax _id=id
        end

        g = gif(anim, "$(pwd())/img/$(M)x$(N).gif", fps=fps)
        mp4(anim, "$(pwd())/img/$(M)x$(N).mp4", fps=fps)

        display(g)
        @info "Rendering..." progress="done" _id=id
    end
end
