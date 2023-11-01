function DaviesBouldin(X, C)
    centroids = C.centers
    assigns = C.assignments
    S = zeros(Float64, size(centroids, 2))
    M = zeros(Float64, (size(centroids, 2), size(centroids, 2)))
    for i in unique(assigns)
        this_cluster = findall(isequal(i), assigns)
        centr = centroids[:,i]
        pts = X[:,this_cluster]
        S[i] = mean(sqrt.([sum((centr .- pts[:,j]).^2.0) for j in axes(pts, 2)]))
        for j in unique(assignments(clusters))
            if i >=j
                M[i,j] = M[j,i] = sqrt(sum((centroids[:,i] .- centroids[:,j]).^2.0))
            end
        end
    end

    R = (S .+ S')./M
    D = mapslices(v -> maximum(filter(!isinf, v)), R; dims=2)
    return sum(D)/length(unique(assigns))
end