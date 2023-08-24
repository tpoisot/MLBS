import Random

function shapleyvalues(model, X, i::T, j::T; kwargs...) where {T <: Int}
    x = X[i,:]
    return shapleyvalues(model, X, x, j; kwargs...)
end

function shapleyvalues(model, X::Matrix{T}, x::Vector{T}, j; M=200) where {T <: Any}

    ϕ = zeros(Float64, M)
    b1 = copy(x)
    b2 = copy(x)

    for m in axes(ϕ, 1)
        O = Random.shuffle(axes(X, 2))
        w = X[sample(axes(X, 1)),:]

        bef = findall(O .< j)
        aft = findall(O .> j)

        b1[bef] .= x[bef]
        b1[j] = x[j]
        b1[aft] = w[aft]
        b2[bef] .= x[bef]
        b2[j] = w[j]
        b2[aft] = w[aft]

        ϕ[m] = model(b1) - model(b2)
    end

    return sum(ϕ)/M
end