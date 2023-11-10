function bootstrap(y, X; n = 50)
    @assert size(y, 1) == size(X, 2)
    bags = []
    for i in 1:n
        inbag = sample(1:size(X, 2), size(X, 2); replace = true)
        outbag = setdiff(axes(X, 2), inbag)
        push!(bags, (inbag, outbag))
    end
    return bags
end