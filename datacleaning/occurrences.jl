using DelimitedFiles
using DataFrames
import CSV
using SpeciesDistributionToolkit
using CairoMakie

spatial_extent = (left = 8.412, bottom = 41.325, right = 9.662, top = 43.060)
dataprovider = RasterData(CHELSA2, BioClim)

temperature = SimpleSDMPredictor(dataprovider; layer = "BIO1", spatial_extent...)
msklayer = SimpleSDMPredictor(RasterData(CHELSA1, BioClim); layer = "BIO1", spatial_extent...)
temperature = mask(msklayer, temperature)
heatmap(temperature, colormap=:lajolla)

# Data
BIOX = convert.(Float32, [mask(msklayer, SimpleSDMPredictor(dataprovider; layer = l, spatial_extent...)) for l in layers(dataprovider)])
for i in 2:length(BIOX)
    BIOX[i].left = BIOX[1].left
    BIOX[i].top = BIOX[1].top
    BIOX[i].bottom = BIOX[1].bottom
    BIOX[i].right = BIOX[1].right
end
SpeciesDistributionToolkit._write_geotiff("data/general/layers.tiff", BIOX)

rangifer = taxon("Sitta whiteheadi"; strict = false)
query = [
    "occurrenceStatus" => "PRESENT",
    "hasCoordinate" => true,
    "decimalLatitude" => (spatial_extent.bottom, spatial_extent.top),
    "decimalLongitude" => (spatial_extent.left, spatial_extent.right),
    "limit" => 300,
]
presences = occurrences(rangifer, query...)
for i in 1:12
    @info i
    occurrences!(presences)
end

presencelayer = mask(temperature, presences, Bool)
heatmap(presencelayer)

background = pseudoabsencemask(DistanceToEvent, presencelayer)
bgmask = background

heatmap(bgmask)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
scatter!(presences; color = :black)
current_figure()

bgpoints = backgroundpoints((x -> x^1.2).(bgmask), round(Int, 0.8sum(presencelayer)); replace=false)
replace!(bgpoints, false => nothing)
replace!(presencelayer, false => nothing)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
#heatmap!(bgmask; colormap = cgrad([:transparent, :white]; alpha = 0.3))
scatter!(keys(presencelayer); color = :black)
scatter!(keys(bgpoints); color = :red)
current_figure()

# Get the data
pr = keys(presencelayer)
ab = keys(bgpoints)

lon = vcat([p[1] for p in pr], [p[1] for p in ab])
lat = vcat([p[2] for p in pr], [p[2] for p in ab])
pre = vcat([true for p in pr], [false for p in ab])

# data
biox = [vcat([bx[p] for p in pr], [bx[p] for p in ab]) for bx in BIOX]

using DataFrames
import CSV

df = DataFrame(latitude=lat, longitude=lon, presence=pre)
for (i, l) in enumerate(layers(dataprovider))
    df[!,l] = biox[i]
end
CSV.write("data/general/observations.csv", df)
