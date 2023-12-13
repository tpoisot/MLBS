function backwardselection(
    model,
    y,
    X,
    folds,
    perf,
    args...;
    verbose::Bool = false,
    kwargs...,
)
    pool = collect(axes(X, 1))
    best_perf = -Inf
    while ~isempty(pool)
        if verbose
            @info "N = $(length(pool))"
        end
        scores = zeros(length(pool))
        Threads.@threads for i in eachindex(pool)
            this_pool = deleteat!(copy(pool), i)
            scores[i] = mean(
                perf.(
                    first(
                        crossvalidate(model, y, X[this_pool, :], folds, args...; kwargs...),
                    )
                ),
            )
        end
        best, i = findmax(scores)
        if best > best_perf
            best_perf = best
            deleteat!(pool, i)
        else
            if verbose
                @info "Returning with $(pool) -- $(best_perf)"
            end
            break
        end
    end
    return pool
end

function constrainedselection(
    model,
    y,
    X,
    folds,
    pool,
    perf,
    args...;
    verbose::Bool = false,
    kwargs...,
)
    on_top = filter(p -> !(p in pool), collect(axes(X, 1)))
    best_perf = -Inf
    while ~isempty(on_top)
        if verbose
            @info "N = $(length(pool)+1)"
        end
        scores = zeros(length(on_top))
        for i in eachindex(on_top)
            this_pool = push!(copy(pool), on_top[i])
            scores[i] = mean(
                perf.(
                    first(
                        crossvalidate(model, y, X[this_pool, :], folds, args...; kwargs...),
                    )
                ),
            )
        end
        best, i = findmax(scores)
        if best > best_perf
            best_perf = best
            push!(pool, on_top[i])
            deleteat!(on_top, i)
        else
            if verbose
                @info "Returning with $(pool) -- $(best_perf)"
            end
            break
        end
    end
    return pool
end

function forwardselection(model, y, X, folds, perf, args...; kwargs...)
    pool = Int64[]
    return constrainedselection(model, y, X, folds, pool, perf, args...; kwargs...)
end