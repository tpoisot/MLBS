using GLM

vif(m) = 1 / (1 - r²(m))

function stepwisevif(X::Matrix{T}, threshold) where {T <: Number}
    return stepwisevif(X, collect(1:size(X, 2)), threshold)
end

function stepwisevif(X::Matrix{T}, v, threshold) where {T <: Number}
    X = (X .- mean(X; dims = 1)) ./ std(X; dims = 1)
    vifs = zeros(Float64, length(v))
    for i in eachindex(v)
        begin
            # GLM gives warning with matrices
            model = lm(X[:, setdiff(eachindex(v), i)], X[:, i])
            vifs[i] = vif(model)
        end
    end
    all(vifs .<= threshold) && return v
    drop = last(findmax(vifs))
    popat!(v, drop)
    @info "Variables remaining: $(v)"
    return stepwisevif(X, v, threshold)
end