using DataFrames
import CSV
using GLM
using PrettyTables

using MultivariateStats

import JLD

using Distributions

using Statistics

using CairoMakie
set_theme!()
CairoMakie.activate!(; type = "png")
update_theme!(;
    backgroundcolor = :transparent,
    Figure = (; backgroundcolor = :transparent),
    Axis = (
        backgroundcolor = :white,
    ),
    CairoMakie = (; px_per_unit = 2),
)

using SpeciesDistributionToolkit

import Images
import Downloads

import Random
rng = Random.default_rng()
Random.seed!(rng, 12345)

function iqr(x)
    if all(isnan.(x))
        return 0.0
    else
        return first(diff(quantile(filter(!isnan, x), [0.25, 0.75])))
    end
end
