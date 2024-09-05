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

for i in 1:11
    BIOX[i] = 0.1f0 .* BIOX[i]
end

# Save the layers
SpeciesDistributionToolkit._write_geotiff("data/occurrences/layers.tiff", BIOX)

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
buffer = pseudoabsencemask(WithinRadius, presencelayer; distance=2.0)
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

bgpoints = backgroundpoints((x -> x^0.7).(bgmask), round(Int, 1.35sum(presencelayer)); replace=false)
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

# Do the splits
_code_path = joinpath(dirname(Base.active_project()), "code")
include(joinpath(_code_path, "pkg.jl"))
include(joinpath(_code_path, "minisdm/pipelines.jl"))

occdata = df
coordinates = select(occdata, [:presence, :longitude, :latitude])
select!(occdata, Not(:latitude))
select!(occdata, Not(:longitude))
raw = copy(occdata)

y = occdata.presence
X = permutedims(Matrix(select(occdata, Not(:presence))))
trn, tst = holdout(y, X)
ty = y[tst]
tX = X[:,tst]
y = y[trn]
X = X[:,trn]

folds = kfold(y, X; k=20)
bags = bootstrap(y, X; n=20)

latlon=Matrix(coordinates[trn,[3,2]])

# Save the data
dpath = joinpath("data", "occurrences")
if !ispath(dpath)
    mkpath(dpath)
end

writedlm(joinpath(dpath, "training-features.csv"), X)
writedlm(joinpath(dpath, "training-labels.csv"), y)
writedlm(joinpath(dpath, "testing-features.csv"), tX)
writedlm(joinpath(dpath, "testing-labels.csv"), ty)
writedlm(joinpath(dpath, "coordinates.csv"), latlon)
open(joinpath(dpath, "crossvalidation.json"), "w") do f
    JSON.print(f, Dict([
        :bags => bags,
        :folds => folds
    ]), 4)
end

ldesc = layerdescriptions(dataprovider)
ldict = Dict()
for (k, v) in ldesc
    ldict[k] = Dict([:code => k])
    lparts = split(v, "(", limit=2)
    ldict[k][:description] = lparts[1]
    if length(lparts) == 2
        ldict[k][:information] = lparts[2][1:end-1]
    else
        ldict[k][:information] = ""
    end
end

open(joinpath(dpath, "layers.json"), "w") do f
    JSON.print(f, ldict, 4)
end
