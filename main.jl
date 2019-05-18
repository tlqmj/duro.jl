@info "Starting..."
using DifferentialEquations, Plots, JLD2, FileIO
include("system.jl")
include("util.jl")
include("plotting.jl")

@info "Defining ODE system..."
N = M = 5;
p = (k_m=0.1, l₀ = 1.0)
t = (0.0, 15.0)

u₀ = uniform_grid(N, M, p[:l₀])
u₀[3,1,1] += 0.25*p[:l₀]
u₀[4,1,1] += -0.25*p[:l₀]

@info "Displaying initial positions."
buf = fill((0.0,0.0), (size(u₀,2), size(u₀,3)))
display(plot_lindo(u₀, buf=buf))

@info "Integrating ODE system..."
prob = ODEProblem(rigid!, u₀, t, p)
@time sol = solve(prob, progress=true, DifferentialEquations.Rodas5())

@info "Saving solution to $(pwd())/data/$(N)x$(M).jld"
@save "$(pwd())/data/$(N)x$(M).jld" sol

@info "Rendering..."
render(sol, buf=buf)
@info "Done."
