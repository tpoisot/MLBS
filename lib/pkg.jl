using DataFrames
import CSV
using GLM
using PrettyTables

import JLD

using Distributions

using Statistics

using CairoMakie
set_theme!()
CairoMakie.activate!(type = "png")
update_theme!(
    backgroundcolor=:transparent,
    Figure=(; backgroundcolor=:transparent),
    Axis=(
        backgroundcolor=:white,
    ),
    CairoMakie=(; px_per_unit=2),
)

using SpeciesDistributionToolkit

import Images
import Downloads

using Random
Random.seed!(12345)