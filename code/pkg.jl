_code_path = joinpath(dirname(Base.active_project()), "code")
_data_path = joinpath(dirname(Base.active_project()), "data")
_models_path = joinpath(dirname(Base.active_project()), "models")

ispath(_code_path) || mkpath(_code_path)
ispath(_data_path) || mkpath(_data_path)
ispath(_models_path) || mkpath(_models_path)

import JLD2
import StatsAPI
using CairoMakie
using Distributions
using GLM
using MultivariateStats
using SpeciesDistributionToolkit
using Statistics
using StatsBase
using Random
import CSV
using DataFrames
using PrettyTables
import JSON

set_theme!()
CairoMakie.activate!(; type = "png")
update_theme!(;
    backgroundcolor = :transparent,
    fontsize = 12,
    Figure = (; backgroundcolor = :transparent),
    Axis = (
        backgroundcolor = :transparent,
    ),
    CairoMakie = (; px_per_unit = 6),
)

rng = Random.default_rng()
Random.seed!(rng, 42069)

include(joinpath(_code_path, "palettes.jl"))