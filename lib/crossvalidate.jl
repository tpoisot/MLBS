function crossvalidate(model, y, X, folds, args...; kwargs...)
    Cv = zeros(ConfusionMatrix, length(folds))
    Ct = zeros(ConfusionMatrix, length(folds))
    for (i,f) in enumerate(folds)
        trn, val = f
        foldmodel = model(y[trn], X[trn,:]; kwargs...)
        foldpred = vec(mapslices(foldmodel, X[val,:]; dims=2))
        Cv[i] = ConfusionMatrix(foldpred, y[val], args...)
        ontrn = vec(mapslices(foldmodel, X[trn,:]; dims=2))
        Ct[i] = ConfusionMatrix(ontrn, y[trn], args...)
    end
    return Cv, Ct
end

function iqr(x)
    if all(isnan.(x))
        return 0.0
    else
        return first(diff(quantile(filter(!isnan, x), [0.25, 0.75])))
    end
end
