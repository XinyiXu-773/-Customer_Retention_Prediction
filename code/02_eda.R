# 02_eda.R
# Purpose: reproduce core EDA outputs (distribution + relationships)

source("code/01_data_cleaning.R")

run_eda <- function(df) {

  # Retention distribution
  p_retention <- df %>%
    count(retained) %>%
    mutate(pct = n / sum(n)) %>%
    ggplot(aes(x = retained, y = pct)) +
    geom_col() +
    scale_y_continuous(labels = percent) +
    labs(x = NULL, y = "Share", title = "Retention Rate Distribution")

  # Satisfaction vs retention
  p_satisfaction <- df %>%
    count(satisfaction_survey, retained) %>%
    ggplot(aes(x = satisfaction_survey, y = n, fill = retained)) +
    geom_col(position = "stack") +
    labs(x = "Satisfaction (ordinal)", y = "Count", title = "Satisfaction vs Retention")

  # Retention by weeks since last purchase
  p_recency <- df %>%
    group_by(weeks_since_last_purchase) %>%
    summarise(retention_rate = mean(retained == "Retained"), .groups = "drop") %>%
    ggplot(aes(x = weeks_since_last_purchase, y = retention_rate)) +
    geom_line() +
    scale_y_continuous(labels = percent) +
    labs(x = "Weeks Since Last Purchase", y = "Retention Rate", title = "Retention Rate by Purchase Week")

  list(
    p_retention = p_retention,
    p_satisfaction = p_satisfaction,
    p_recency = p_recency
  )
}
