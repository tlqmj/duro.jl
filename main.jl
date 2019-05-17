@info "Starting..."
using DifferentialEquations, Plots
include("system.jl")
include("util.jl")
include("plotting.jl")

@info "Defining ODE system..."
N = M = 4;
p = (k_m=0.1, l₀ = 1.0)
t = (0.0, 5.0)

u₀ = uniform_grid(N, M, p[:l₀])
u₀[3,1,1] += 0.25*p[:l₀]
u₀[4,1,1] += -0.25*p[:l₀]

@info "Displaying initial positions."
buf = fill((0.0,0.0), (size(u₀,2), size(u₀,3)))
display(plot_lindo(u₀, buf=buf))

@info "Integrating ODE system..."
prob = ODEProblem(rigid!, u₀, t, p)
sol = solve(prob, progress=true, Rodas4P())

@info "Rendering..."
render(sol, buf=buf)
@info "Done."
