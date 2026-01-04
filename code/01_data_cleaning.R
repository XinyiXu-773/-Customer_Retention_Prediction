# 01_data_cleaning.R
# Purpose: read data, clean, derive modeling-ready dataset

source("code/00_setup.R")

read_and_clean <- function(path = "platefulnz_customers.csv") {
  raw <- read_csv(path, show_col_types = FALSE)

  df <- raw %>%
    # Standardize target to factor with levels c("Retained", "Churn")
    mutate(
      retained = make_retention_factor(retained_binary),
      # satisfaction_survey in your report is ordinal 1–5 plus NoResponse
      satisfaction_survey = factor(
        satisfaction_survey,
        levels = c("NoResponse", "1", "2", "3", "4", "5"),
        ordered = TRUE
      ),
      # Keep a numeric version for clustering
      satisfaction_num = as.numeric(satisfaction_survey),  # NoResponse becomes 1
      discounted_rate_last_purchase = factor(discounted_rate_last_purchase)
    ) %>%
    # Minimal cleaning: drop duplicates, keep complete cases for core predictors
    distinct() %>%
    filter(
      !is.na(num_purchases),
      !is.na(weeks_since_last_purchase),
      !is.na(satisfaction_survey),
      !is.na(discounted_rate_last_purchase),
      !is.na(retained)
    )

  list(raw = raw, df = df)
}
