function _generate_perm!(b1, b2, X, j)
    O = Random.shuffle(axes(X, 2))
    w = X[sample(axes(X, 1)), :]
    i = only(indexin(j, O))
    for (idx, pos) in enumerate(O)
        if idx < i
            b1[pos] = x[pos]
            b2[pos] = x[pos]
        end
        if idx > i
            b1[pos] = w[pos]
            b2[pos] = w[pos]
        end
        if idx == i
            b1[pos] = x[pos]
            b2[pos] = w[pos]
        end
    end
end

function shapley(model, X, i::T, j::T; kwargs...) where {T<:Int}
    return shapley(model, X, X[i, :], j; kwargs...)
end

function shapley(model, X::Matrix{T1}, x::Vector{T2}, j; M=200, kwargs...) where {T1<:Number,T2<:Number}

    ϕ = zeros(Float64, M)
    b1 = copy(x)
    b2 = copy(x)

    for m in axes(ϕ, 1)

        still_looking = true
        while still_looking
            _generate_perm!(b1, b2, X, j)
            ϕ[m] = model(b1) - model(b2)
            still_looking = isnan(ϕ[m])
        end
    end

    return mean(filter(!isnan, ϕ))
end