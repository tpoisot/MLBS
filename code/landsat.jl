using DelimitedFiles

contraststretch(M, m) = clamp01.(M ./ m)

function readlandsat(_data_path)
    B = readdlm(joinpath(_data_path, "blue.dat")); # Band 2
    G = readdlm(joinpath(_data_path, "green.dat")); # Band 3
    R = readdlm(joinpath(_data_path, "red.dat"));   # Band 4
    N = readdlm(joinpath(_data_path, "nir.dat")); # Band 5
    S1 = readdlm(joinpath(_data_path, "swir1.dat")); # Band 6
    S2 = readdlm(joinpath(_data_path, "swir2.dat")); # Band 7

    return (R,B,G,N,S1,S2)
end