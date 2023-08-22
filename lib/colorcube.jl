using Images

function colorcube(R, G, B; scaler=2.75e-05)
    cube = zeros(eltype(B), (3, size(B)...))
    cube[1,:,:] .= R
    cube[2,:,:] .= G
    cube[3,:,:] .= B

    tfile = tempname()*".png"
    save(tfile, map(clamp01nan, colorview(RGB, cube.*scaler)))
    return tfile
end