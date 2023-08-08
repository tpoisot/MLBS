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

bgpoints = SpeciesDistributionToolkit.sample(
    bgmask,
    cellsize(bgmask),
    floor(Int, 0.5sum(presencelayer)),
)

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