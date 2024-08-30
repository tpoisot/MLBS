using DelimitedFiles
using DataFrames
import CSV
using SpeciesDistributionToolkit
using CairoMakie

spatial_extent = (left = 8.53, bottom = 41.325, right = 9.58, top = 43.040)
dataprovider = RasterData(CHELSA1, BioClim)

temperature = SimpleSDMPredictor(dataprovider; layer = "BIO1", spatial_extent...)
heatmap(temperature, colormap=[:black, :black])

# Data
BIOX = convert.(Float32, [SimpleSDMPredictor(dataprovider; layer = l, spatial_extent...) for l in layers(dataprovider)])

# Save the layers
SpeciesDistributionToolkit._write_geotiff("data/general/layers.tiff", BIOX)

sitta = taxon("Sitta whiteheadi"; strict = false)
query = [
    "occurrenceStatus" => "PRESENT",
    "hasCoordinate" => true,
    "decimalLatitude" => (spatial_extent.bottom, spatial_extent.top),
    "decimalLongitude" => (spatial_extent.left, spatial_extent.right),
    "limit" => 300,
]
presences = occurrences(sitta, query...)
while length(presences) < count(presences)
    occurrences!(presences)
end

presencelayer = SpeciesDistributionToolkit.mask(temperature, presences, Bool)
heatmap(presencelayer)

background = pseudoabsencemask(DistanceToEvent, presencelayer)
buffer = pseudoabsencemask(WithinRadius, presencelayer; distance=2.5)
bgmask = SpeciesDistributionToolkit.mask(buffer, background)

heatmap(bgmask)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
scatter!(presences; color = :black)
current_figure()

bgpoints = backgroundpoints((x -> x^0.6).(bgmask), round(Int, 0.8sum(presencelayer)); replace=false)
replace!(bgpoints, false => nothing)
replace!(presencelayer, false => nothing)

heatmap(
    temperature;
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; resolution = (800, 500)),
)
scatter!(keys(presencelayer); color = :black, markersize=6)
scatter!(keys(bgpoints); color = :red, markersize=4)
current_figure()

# Get the data
pr = keys(presencelayer)
ab = keys(bgpoints)

lon = vcat([p[1] for p in pr], [p[1] for p in ab])
lat = vcat([p[2] for p in pr], [p[2] for p in ab])
pre = vcat([true for p in pr], [false for p in ab])

# data
biox = [vcat([bx[p] for p in pr], [bx[p] for p in ab]) for bx in BIOX]

df = DataFrame(latitude=lat, longitude=lon, presence=pre)
for (i, l) in enumerate(layers(dataprovider))
    df[!,l] = biox[i]
end
CSV.write("data/general/observations.csv", df)