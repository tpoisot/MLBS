abstract type AbstractPredictionStep end
abstract type AbstractClassifier <: AbstractPredictionStep end
abstract type AbstractTransformer <: AbstractPredictionStep end

Base.@kwdef mutable struct Thresholder <: AbstractPredictionStep
    cutoff::Float64 = 0.5
end

StatsAPI.predict(thr::Thresholder, x::T) where {T <: Float64} = x >= thr.cutoff
StatsAPI.predict(thr::Thresholder, x::Vector{T}) where {T <: Float64} = x .>= thr.cutoff

mutable struct PredictionPipeline
    steps::Vector{<:AbstractPredictionStep}
end

PredictionPipeline(x...) = PredictionPipeline([x...])
PredictionPipeline(x) = PredictionPipeline([x])
Base.getindex(p::PredictionPipeline, i...) = PredictionPipeline(getindex(p.steps, i...))
Base.lastindex(p::PredictionPipeline) = lastindex(p.steps)
Base.length(p::PredictionPipeline) = length(p.steps)

function StatsAPI.predict(p::PredictionPipeline, x::Vector{T}) where {T <: Number}
    prediction = predict(p.steps[1], x)
    for step in p.steps[2:end]
        prediction = predict(step, prediction)
    end
    return prediction
end

function StatsAPI.predict(p::PredictionPipeline, X::Matrix{T}) where {T <: Number}
    return vec(mapslices(x -> predict(p, x), X; dims = 1))
end

#= test data =#
y = rand(Bool, 100)
X = rand(Float64, (4, length(y)))
for i in eachindex(y)
    if y[i]
        X[:,i] = 2X[:,i]
    end
end

mod = train(GaussianNaiveBayes, y, X)

pip = PredictionPipeline(mod, Thresholder())

predict(pip, X)