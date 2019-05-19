# `u` is a (2,M,N) matrix of SVectors where u[1,i,j] is the position of
# of particle (i,j) and u[2,i,j] is it's velocity.

"""
    rigid!(du, u, p, t)

Defines the system of equations for a solid modeled as particles linked by springs.
    
`u` is a (2,M,N) matrix of SVectors where u[1,i,j] is the position of
of particle (i,j) and u[2,i,j] is it's velocity.
`p` is a named touple with two components: `k_m` which is the spring constant `k`
divided by the mass `m`, and `l₀` which is the natural length between the particles.
"""
function rigid!(du, u, p, t)

    M = size(u,2)
    N = size(u,3)
    l₀_diag = sqrt(2.0)*p[:l₀]

    # Verticales
    @inbounds for i = 1:(M-1), j = 1:N
        add_acc_component!(du, u, p[:l₀], i, j, +1, 0)
    end

    # Diagonales (\)
    @inbounds for i = 1:(M-1), j = (1:N-1)
        add_acc_component!(du, u, l₀_diag, i, j, +1, +1)
    end

    # Diagonales (/)
    @inbounds for i = 2:M, j = (1:N-1)
        add_acc_component!(du, u, l₀_diag, i, j, -1, +1)
    end

    # Horizontales
    @inbounds for i =1:M, j=1:(N-1)
        add_acc_component!(du, u, p[:l₀], i, j, 0, +1)
    end

    @inbounds for i = 1:M, j = 1:N
        du[2,i,j] *= p[:k_m]
        du[1,i,j] =  u[2,i,j]
    end
end

@inline function add_acc_component!(du, u, l₀, i::Integer, j::Integer, di::Integer, dj::Integer)

    Δr = u[1,i+di,j+dj] - u[1,i,j]
    am_k = Δr*(l₀/norm(Δr) - 1.0)

    du[2,i,j]   -= am_k
    du[2,i+di,j+dj] += am_k

end
