# k-means data prep from the USGS files

using SpeciesDistributionToolkit
using DelimitedFiles
using CairoMakie

img_path = "data/kmeans/raw/LC08_L2SP_017024_20230602_20230607_02_T1/"
all_files = readdir(img_path; join=true)
bands = filter(contains(r"SR_B\d.TIF"), all_files)

function readLS9band(files, pattern; kwargs...)
    band_file = only(filter(contains("$(pattern).TIF"), files))
    return SpeciesDistributionToolkit._read_geotiff(band_file, SimpleSDMResponse; kwargs...)
end

testband = readLS9band(img_files, "B6")
heatmap(testband, colormap=:Spectral)

bbox = (left=-76.3, right=-76.15, bottom=51.1, top=51.25)
clp = clip(testband; bbox...)
@info size(clp)
heatmap(clp, colormap=:Spectral)

function get_and_correct_band(img_files, bid, bbox)
    raw_bd = readLS9band(img_files, "B$(bid)"; bbox...)
    scaled =  raw_bd .* 0.0000275 .- 0.2
    normed = (scaled .+ 0.199972)./(1.602213 + 0.199972)
    return normed
end

blue = get_and_correct_band(img_files, 2, bbox)
green = get_and_correct_band(img_files, 3, bbox)
red = get_and_correct_band(img_files, 4, bbox)
nir = get_and_correct_band(img_files, 5, bbox)
swir1 = get_and_correct_band(img_files, 6, bbox)
swir2 = get_and_correct_band(img_files, 7, bbox)

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

ndvi = @. (N - R) / (N + R)
ndwi = @. (G - N) / (G + N)
ndmi = @. (N - S1) / (N + S1)

fig, ax, hm = heatmap(permutedims(ndwi), colormap=:Spectral, colorrange=(-0.1, 0.1))
Colorbar(fig[:, end+1], hm)
fig
