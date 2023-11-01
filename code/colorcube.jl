function rscale(Y; q=(0.01, 0.99))
    m, M = quantile(vec(Y), q)
    return Images.clamp01.((Y .- m)./(M - m))
end

function colorcube(R, G, B; natural=false)
    cube = zeros(eltype(B), (3, size(permutedims(B))...))

    if natural
        qR = Images.clamp01.((R .- 0.10) ./ 0.18)
        qG = Images.clamp01.((G .- 0.10) ./ 0.13)
        qB = Images.clamp01.((B .- 0.10) ./ 0.15)
    else
        qR = rscale(R)
        qG = rscale(G)
        qB = rscale(B)
    end

    cube[1,:,:] .= permutedims(qR)
    cube[2,:,:] .= permutedims(qG)
    cube[3,:,:] .= permutedims(qB)

    tfile = tempname()*".png"
    save(tfile, map(Images.clamp01nan, Images.colorview(Images.RGB, cube)))
    return tfile
end