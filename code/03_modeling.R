# 03_modeling.R
# Purpose: logistic regression + random forest with 5-fold CV, plus threshold scan

source("code/01_data_cleaning.R")

build_splits <- function(df) {
  split <- initial_split(df, prop = 0.8, strata = retained)
  list(
    split = split,
    train = training(split),
    test  = testing(split)
  )
}

build_recipe <- function(train_df) {
  recipe(retained ~ num_purchases + weeks_since_last_purchase + satisfaction_survey + discounted_rate_last_purchase,
         data = train_df) %>%
    step_dummy(all_nominal_predictors()) %>%
    step_zv(all_predictors())
}

fit_models_cv <- function(train_df) {
  folds <- vfold_cv(train_df, v = 5, strata = retained)

  rec <- build_recipe(train_df)

  # Logistic regression (glm)
  lr_spec <- logistic_reg() %>% set_engine("glm")

  # Random forest (randomForest package)
  rf_spec <- rand_forest(mtry = tune(), trees = 500, min_n = tune()) %>%
    set_engine("randomForest") %>%
    set_mode("classification")

  wf_lr <- workflow() %>% add_recipe(rec) %>% add_model(lr_spec)
  wf_rf <- workflow() %>% add_recipe(rec) %>% add_model(rf_spec)

  # Metrics: event_level second => "Churn"
  met <- metric_set(roc_auc, pr_auc, accuracy, sens, spec, f_meas)

  # LR CV
  lr_res <- fit_resamples(
    wf_lr, resamples = folds,
    metrics = met,
    control = control_resamples(save_pred = TRUE)
  )

  # RF tuning
  rf_grid <- grid_regular(mtry(range = c(1, 10)), min_n(range = c(2, 50)), levels = 5)

  rf_res <- tune_grid(
    wf_rf, resamples = folds,
    metrics = met,
    grid = rf_grid,
    control = control_grid(save_pred = TRUE)
  )

  list(folds = folds, rec = rec, wf_lr = wf_lr, wf_rf = wf_rf, lr_res = lr_res, rf_res = rf_res)
}

finalize_and_fit <- function(train_df, rf_res, wf_rf, metric = "roc_auc") {
  best <- select_best(rf_res, metric = metric)
  wf_final <- finalize_workflow(wf_rf, best)
  fit(wf_final, data = train_df)
}

# Threshold scan on test set
threshold_scan <- function(truth, prob_churn, thresholds = seq(0.05, 0.95, by = 0.01)) {
  tibble(
    threshold = thresholds
  ) %>%
    rowwise() %>%
    mutate(
      pred = factor(ifelse(prob_churn >= threshold, "Churn", "Retained"), levels = c("Retained", "Churn")),
      roc_auc = roc_auc_vec(truth, prob_churn, event_level = "second"),
      pr_auc  = pr_auc_vec(truth, prob_churn, event_level = "second"),
      recall  = sens_vec(truth, pred, event_level = "second"),
      precision = precision_vec(truth, pred, event_level = "second"),
      f1      = f_meas_vec(truth, pred, event_level = "second")
    ) %>%
    ungroup()
}

compute_vif_glm <- function(train_df) {
  # glm requires numeric outcome; use retained_binary 1=Retained, 0=Churn
  # We use Retained as 1 to match the original dataset definition; VIF doesn't depend on outcome coding.
  tmp <- train_df %>%
    mutate(retained_num = ifelse(retained == "Retained", 1, 0))

  m <- glm(
    retained_num ~ num_purchases + weeks_since_last_purchase + satisfaction_survey + discounted_rate_last_purchase,
    data = tmp,
    family = binomial()
  )

  tibble(variable = names(car::vif(m)), vif = as.numeric(car::vif(m)))
}
