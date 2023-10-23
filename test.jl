using Shapley

function shmod(x)
    @info x
    return vec(mapslices(model, x, dims=2))
end

Shapley.shapley(shmod, Shapley.MonteCarlo(200), Tables.table(X), 1)
