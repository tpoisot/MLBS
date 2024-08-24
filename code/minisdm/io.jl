struct SDMSerialization
    y::Vector
    X::Matrix
    threshold::AbstractFloat
    variables::Vector{Int}
    classifier::Symbol
    transformer::Symbol
end

JLD2.writeas(::Type{SDM}) = SDMSerialization

function __tosymbol(cl::Type{T}) where T <: Classifier
    str = string(cl)
    contains("NBC", str) && return :NBC
    contains("BioClim", str) && return :BioClim
    return :NBC
end

function __tosymbol(tr::Type{T}) where T <: Transformer
    str = string(tr)
    contains("PCA", str) && return Symbol("MultivariateTransform{PCA}")
    contains("Whitening", str) && return Symbol("MultivariateTransform{Whitening}")
    contains("ZScore", str) && return :ZScore
    return :RawData
end

function Base.convert(::Type{SDMSerialization}, sdm::SDM)
    return SDMSerialization(
        model.y, model.X,
        model.τ, model.v,
        __tosymbol(model.classifier), __tosymbol(model.transformer)
    )
end

function Base.convert(::Type{SDM}, sdm::SDMSerialization)
    model = SDM(
        eval(sdm.transformer), eval(sdm.classifier),
        sdm.threshold, sdm.X, sdm.y,
        sdm.variables
    )
    return model
end
