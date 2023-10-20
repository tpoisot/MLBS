function naivebayes(y::Vector{Bool}, X::Matrix{T}; presence=0.5, transformation=nothing) where {T <: Number}
    Xpos = X[findall(y),:]
    Xneg = X[findall(.!y),:]
    if transformation == MultivariateStats.PCA
        pca = MultivariateStats.fit(PCA, permutedims(X))
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.predict(pca, permutedims(Xpos)), dims=2))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.predict(pca, permutedims(Xneg)), dims=2))
    end
    if transformation == MultivariateStats.Whitening
        wht = MultivariateStats.fit(Whitening, permutedims(X))
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.transform(wht, permutedims(Xpos)), dims=2))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), MultivariateStats.transform(wht, permutedims(Xneg)), dims=2))
    end
    if isnothing(transformation)
        pred_pos = vec(mapslices(x -> Normal(mean(x), std(x)), Xpos, dims=1))
        pred_neg = vec(mapslices(x -> Normal(mean(x), std(x)), Xneg, dims=1))
    end
    function inner_predictor(v::Vector{TN}) where { TN <: Number }
        if isnothing(transformation)
            V = copy(v)
        end
        if transformation == MultivariateStats.PCA
            V = MultivariateStats.predict(pca, v)
        end
        if transformation == MultivariateStats.Whitening
            V = MultivariateStats.transform(wht, v)
        end
        is_pos = prod(pdf.(pred_pos, V))
        is_neg = prod(pdf.(pred_neg, V))
        evid = presence * is_pos + (1.0 - presence) * is_neg
        return (presence * is_pos)/evid
    end
    return inner_predictor
end