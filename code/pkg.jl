_code_path = joinpath(dirname(Base.active_project()), "code")

import JLD2
import StatsAPI
using CairoMakie
import GeoMakie
using Distributions
using GLM
using MultivariateStats
using SpeciesDistributionToolkit
using Statistics
using StatsBase
using Random

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

include(joinpath(_code_path, "palettes.jl"))

rng = Random.default_rng()
Random.seed!(rng, 12345)