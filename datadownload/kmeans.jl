# k-means data prep from the USGS files

using SpeciesDistributionToolkit
using DelimitedFiles
using CairoMakie

img_path = "data/kmeans/raw/LC09_L2SP_014028_20230621_20230623_02_T1/"
all_files = readdir(img_path; join=true)
bands = filter(contains(r"SR_B\d.TIF"), all_files)

function readLS9band(files, pattern; kwargs...)
    band_file = only(filter(contains("$(pattern).TIF"), files))
    return SpeciesDistributionToolkit._read_geotiff(band_file, SimpleSDMResponse; kwargs...)
end

testband = readLS9band(bands, "B6")
heatmap(testband, colormap=:Spectral)

begin
    bbox = (left=-74.0, right=-73.75, bottom=45.39, top=45.525)
    clp = clip(testband; bbox...)
    @info size(clp)
    f = Figure()
    ax = CairoMakie.Axis(f[1,1], aspect=DataAspect())
    heatmap!(ax, clp, colormap=:Spectral)
    f
end

function get_and_correct_band(img_files, bid, bbox)
    raw_bd = readLS9band(img_files, "B$(bid)"; bbox...)
    scaled =  raw_bd .* 0.0000275 .- 0.2
    normed = (scaled .+ 0.199972)./(1.602213 + 0.199972)
    return normed
end

blue = get_and_correct_band(bands, 2, bbox)
green = get_and_correct_band(bands, 3, bbox)
red = get_and_correct_band(bands, 4, bbox)
nir = get_and_correct_band(bands, 5, bbox)
swir1 = get_and_correct_band(bands, 6, bbox)
swir2 = get_and_correct_band(bands, 7, bbox)

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

begin
    Y = ndvi
    f = Figure()
    ax = CairoMakie.Axis(f[1,1], aspect=DataAspect())
    hm = heatmap!(ax, permutedims(Y), colormap=:viridis)
    Colorbar(f[1,2], hm)
    f
end