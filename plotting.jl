function plot_lindo(
    U;
    label="",
    limits = FRect(0, -(size(U,3)+1), size(U,2)+1, (size(U,3)+1)),
    kwargs...)

    scatter(reshape(U[3,:,:], size(U,2)*size(U,3)), reshape(U[4,:,:], size(U,2)*size(U,3)); label=label, limits=limits, kwargs...)
end

function render(
    sol;
    fps=24,
    path = "$(pwd())/img/$(size(sol.u[1], 2))x$(size(sol.u[1], 3)).mp4",
    limits = FRect(0, -(size(sol.u[1],3)+1), size(sol.u[1],2)+1, (size(sol.u[1],3)+1)))

    tmax = sol.t[end]

    scene = plot_lindo(sol(0.0), limits = limits)
    record(scene, path, framerate=fps) do io
        for t = 0.0:1.0/fps:tmax
            u = sol(t)
            push!(scene.plots[end].input_args[1], reshape(u[3,:,:], size(u,2)*size(u,3)))
            push!(scene.plots[end].input_args[2], reshape(u[4,:,:], size(u,2)*size(u,3)))
            recordframe!(io)
            Base.CoreLogging.@logmsg(-1,"Rendering...",_id = :Render, message="$(t)s", progress=t/tmax)
        end
    end
    Base.CoreLogging.@logmsg(-1,"Rendering...",_id = :Render, progress="done")
    @info "Saved animation to $path"
end
