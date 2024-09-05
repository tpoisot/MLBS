using Images

function rscale(Y; q = (0.01, 0.99))
    m, M = quantile(vec(Y), q)
    return Images.clamp01.((Y .- m) ./ (M - m))
end

function colorcube(R, G, B)
    r = convert(Matrix{Float32}, R.grid)
    g = convert(Matrix{Float32}, G.grid)
    b = convert(Matrix{Float32}, B.grid)
    cube = zeros(Float32, (3, size(permutedims(b))...))

    qR = rscale(r)
    qG = rscale(g)
    qB = rscale(b)

    cube[1, :, :] .= reverse(rotl90(qR); dims=1)
    cube[2, :, :] .= reverse(rotl90(qG); dims=1)
    cube[3, :, :] .= reverse(rotl90(qB); dims=1)

    tfile = tempname() * ".png"
    save(tfile, map(Images.clamp01nan, Images.colorview(Images.RGB, cube)))
    return tfile
end