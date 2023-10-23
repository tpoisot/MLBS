function naivebayes(y::Vector{Bool}, X::Matrix{T}; presence=0.5, transformation=nothing) where {T <: Number}
    μ = mean(X; dims=1)
    σ = std(X; dims=1)
    Z = (X .- μ) ./ σ
    Xpos = Z[findall(y),:]
    Xneg = Z[findall(.!y),:]
    if transformation == MultivariateStats.PCA
        pca = MultivariateStats.fit(PCA, permutedims(Z))
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.predict(pca, permutedims(Xpos)), dims=2))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.predict(pca, permutedims(Xneg)), dims=2))
    end
    if transformation == MultivariateStats.Whitening
        wht = MultivariateStats.fit(Whitening, permutedims(Z))
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.transform(wht, permutedims(Xpos)), dims=2))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.transform(wht, permutedims(Xneg)), dims=2))
    end
    if isnothing(transformation)
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), Xpos, dims=1))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), Xneg, dims=1))
    end
    function inner_predictor(v::Vector{TN}) where { TN <: Number }
        V = (v .- vec(μ))./vec(σ)
        if transformation == MultivariateStats.PCA
            V = MultivariateStats.predict(pca, V)
        end
        if transformation == MultivariateStats.Whitening
            V = MultivariateStats.transform(wht, V)
        end
        is_pos = prod(pdf.(pred_pos, V))
        is_neg = prod(pdf.(pred_neg, V))
        evid = presence * is_pos + (1.0 - presence) * is_neg
        return (presence * is_pos)/evid
    end
    return inner_predictor
end

function entropy(f)
    p = [f, 1-f]
    if minimum(p) == 0.0
        return 0.0
    end
    return -sum(p .* log2.(p))
end