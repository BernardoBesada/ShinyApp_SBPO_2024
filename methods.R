
min_max <- function(arr){
    return((arr - min(arr))/(max(arr) - min(arr)))
}

reverse_min_max <- function(arr){
    return((arr - max(arr))/(min(arr) - max(arr)))
}

spearman_cor <- function(x, y){
    rank_x <- rank(x, ties.method = "average")
    rank_y <- rank(y, ties.method = "average")
    return( cov(rank_x, rank_y)/(sd(rank_x)*sd(rank_y)))
}

spearman_cor_matrix <- function(mat){
    cor_matrix <- outer(
      colnames(mat), 
      colnames(mat), 
      Vectorize(function(i,j) spearman_cor(mat[, i], mat[,j]))
    )
    return(cor_matrix)
}

geomean <- function(arr){
    return(exp(mean(log(arr))))
}

MABAC <- function(mat){
    stds <- apply(mat, 2, sd)
    cors_matrix <- spearman_cor_matrix(mat)
    conflict_measure <- apply(1-cors_matrix, 2, sum)
    info <- stds*conflict_measure
    return(info/sum(info))
}

CRITIC <- function(mat, weights){
    weighted <- sweep((mat + 1), 2, weights, "*")
    border <- apply(weighted, 2, geomean)
    distance <- sweep(weighted, 2, border, "-")
    score <- apply(distance, 1, sum)
    return(score)
}

calculate_scores <- function(num_values, normalization){
    num_values[, !normalization] <- apply(num_values[, !normalization, drop = FALSE], 2, min_max)
    num_values[, normalization] <- apply(num_values[, normalization, drop = FALSE], 2, reverse_min_max)
    weights <- MABAC(num_values)
    scores <- CRITIC(num_values, weights)

    return(list("Criteria" = colnames(num_values), "Scores" = scores, "Weights" = weights))
}
