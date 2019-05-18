function plot_lindo(
    U;
    label="",
    limits = FRect(0, -(size(U,3)+1), size(U,2)+1, (size(U,3)+1)),
    kwargs...)

    scatter(reshape(U[3,:,:], size(U,2)*size(U,3)), reshape(U[4,:,:], size(U,2)*size(U,3)); label=label, limits=limits, kwargs...)
end

function render(
    sol;
    fps=10,
    limits = FRect(0, -(size(sol.u[1],3)+1), size(sol.u[1],2)+1, (size(sol.u[1],3)+1)))

    tmax = sol.t[end]
    M = size(sol.u[1], 2)
    N = size(sol.u[1], 3)

    scene = plot_lindo(sol(0.0), limits = limits)
    record(scene, "$(pwd())/img/$(M)x$(N).mp4", framerate=fps) do io
        @progress name="Rendering..." for t = 0.0:1.0/fps:tmax
            u = sol(t)
            push!(scene.plots[end].input_args[1], reshape(u[3,:,:], size(u,2)*size(u,3)))
            push!(scene.plots[end].input_args[2], reshape(u[4,:,:], size(u,2)*size(u,3)))
            recordframe!(io)
        end
    end
end
