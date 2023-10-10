function noskill(labels::Vector{Bool})
    n = length(labels)
    p = mean(labels)
    tp = round(Int, n*(p^2))
    tn = round(Int, n*((1-p)^2))
    fp = round(Int, n*(p*(1-p)))
    fn = round(Int, n*((1-p)*p))
    ConfusionMatrix(tp, tn, fp, fn)
end