abstract type SDMTransformer end
abstract type SDMClassifier end
abstract type SDMThresholder end

# Thresholder

Base.@kwdef mutable struct Thresholder{T <: Number} <: SDMThresholder
    cutoff::T = 0.5
end
function train!(thr::Thresholder, y, yhat)
    values = LinRange(extrema(yhat)..., 100)
    C = [ConfusionMatrix(yhat, y, v) for v in values]
    thr.cutoff = values[last(findmax(mcc.(C)))]
    return thr
end
StatsAPI.predict(thr::Thresholder, X) = X .>= thr.cutoff

# No transformation

struct RawData <: SDMTransformer end
train!(rd::RawData, args...) = nothing
StatsAPI.predict(rd::RawData, X) = X

# z-score
Base.@kwdef mutable struct ZScore <: SDMTransformer
    μ::AbstractArray = zeros(1)
    σ::AbstractArray = zeros(1)
end
function train!(zs::ZScore, X; kwdef...)
    zs.μ = vec(mean(X; dims = 2))
    zs.σ = vec(std(X; dims = 2))
    return zs
end
function StatsAPI.predict(zs::ZScore, x::AbstractArray)
    return (x .- zs.μ) ./ (zs.σ)
end

# SDM pipeline

mutable struct SDM
    transformer::SDMTransformer
    classifier::SDMClassifier
    threshold::SDMThresholder
end

function train!(sdm::SDM, y, X; transform = true, classify = true)
    if transform
        train!(sdm.transformer, X)
    end
    X₁ = predict(sdm.transformer, X)
    train!(sdm.classifier, y, X₁)
    ŷ = predict(sdm.classifier, X₁)
    ŷ[findall(isnan.(ŷ))] .= 0.0
    if classify
        train!(sdm.threshold, y, ŷ)
    end
    return sdm
end

function StatsAPI.predict(sdm::SDM, X; classify = true)
    X₁ = predict(sdm.transformer, X)
    ŷ = predict(sdm.classifier, X₁)
    if length(ŷ) > 1
        ŷ[findall(isnan.(ŷ))] .= 0.0
    else
        ŷ = isnan(ŷ) ? 0.0 : ŷ
    end
    if classify
        return predict(sdm.threshold, ŷ)
    else
        return ŷ
    end
end

function iqr(x)
    if all(isnan.(x))
        return 0.0
    else
        return first(diff(quantile(filter(!isnan, x), [0.25, 0.75])))
    end
end

#=
# Demo data

X = rand(Float64, 4, 100)
y = rand(Bool, size(X, 2))
X[:,findall(y)] .+= 0.25

model = SDM(ZScore(), NBC(), Thresholder())
train!(model, y, X)
yhat = predict(model, X; classify=false)
ConfusionMatrix(yhat, y) |> mcc
=#