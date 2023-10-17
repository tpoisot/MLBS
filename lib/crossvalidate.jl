function crossvalidate(model, y, X, folds, args...; kwargs...)
    C = zeros(ConfusionMatrix, length(folds))
    for (i,f) in enumerate(folds)
        trn, val = f
        foldmodel = model(y[trn], X[trn,:]; kwargs...)
        foldpred = vec(mapslices(foldmodel, X[val,:]; dims=2))
        C[i] = ConfusionMatrix(foldpred, y[val], args...)
    end
    return C
end