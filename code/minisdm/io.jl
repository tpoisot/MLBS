function savesdm(model::SDM, path)
    transformer = Symbol(typeof(model.transformer))
    classifier = Symbol(typeof(model.classifier))
    JLD2.jldsave(
        path;
        y = model.y,
        X = model.X,
        threshold = model.τ,
        variables = model.v,
        transformer = transformer,
        classifier = classifier,
    )
end

function loadsdm(path; kwargs...)
    # List of transformers
    __ltransfo = Dict([
        :ZScore => ZScore,
        :RawData => RawData,
        Symbol("Main.Notebook.RawData") => RawData, # TODO Automate the way to prefix symbols when saving the models
        Symbol("MultivariateTransform{Whitening}") => MultivariateTransform{Whitening},
        Symbol("MultivariateTransform{PCA}") => MultivariateTransform{PCA},
    ])
    # List of classifiers
    __lclass = Dict([
        :NBC => NBC,
        :BioClim => BioClim
    ])
    JLD2.jldopen(path) do modelspec
        global X = modelspec["X"]
        global y = modelspec["y"]
        global threshold = modelspec["threshold"]
        global variables = modelspec["variables"]
        global transformer = __ltransfo[modelspec["transformer"]]
        global classifier = __lclass[modelspec["classifier"]]
    end
    model = SDM(transformer(), classifier(), threshold, X, y, variables)
    train!(model; kwargs...)
    return model
end