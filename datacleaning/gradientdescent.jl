using DelimitedFiles
using SpeciesDistributionToolkit
using CairoMakie

spatial_extent = (left = 3.0, bottom = 55.2, right = 19.7, top = 64.9)

rangifer = taxon("Rangifer tarandus tarandus"; strict = false)
query = [
    "occurrenceStatus" => "PRESENT",
    "hasCoordinate" => true,
    "decimalLatitude" => (spatial_extent.bottom, spatial_extent.top),
    "decimalLongitude" => (spatial_extent.left, spatial_extent.right),
    "limit" => 300,
]
presences = occurrences(rangifer, query...)
for i in 1:3
    occurrences!(presences)
end

dataprovider = RasterData(CHELSA1, BioClim)
temperature = 0.1SimpleSDMPredictor(dataprovider; layer = "BIO1", spatial_extent...)

heatmap(temperature)

presencelayer = mask(temperature, presences, Bool)

heatmap(presencelayer)

background = pseudoabsencemask(WithinRadius, presencelayer; distance = 120.0)
buffer = pseudoabsencemask(WithinRadius, presencelayer; distance = 25.0)
bgmask = background .& (.! buffer)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
heatmap!(bgmask; colormap = cgrad([:transparent, :white]; alpha = 0.3))
scatter!(presences; color = :black)
current_figure()

bgpoints = SpeciesDistributionToolkit.sample(bgmask, floor(Int, 0.25sum(presencelayer)))

replace!(bgpoints, false => nothing)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
heatmap!(bgmask; colormap = cgrad([:transparent, :white]; alpha = 0.3))
scatter!(presences; color = :black)
scatter!(keys(bgpoints); color = :red)
current_figure()

# Get the data
replace!(presencelayer, false => nothing)
pr = keys(presencelayer)
ab = keys(bgpoints)

lon = vcat([p[1] for p in pr], [p[1] for p in ab])
lat = vcat([p[2] for p in pr], [p[2] for p in ab])
pre = vcat([true for p in pr], [false for p in ab])

# Data
BIO1 = SimpleSDMPredictor(dataprovider; layer = "BIO1", spatial_extent...)
BIO2 = SimpleSDMPredictor(dataprovider; layer = "BIO2", spatial_extent...)
BIO3 = SimpleSDMPredictor(dataprovider; layer = "BIO3", spatial_extent...)
BIO4 = SimpleSDMPredictor(dataprovider; layer = "BIO4", spatial_extent...)
BIO12 = SimpleSDMPredictor(dataprovider; layer = "BIO12", spatial_extent...)

# data
bio1 = vcat([BIO1[p] for p in pr], [BIO1[p] for p in ab])
bio2 = vcat([BIO2[p] for p in pr], [BIO2[p] for p in ab])
bio3 = vcat([BIO3[p] for p in pr], [BIO3[p] for p in ab])
bio4 = vcat([BIO4[p] for p in pr], [BIO4[p] for p in ab])
bio12 = vcat([BIO12[p] for p in pr], [BIO12[p] for p in ab])

using DataFrames
import CSV

df = DataFrame(latitude=lat, longitude=lon, presence=pre, bio1=bio1, bio2=bio2, bio3=bio3, bio4=bio4, bio12=bio12)
mkdir("data/gradientdescent")
CSV.write("data/gradientdescent/climate.csv", df)
