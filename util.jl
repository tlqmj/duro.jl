function uniform_grid(N, M, l₀=1.0)
    u = zeros(Float64, (4,N,M))

    for i = 1:N, j=1:M
        u[3,i,j] = j*l₀
        u[4,i,j] = -i*l₀
    end

    return u
end
