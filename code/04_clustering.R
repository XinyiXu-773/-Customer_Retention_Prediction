# 04_clustering.R
# Purpose: k-means clustering with elbow (WSS) + silhouette, plus profiling

source("code/01_data_cleaning.R")

prep_cluster_matrix <- function(df) {
  # Use core behavior variables; convert to numeric; scale for kmeans
  X <- df %>%
    transmute(
      num_purchases = num_purchases,
      weeks_since_last_purchase = weeks_since_last_purchase,
      satisfaction = satisfaction_num,
      discounted = as.numeric(discounted_rate_last_purchase)  # factor -> 1/2
    ) %>%
    scale() %>%
    as.matrix()

  X
}

evaluate_k <- function(X, k_grid = 2:10, nstart = 25) {
  set.seed(123)

  wss <- map_dbl(k_grid, ~{
    km <- kmeans(X, centers = .x, nstart = nstart)
    km$tot.withinss
  })

  sil <- map_dbl(k_grid, ~{
    km <- kmeans(X, centers = .x, nstart = nstart)
    ss <- silhouette(km$cluster, dist(X))
    mean(ss[, 3])
  })

  tibble(k = k_grid, wss = wss, silhouette = sil)
}

fit_kmeans <- function(X, k) {
  set.seed(123)
  kmeans(X, centers = k, nstart = 50)
}

profile_clusters <- function(df, cluster_id) {
  df %>%
    mutate(cluster = factor(cluster_id)) %>%
    group_by(cluster) %>%
    summarise(
      n = n(),
      churn_rate = mean(retained == "Churn"),
      avg_purchases = mean(num_purchases),
      avg_inactive_weeks = mean(weeks_since_last_purchase),
      avg_satisfaction = mean(satisfaction_num),
      discount_share = mean(discounted_rate_last_purchase == levels(discounted_rate_last_purchase)[2]),
      .groups = "drop"
    ) %>%
    arrange(desc(churn_rate))
}
