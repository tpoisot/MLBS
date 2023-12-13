using GLM

vif(m) = 1 / (1 - r²(m))

function stepwisevif!(model::SDM, threshold)
    return stepwisevif!(model, model.v, threshold)
end

function stepwisevif!(model::SDM, threshold)
    Xv = model.X[model.v,:]
    X = (Xv .- mean(Xv; dims = 2)) ./ std(Xv; dims = 2)
    vifs = zeros(Float64, length(model.v))
    for i in eachindex(model.v)
        linreg = lm(Xv[setdiff(eachindex(model.v), i), :]', Xv[i, :])
        vifs[i] = vif(linreg)
    end
    all(vifs .<= threshold) && return model
    drop = last(findmax(vifs))
    popat!(model.v, drop)
    #@info "Variables remaining: $(model.v)"
    return stepwisevif!(model, threshold)
end