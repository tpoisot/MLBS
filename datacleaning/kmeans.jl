# k-means data prep from the USGS files

using SpeciesDistributionToolkit
using DelimitedFiles

img_path = "data/kmeans/raw"
img_files = readdir(img_path; join=true)
filter!(contains(".TIF"), img_files)

function readLS9band(files, pattern; kwargs...)
    band_file = only(filter(contains("$(pattern).TIF"), files))
    return convert(Float32, SpeciesDistributionToolkit._read_geotiff(band_file, SimpleSDMResponse; kwargs...))
end

bbox = (left=-103.0, right=-102.0, bottom=35.5, top=36.5)

nir = readLS9band(img_files, "B5"; bbox...)
swir = readLS9band(img_files, "B6"; bbox...)
blue = readLS9band(img_files, "B2"; bbox...)
green = readLS9band(img_files, "B3"; bbox...)
red = readLS9band(img_files, "B4"; bbox...)

replace!(red, nothing => 0.0f0)
replace!(green, nothing => 0.0f0)
replace!(blue, nothing => 0.0f0)
replace!(nir, nothing => 0.0f0)
replace!(swir, nothing => 0.0f0)

R = convert(Matrix{Float32}, grid(red))
G = convert(Matrix{Float32}, grid(green))
B = convert(Matrix{Float32}, grid(blue))
S = convert(Matrix{Float32}, grid(swir))
N = convert(Matrix{Float32}, grid(nir))

idx = 1500:2200

writedlm("data/kmeans/cooked/red.dat", R[idx, idx])
writedlm("data/kmeans/cooked/green.dat", G[idx, idx])
writedlm("data/kmeans/cooked/blue.dat", B[idx, idx])
writedlm("data/kmeans/cooked/nir.dat", N[idx, idx])
writedlm("data/kmeans/cooked/swir.dat", S[idx, idx])
