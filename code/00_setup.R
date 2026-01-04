# 00_setup.R
# Purpose: libraries, global options, reproducibility helpers

suppressPackageStartupMessages({
  library(tidyverse)
  library(tidymodels)
  library(readr)
  library(scales)
  library(car)        # VIF
  library(cluster)    # silhouette
})

theme_set(theme_minimal())

set.seed(123)

# Helper: enforce factor levels so yardstick "event_level = second" == Churn
make_retention_factor <- function(x) {
  # x may be 0/1 or labels
  if (is.numeric(x) || is.integer(x)) {
    x <- ifelse(x == 1, "Retained", "Churn")
  }
  factor(x, levels = c("Retained", "Churn"))
}
