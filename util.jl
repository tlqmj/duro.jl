function uniform_grid(M, N, l₀=1.0)
    _l₀ = Float64(l₀)

    u = fill(SVector(0.0, 0.0), (2,M,N))
    for i = 1:M, j=1:N
        u[1,i,j] = SVector(j*_l₀, -i*_l₀)
    end

    return u
end
