# k-means data prep from the USGS files

using SpeciesDistributionToolkit
using DelimitedFiles
using CairoMakie

img_path = "data/kmeans/raw"
img_files = readdir(img_path; join=true)
filter!(contains(".TIF"), img_files)

function readLS9band(files, pattern; kwargs...)
    band_file = only(filter(contains("$(pattern).TIF"), files))
    return SpeciesDistributionToolkit._read_geotiff(band_file, SimpleSDMResponse; kwargs...)
end

#b5 = readLS9band(img_files, "B5")
#heatmap(b5)

bbox = (left=-72.8, right=-72.6, bottom=19.4, top=19.5)
#b5 = readLS9band(img_files, "B2"; bbox...)
#heatmap(b5)

nir = readLS9band(img_files, "B5"; bbox...)
swir = readLS9band(img_files, "B6"; bbox...)
blue = readLS9band(img_files, "B2"; bbox...)
green = readLS9band(img_files, "B3"; bbox...)
red = readLS9band(img_files, "B4"; bbox...)

T = SimpleSDMLayers._inner_type(red)

for layer in [red, green, blue, nir, swir]
    replace!(layer, nothing => zero(T))
end

R = convert(Matrix{Float16}, grid(red))
G = convert(Matrix{Float16}, grid(green))
B = convert(Matrix{Float16}, grid(blue))
S = convert(Matrix{Float16}, grid(swir))
N = convert(Matrix{Float16}, grid(nir))

writedlm("data/kmeans/cooked/red.dat", R)
writedlm("data/kmeans/cooked/green.dat", G)
writedlm("data/kmeans/cooked/blue.dat", B)
writedlm("data/kmeans/cooked/nir.dat", N)
writedlm("data/kmeans/cooked/swir.dat", S)
