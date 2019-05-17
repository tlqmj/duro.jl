@info "Starting"
using DifferentialEquations, Plots
@info "Packages loaded"

function rigid!(du, u, p, t)
    l_diag = sqrt(2.0)*p[:l₀]

    # Verticales
    @inbounds for j = 1:size(u,3), i = 1:(size(u,2)-1)
        c = (p[:l₀]/sqrt((u[3,i+1,j] - u[3,i,j])^2 + (u[4,i+1,j] - u[4,i,j])^2) - 1.0)

        k = c*(u[3,i+1,j] - u[3,i,j])
        du[1,i,j]   += k
        du[1,i+1,j] -= k

        k = c*(u[4,i+1,j] - u[4,i,j])
        du[2,i,j]   += k
        du[2,i+1,j] -= k
    end

    # Diagonales (\)
    @inbounds for j = (1:size(u,3)-1), i = 1:(size(u,2)-1)
        c = (l_diag/sqrt((u[3,i+1,j+1] - u[3,i,j])^2 + (u[4,i+1,j+1] - u[4,i,j])^2) - 1.0)

        k = c*(u[3,i+1,j+1] - u[3,i,j])
        du[1,i,j]     += k
        du[1,i+1,j+1] -= k

        k = c*(u[4,i+1,j+1] - u[4,i,j])
        du[2,i,j]     += k
        du[2,i+1,j+1] -= k
    end

    # Diagonales (/)
    @inbounds for j = (1:size(u,3)-1), i = 2:size(u,2)
        c = (l_diag/sqrt((u[3,i-1,j+1] - u[3,i,j])^2 + (u[4,i-1,j+1] - u[4,i,j])^2) - 1.0)

        k = c*(u[3,i-1,j+1] - u[3,i,j])
        du[1,i,j]     += k
        du[1,i-1,j+1] -= k

        k = c*(u[4,i-1,j+1] - u[4,i,j])
        du[2,i,j]     += k
        du[2,i-1,j+1] -= k
    end

    # Horizontales
    @inbounds for j=1:(size(u,3)-1), i =1:size(u,2)
        c = (p[:l₀]/sqrt((u[3,i,j+1] - u[3,i,j])^2 + (u[4,i,j+1] - u[4,i,j])^2) - 1.0)

        k = c*(u[3,i,j] - u[3,i,j+1])
        du[1,i,j]   += k
        du[1,i,j+1] -= k

        k = c*(u[4,i,j] - u[4,i,j+1])
        du[2,i,j]   += k
        du[2,i,j+1] -= k
    end


    @inbounds for j=1:size(u,3), i=1:size(u,2)
        du[1,i,j] *= p[:k_m]
        du[2,i,j] *= p[:k_m]
        du[3,i,j] =  u[1,i,j]
        du[4,i,j] =  u[2,i,j]
    end
end

function plot_lindo!(p, U; kwargs...)

    for i = 1:size(U,2), j = 1:size(U,3)
        p[i,j] = (U[3,i,j], U[4,i,j])
    end

    Plots.scatter(reshape(p, size(p,1)*size(p,2)); kwargs...)
end


N = 4;
u = zeros(Float64, (4,N,N))
p = (k_m=0.1, l₀ = 1.0)

for i = 1:size(u,2), j=1:size(u,3)
    u[3,i,j] = j*p[:l₀]
    u[4,i,j] = -i*p[:l₀]
end
u[3,1,1] += 0.25*p[:l₀]
u[4,1,1] += -0.25*p[:l₀]

tmax = 5.0
fps  = 10
t = (0.0, tmax)

buf = fill((0.0,0.0), (size(u,2), size(u,3)))
display(plot_lindo!(buf, u))

prob = ODEProblem(rigid!, u, t, p)
sol = solve(prob, progress=true, Rodas4P())
@info "System integrated"

Juno.progress(name = "Rendering") do id
    global sol
    anim = @animate for t = 1.0:1.0/fps:tmax
        plot_lindo!(buf, sol(t), xlims=(0.0,size(u,2)+1), ylims=(-(size(u,3)+1), 0.0))
        @info "Rendering" progress=t/(tmax*fps) _id=id
    end
    g = gif(anim, "$(pwd())/img/$(size(u,2))x$(size(u,3)).gif", fps=fps)
    mp4(anim, "$(pwd())/img/$(size(u,2))x$(size(u,3)).mp4", fps=fps)
    @info "Rendering" progress="done" _id=id
    return g
end
