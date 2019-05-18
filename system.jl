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

        k = c*(u[3,i,j+1] - u[3,i,j])
        du[1,i,j]   += k
        du[1,i,j+1] -= k

        k = c*(u[4,i,j+1] - u[4,i,j])
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
