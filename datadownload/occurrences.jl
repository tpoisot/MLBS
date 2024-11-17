using DelimitedFiles
using DataFrames
import CSV
using SpeciesDistributionToolkit
using CairoMakie

spatial_extent = (left = 8.53, bottom = 41.325, right = 9.58, top = 43.040)
dataprovider = RasterData(CHELSA2, BioClim)

COR = SpeciesDistributionToolkit.gadm("FRA", "Corse")

# Data
BIOX = convert.(SDMLayer{Float32}, [SDMLayer(dataprovider; layer = l, spatial_extent...) for l in layers(dataprovider)])

# Mask and trim the layer
for i in eachindex(BIOX)
    BIOX[i] = SpeciesDistributionToolkit.trim(mask!(BIOX[i], COR))
end

# Temperature correction
for i in 1:11
    BIOX[i] = 0.1f0 .* BIOX[i]
end

# Save the layers
SimpleSDMLayers._write_geotiff("data/occurrences/layers.tiff", BIOX)

sitta = taxon("Sitta whiteheadi"; strict = false)
query = [
    "occurrenceStatus" => "PRESENT",
    "hasCoordinate" => true,
    "limit" => 300,
]
presences = occurrences(sitta, BIOX[1], query...)
while length(presences) < count(presences)
    occurrences!(presences)
end

presencelayer = SpeciesDistributionToolkit.mask(BIOX[1], presences)
heatmap(presencelayer)

background = pseudoabsencemask(DistanceToEvent, presencelayer)
nodata!(background, v -> v <= 2.1)
heatmap(background)

heatmap(
    BIOX[1];
    colormap = :deep,
    axis = (; aspect = DataAspect()),
    figure = (; size = (800, 500)),
)
scatter!(presences; color = :black)
current_figure()

absencelayer = backgroundpoints(background.^0.7, round(Int, 1.3sum(presencelayer)); replace=false)
nodata!(absencelayer, false)
nodata!(presencelayer, false)

heatmap(
    BIOX[1];
    colormap = :Greys,
    axis = (; aspect = DataAspect()),
    figure = (; size = (800, 500)),
)
scatter!(presencelayer; color = :orange, markersize=6)
scatter!(absencelayer; color = :red, markersize=4)
current_figure()

# Get the data
pr = transpose(SimpleSDMLayers._centers(presencelayer))
ab = transpose(SimpleSDMLayers._centers(absencelayer))

lonlat = vcat(pr, ab)
pre = vcat([true for p in axes(pr, 1)], [false for p in axes(ab, 1)])

# data
biox = [[bx[lonlat[j,:]...] for j in axes(lonlat, 1)] for bx in BIOX]

df = DataFrame(latitude=lonlat[:,2], longitude=lonlat[:,1], presence=pre)
for (i, l) in enumerate(layers(dataprovider))
    df[!,l] = biox[i]
end

# Do the splits
_code_path = joinpath(dirname(Base.active_project()), "code")
include(joinpath(_code_path, "pkg.jl"))

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

folds = kfold(y, X; k=10)
bags = bootstrap(y, X; n=64)

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
