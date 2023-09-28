using DelimitedFiles
using DataFrames
import CSV
using SpeciesDistributionToolkit
using CairoMakie

spatial_extent = (left = 4.0, bottom = 55.0, right = 29.0, top = 72.0)
args = (resolution = 5.0, )

dataprovider = RasterData(WorldClim2, BioClim)

temperature = SimpleSDMPredictor(dataprovider; layer = "BIO1", spatial_extent..., args...)
heatmap(temperature, colormap=:lajolla)

# Data
BIOX = [SimpleSDMPredictor(dataprovider; layer = l, spatial_extent...) for l in layers(dataprovider)]
SpeciesDistributionToolkit._write_geotiff("data/general/rangifer-layers.tiff", BIOX)

rangifer = taxon("Rangifer tarandus tarandus"; strict = false)
query = [
    "occurrenceStatus" => "PRESENT",
    "hasCoordinate" => true,
    "decimalLatitude" => (spatial_extent.bottom, spatial_extent.top),
    "decimalLongitude" => (spatial_extent.left, spatial_extent.right),
    "limit" => 300,
]
presences = occurrences(rangifer, query...)
for i in 1:20
    @info i
    occurrences!(presences)
end

presencelayer = mask(temperature, presences, Bool)
heatmap(presencelayer)

background = pseudoabsencemask(WithinRadius, presencelayer; distance = 200.0)
buffer = pseudoabsencemask(WithinRadius, presencelayer; distance = 50.0)
bgmask = .!(background .| (.! buffer))

heatmap(bgmask)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
heatmap!(bgmask; colormap = cgrad([:transparent, :white]; alpha = 0.3))
scatter!(presences; color = :black)
current_figure()

bgpoints = SpeciesDistributionToolkit.sample(bgmask, floor(Int, 0.5sum(presencelayer)))
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

# data
biox = [vcat([bx[p] for p in pr], [bx[p] for p in ab]) for bx in BIOX]

using DataFrames
import CSV

df = DataFrame(latitude=lat, longitude=lon, presence=pre)
for (i, l) in enumerate(layers(dataprovider))
    df[!,l] = biox[i]
end
CSV.write("data/general/rangifer-observations.csv", df)
