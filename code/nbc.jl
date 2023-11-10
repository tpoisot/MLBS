Base.@kwdef mutable struct NBC <: SDMClassifier
    presences::Vector{Normal} = Normal[]
    absences::Vector{Normal} = Normal[]
    prior::Float64 = 0.5
end

function train!(
    nbc::NBC,
    y::Vector{Bool},
    X::Matrix{T};
    prior=0.5
) where {T <: Number}
    X₊ = X[:, findall(y)]
    X₋ = X[:, findall(.!y)]
    nbc.presences = vec(mapslices(x -> Normal(mean(x), std(x)), X₊; dims = 2))
    nbc.absences = vec(mapslices(x -> Normal(mean(x), std(x)), X₋; dims = 2))
    nbc.prior = prior
    return nbc
end

function train(::Type{NBC}, y, X; kwdef...)
    return train!(NBC(), y, X; kwdef...)
end

function StatsAPI.predict(nbc::NBC, x::Vector{T}) where {T <: Number}
    p₊ = prod(pdf.(nbc.presences, x))
    p₋ = prod(pdf.(nbc.absences, x))
    pₓ = nbc.prior * p₊ + (1.0 - nbc.prior) * p₋
    return (p₊ * nbc.prior) / pₓ
end

function StatsAPI.predict(nbc::NBC, X::Matrix{T}) where {T <: Number}
    return vec(mapslices(x -> predict(nbc, x), X; dims = 1))
end
