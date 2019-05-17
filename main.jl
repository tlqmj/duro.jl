using DifferentialEquations, Makie, Plots, BenchmarkTools, Distributed, SharedArrays

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

function runbenchmarks(N)
    p = (k_m=1.0, l₀ = 1.0)

    u = zeros(Float64, (4,N,N))
    for i = 1:size(u,2), j=1:size(u,3)
        u[3,i,j] = j*p[:l₀]
        u[4,i,j] = -i*p[:l₀]
    end
    u[3,1,1] = 0.25*p[:l₀]
    u[4,1,1] = -0.25*p[:l₀]

    for f in (rigid!, rigid2!)
        du = zeros(Float64, size(u))
        @info f
        @btime $(f)(du, u, p, 0.0)
    end
end



prob = ODEProblem(rigid!, u, t, p)
sol = solve(prob, RadauIIA5(), progress=true)

Plots.plot(sol)
