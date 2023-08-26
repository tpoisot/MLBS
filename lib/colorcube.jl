using Images

function colorcube(R, G, B; scaler=2.75e-05)
    cube = zeros(eltype(B), (3, size(permutedims(B))...))
    cube[1,:,:] .= permutedims(R)
    cube[2,:,:] .= permutedims(G)
    cube[3,:,:] .= permutedims(B)

    tfile = tempname()*".png"
    save(tfile, map(clamp01nan, colorview(RGB, cube.*scaler)))
    return tfile
end