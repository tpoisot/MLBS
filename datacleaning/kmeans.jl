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

b5 = readLS9band(img_files, "B5")
heatmap(b5)
bbox = (left=9.05, right=9.27, bottom=41.35, top=41.5)
clp = clip(b5; bbox...)
@info size(clp)
heatmap(clp, colormap=:vik, aspect=DataAspect())

blue = readLS9band(img_files, "B2"; bbox...)
green = readLS9band(img_files, "B3"; bbox...)
red = readLS9band(img_files, "B4"; bbox...)
nir = readLS9band(img_files, "B5"; bbox...)
swir1 = readLS9band(img_files, "B6"; bbox...)
swir2 = readLS9band(img_files, "B7"; bbox...)

T = SimpleSDMLayers._inner_type(red)

for layer in [red, green, blue, nir, swir1, swir2]
    replace!(layer, nothing => zero(T))
end

R = convert(Matrix{Float16}, grid(red))
G = convert(Matrix{Float16}, grid(green))
B = convert(Matrix{Float16}, grid(blue))
S1 = convert(Matrix{Float16}, grid(swir1))
S2 = convert(Matrix{Float16}, grid(swir2))
N = convert(Matrix{Float16}, grid(nir))

writedlm("data/kmeans/cooked/red.dat", R)
writedlm("data/kmeans/cooked/green.dat", G)
writedlm("data/kmeans/cooked/blue.dat", B)
writedlm("data/kmeans/cooked/nir.dat", N)
writedlm("data/kmeans/cooked/swir1.dat", S1)
writedlm("data/kmeans/cooked/swir2.dat", S2)
