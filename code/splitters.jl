function bootstrap(y, X; n = 50)
    @assert size(y, 1) == size(X, 1)
    return [sample(1:size(X, 1), size(X, 1); replace = true) for i in 1:n]
end