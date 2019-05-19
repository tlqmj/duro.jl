@info "Starting..."
using LinearAlgebra, StaticArrays, DifferentialEquations, Makie
using BSON: @save, @load
include("system.jl")
include("util.jl")
include("plotting.jl")

@info "Defining ODE system..."
N = M = 3;
p = (k_m=0.2, l₀ = 1.0)
t = (0.0, 60.0)

u₀ = uniform_grid(M, N, p[:l₀])
u₀[1,:,1] .+= [SVector(0.3*p[:l₀], 0)]

@info "Displaying initial positions."
display(plot_lindo(u₀))

@info "Integrating ODE system..."
prob = ODEProblem(rigid!, u₀, t, p)
@time sol = solve(prob, progress=true, force_dtmin=true, DifferentialEquations.TRBDF2())

@save "$(pwd())/data/$(N)x$(M).bson" sol
@info "Saved solution to $(pwd())/data/$(N)x$(M).bson"

@info "Rendering..."
render(sol)
@info "Done."
