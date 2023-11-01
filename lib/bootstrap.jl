function _bootstrap(y, X)
    bag = sample(axes(X, 1), size(X, 1), replace=true)
    outofbag = setdiff(axes(X, 1), unique(bag))
    return (bag, outofbag)
end

function bootstrap(y, X; n=50)
    @assert size(y,1) == size(X, 1)
    return [_bootstrap(y, X) for _ in 1:n]
end