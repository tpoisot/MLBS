using DataFrames
import CSV
using GLM
using PrettyTables

import JLD

#import Suppressor

using Statistics

using CairoMakie
CairoMakie.activate!(; px_per_unit = 2)
using GeoMakie

using SpeciesDistributionToolkit

import Downloads

using Random
Random.seed!(12345)