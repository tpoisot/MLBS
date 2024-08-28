function loss(model, x, xprime, yhat, λ; kwargs...)
    fhat = predict(model, xprime; kwargs...)
    D1 = λ * (fhat - yhat) ^ 2.0
    S = zeros(Float64, length(model.v))
    for (i,v) in enumerate(model.v)
        S[i] = abs(x[i]-xprime[i]) / median(x[v] .- median(model.X[v,:]))
    end
    return D1 + sum(S)
end