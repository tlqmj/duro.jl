@info "Starting..."
using DifferentialEquations, Makie, JLD2, FileIO
include("system.jl")
include("util.jl")
include("plotting.jl")

@info "Defining ODE system..."
N = M = 3;
p = (k_m=0.2, l₀ = 1.0)
t = (0.0, 60.0)

u₀ = uniform_grid(N, M, p[:l₀])
u₀[3,:,1] .+= 0.3*p[:l₀]
#u₀[4,1,1] += -0.25*p[:l₀]

@info "Displaying initial positions."
scene = plot_lindo(u₀)

@info "Integrating ODE system..."
prob = ODEProblem(rigid!, u₀, t, p)
@time sol = solve(prob, progress=true, force_dtmin=true, DifferentialEquations.TRBDF2())

@info "Saving solution to $(pwd())/data/$(N)x$(M).jld"
@save "$(pwd())/data/$(N)x$(M).jld" sol

@info "Rendering..."
@time render(sol)
@info "Done."
