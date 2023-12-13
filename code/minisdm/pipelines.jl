import StatsAPI
import LinearAlgebra
using MultivariateStats
using Distributions

abstract type Transformer end
abstract type Classifier end

mutable struct SDM{F,L}
    transformer::Transformer
    classifier::Classifier
    τ::Number # Threshold
    X::Matrix{F} # Features
    y::Vector{L} # Labels
    v::AbstractVector # Variables
end

include("univariatetransforms.jl")
include("multivariatetransforms.jl")
include("nbc.jl")
include("confusionmatrix.jl")
include("crossvalidation.jl")
include("mocks.jl")
include("vif.jl")
include("variableselection.jl")

function train!(sdm::SDM; threshold=true, training=:, optimality=mcc)
    train!(sdm.transformer, sdm.X[sdm.v,training])
    X₁ = predict(sdm.transformer, sdm.X[sdm.v,training])
    train!(sdm.classifier, sdm.y[training], X₁)
    ŷ = predict(sdm.classifier, X₁)
    ŷ[findall(isnan.(ŷ))] .= 0.0
    if threshold
        thr_range = LinRange(extrema(ŷ)..., 100)
        C = [ConfusionMatrix(ŷ, sdm.y[training], thr) for thr in thr_range]
        sdm.τ = thr_range[last(findmax(optimality, C))]
    end
    return sdm
end

function StatsAPI.predict(sdm::SDM, X; threshold = true)
    X₁ = predict(sdm.transformer, X[sdm.v,:])
    ŷ = predict(sdm.classifier, X₁)
    ŷ = isone(length(ŷ)) ? ŷ[1] : ŷ
    if length(ŷ) > 1
        ŷ[findall(isnan.(ŷ))] .= 0.0
    else
        ŷ = isnan(ŷ) ? 0.0 : ŷ
    end
    if threshold
        return ŷ .>= sdm.τ
    else
        return ŷ
    end
end

function StatsAPI.predict(sdm::SDM; kwargs...)
    return StatsAPI.predict(sdm::SDM, sdm.X; kwargs...)
end

function reset!(sdm::SDM)
    sdm.v = collect(axes(sdm.X, 1))
    sdm.τ = 0.5
    return sdm
end

function predictors(sdm::SDM)
    return copy(sdm.v)
end

#=
# Demo data

X = rand(Float64, 8, 100)
v = 1:4
training = unique(rand(axes(X, 2), 70))
y = rand(Bool, size(X, 2))
X[:,findall(y)] .+= 0.25

sdm = SDM(MultivariateTransform{PCA}(), NBC(), 0.5, X, y, v)
train!(sdm; training=training)
yhat = predict(sdm, X)
ConfusionMatrix(yhat, y) |> mcc
=#
