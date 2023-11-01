Base.@kwdef mutable struct GaussianNaiveBayes{T <: Number}
    presences::Vector{Normal} = Normal[]
    absences::Vector{Normal} = Normal[]
    prior::T = 0.5
end

function train!(
    NBC::GaussianNaiveBayes,
    y::Vector{Bool},
    X::Matrix{T};
    prior=0.5
) where {T <: Number}
    X₊ = X[:, findall(y)]
    X₋ = X[:, findall(.!y)]
    NBC.presences = vec(mapslices(x -> Normal(mean(x), std(x)), X₊; dims = 2))
    NBC.absences = vec(mapslices(x -> Normal(mean(x), std(x)), X₋; dims = 2))
    NBC.prior = prior
    return NBC
end

function train(::Type{GaussianNaiveBayes}, y, X; kwdef...)
    return train!(GaussianNaiveBayes(), y, X; kwdef...)
end

function predict(NBC::GaussianNaiveBayes, x::Vector{T}) where {T <: Number}
    p₊ = prod(pdf.(NBC.presences, x))
    p₋ = prod(pdf.(NBC.absences, x))
    pₓ = NBC.prior * p₊ + (1.0 - NBC.prior) * p₋
    return (p₊ * NBC.prior) / pₓ
end

function predict(NBC::GaussianNaiveBayes, X::Matrix{T}) where {T <: Number}
    return vec(mapslices(x -> predict(NBC, x), X; dims = 1))
end
