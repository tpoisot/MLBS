using Images

function rscale(Y; q=(0.001, 0.999))
    m, M = quantile(vec(Y), q)
    return clamp01.((Y .- m)./(M - m))
end

function colorcube(R, G, B; natural=false)
    cube = zeros(eltype(B), (3, size(permutedims(B))...))

    qR = rscale(R)
    qG = rscale(G)
    qB = rscale(B)

    cube[1,:,:] .= permutedims(qR)
    cube[2,:,:] .= permutedims(qG)
    cube[3,:,:] .= permutedims(qB)

    tfile = tempname()*".png"
    save(tfile, map(clamp01nan, colorview(RGB, cube)))
    return tfile
end