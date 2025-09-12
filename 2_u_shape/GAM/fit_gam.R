#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

dietary_file <- args[1]
bag_file <- args[2]
cov_file <- args[3]
output_dir <- args[4]
trait <- args[5]

.libPaths("/gpfs/fs001/cbica/home/wenju/R/x86_64-pc-linux-gnu-library/4.2.2")

library(mgcv)
system.file(package = "mgcv")
packageVersion("mgcv")
library(dplyr)
library(ggplot2)
library(patchwork)
library(tidyr)

diagnosis_file="/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/icd_disease_diagnosis.tsv"
add_cov_file="/Users/hao/cubic-home/Reproducibile_paper/CoffeeChart/data/additional_cov.tsv"

## Load and merge data (commented out if already loaded in session)
dietary <- read.csv(dietary_file, sep='\t')
bag <- read.delim(bag_file, header = TRUE, na.strings = c("NA", "", ".", "-9999"))
names(bag)[names(bag) == "Brain_PhenoBAG"] <- "Brain_MRIBAG"
covs <- read.csv(cov_file)
names(covs)[names(covs) == "eid"] <- "participant_id"
diagnosis <- read.csv(diagnosis_file, sep='\t')
add_cov <- read.csv(add_cov_file, sep='\t')

# Full join all three datasets by participant_id
df <- dietary %>%
  full_join(bag, by = "participant_id") %>%
  full_join(covs, by = "participant_id") %>%
  full_join(add_cov, by = "participant_id") %>%
  full_join(diagnosis, by = "participant_id")

BAG_list <- c('Reproductive_female_ProtBAG', 'Pulmonary_ProtBAG', 'Heart_ProtBAG',
              'Brain_ProtBAG', 'Eye_ProtBAG', 'Hepatic_ProtBAG', 'Renal_ProtBAG',
              'Reproductive_male_ProtBAG', 'Endocrine_ProtBAG', 'Immune_ProtBAG', 'Skin_ProtBAG',
              "Endocrine_MetBAG", "Digestive_MetBAG", "Hepatic_MetBAG", "Immune_MetBAG",
              "Metabolic_MetBAG", "Brain_MRIBAG", "Adipose_MRIBAG", "Kidney_MRIBAG", "Heart_MRIBAG", "Liver_MRIBAG",
              "Pancreas_MRIBAG", "Spleen_MRIBAG")

covariates <- c("age_when_attended_assessment_centre_f21003_0_0", "diastolic_blood_pressure_automated_reading_f4079_0_0",
                "systolic_blood_pressure_automated_reading_f4080_0_0", 'genetic_principal_components_f22009_0_1', 'genetic_principal_components_f22009_0_2', 'genetic_principal_components_f22009_0_3',
                'genetic_principal_components_f22009_0_4', 'genetic_principal_components_f22009_0_5', 'genetic_principal_components_f22009_0_6',
                'genetic_principal_components_f22009_0_7', 'genetic_principal_components_f22009_0_8', 'genetic_principal_components_f22009_0_9',
                'genetic_principal_components_f22009_0_10', 'genetic_principal_components_f22009_0_11', 'genetic_principal_components_f22009_0_12',
                'genetic_principal_components_f22009_0_13', 'genetic_principal_components_f22009_0_14', 'genetic_principal_components_f22009_0_15',
                'genetic_principal_components_f22009_0_16', 'genetic_principal_components_f22009_0_17', 'genetic_principal_components_f22009_0_18',
                'genetic_principal_components_f22009_0_19', 'genetic_principal_components_f22009_0_20', 'genetic_principal_components_f22009_0_21',
                'genetic_principal_components_f22009_0_22', 'genetic_principal_components_f22009_0_23', 'genetic_principal_components_f22009_0_24',
                'genetic_principal_components_f22009_0_25', 'genetic_principal_components_f22009_0_26', 'genetic_principal_components_f22009_0_27',
                'genetic_principal_components_f22009_0_28', 'genetic_principal_components_f22009_0_29', 'genetic_principal_components_f22009_0_30',
                'genetic_principal_components_f22009_0_31', 'genetic_principal_components_f22009_0_32', 'genetic_principal_components_f22009_0_33',
                'genetic_principal_components_f22009_0_34', 'genetic_principal_components_f22009_0_35', 'genetic_principal_components_f22009_0_36',
                'genetic_principal_components_f22009_0_37', 'genetic_principal_components_f22009_0_38', 'genetic_principal_components_f22009_0_39',
                'genetic_principal_components_f22009_0_40', "standing_height_f50_0_0", "waist_circumference_f48_0_0", "body_mass_index_bmi_f23104_0_0", "smoking_status_f20116_0_0", 'average_total_household_income_before_tax_f738_0_0')

# Function to test multiple families and return the best model
fit_and_test_effects <- function(outcome) {
  vars_to_keep <- c(trait, "sex_f31_0_0", outcome, covariates)
  
  df_model <- df %>%
    select(all_of(vars_to_keep)) %>%
    drop_na() %>%
    mutate(
      sex = factor(sex_f31_0_0, levels = c(0, 1), labels = c("female", "male")),
      
      # Normalize the column specified by the 'outcome' variable to the range [1e-5, 1]
      !!outcome := (get(outcome) - min(get(outcome), na.rm = TRUE)) / 
        (max(get(outcome), na.rm = TRUE) - min(get(outcome), na.rm = TRUE)) + 1e-5
    )
  
  # Define model formula
  # Define candidate families
  families <- list(
    gaussian = gaussian(),
    tdist = scat(),
    gamma = Gamma(link = "log")
  )
  
  # Candidate k values
  k_values <- c(3, 5, 10, 15, 20)
  
  # Initialize tracking variables
  best_model <- NULL
  best_aic <- Inf
  best_family <- NULL
  best_k <- NULL
  
  # Loop over k and family combinations
  for (k in k_values) {
    model_formula <- as.formula(paste0(
      outcome, " ~ s(", trait, ", k=", k, ", bs='cr') +
                 sex +
                 s(", trait, ", by=sex, k=", k, ", bs='cr') + ",
      paste(covariates, collapse = " + ")
    ))
    
    for (fam_name in names(families)) {
      fam <- families[[fam_name]]
      fit <- tryCatch(
        gam(model_formula, data = df_model, method = "REML", family = fam),
        error = function(e) NULL
      )
      
      if (!is.null(fit)) {
        aic <- AIC(fit)
        if (aic < best_aic) {
          best_model <- fit
          best_aic <- aic
          best_family <- fam_name
          best_k <- k
        }
      }
    }
  }
  
  # Print best model details
  cat("BAG:", outcome, "\n")
  cat("Best family:", best_family, "\n")
  cat("Best k:", best_k, "\n")
  cat("Best AIC:", best_aic, "\n")
  
  # Choose the best model based on AIC
  model <- best_model
  
  sum_gam <- summary(model)
  # Correctly format the row names using paste0()
  main_smooth_name <- paste0("s(", trait, ")")
  interaction_smooth_name <- paste0("s(", trait, "):sexmale")
  # Then access the summary tables using those full strings
  main_dietary <- sum_gam$s.table[main_smooth_name, ]
  print(rownames(sum_gam$p.table))
  sex_diff <- sum_gam$p.table["sexmale", ]
  print(rownames(sum_gam$s.table))
  sex_interaction_term <- sum_gam$s.table[interaction_smooth_name, ]
  
  df_model$trait <- df_model[trait] 
  
  min_val = min(df_model$trait, na.rm=TRUE)
  max_val = max(df_model$trait, na.rm=TRUE)
  
  # Prediction
  pred_data <- expand.grid(
    trait = seq(min_val, max_val, length = 100),
    sex = factor(c("female", "male"), levels = c("female", "male"))
  )
  for (cov in covariates) {
    if (is.numeric(df_model[[cov]])) {
      pred_data[[cov]] <- mean(df_model[[cov]], na.rm = TRUE)
    } else {
      pred_data[[cov]] <- names(sort(table(df_model[[cov]]), decreasing = TRUE))[1]
    }
  }
  pred_data[trait] <- pred_data$trait
  pred <- predict(model, newdata = pred_data, se.fit = TRUE)
  pred_data$fit <- pred$fit
  
  optimals <- pred_data %>%
    group_by(sex) %>%
    slice(which.min(fit))
  
  ci_data <- pred_data %>%
    mutate(
      lower = fit - 1.96 * pred$se.fit,
      upper = fit + 1.96 * pred$se.fit
    )
  
  # Only show optimal lines if main dietary p-value is significant
  add_optimal_lines <- main_dietary[["p-value"]] < 0.05 / 23 / 19
  
  # Filter optimals only if significant
  optimals_filtered <- if (add_optimal_lines) optimals else optimals[0, ]
  
  # --- Plot 1: Raw data points by sex (x-axis hidden) ---
  p_points <- ggplot(df_model, aes(x = .data[[trait]], y = !!sym(outcome), color = sex)) +
    geom_point(alpha = 0.3, size = 1) +
    scale_color_manual(values = c(female = "#EB5F2C", male = "#0072B5")) +
    labs(
      title = paste(outcome),
      x = NULL,
      y = "BAG"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 6),
      legend.position = "none",
      axis.text.x = element_blank(),         # Remove x-axis text
      axis.ticks.x = element_blank(),        # Remove x-axis ticks
      axis.text = element_text(color = "black")  # All axis labels in black
    )
  
  # --- Plot 2: Model fit with CI and conditional optimal lines ---
  p_fit <- ggplot(ci_data, aes(x = .data[[trait]], y = fit, color = sex)) +
    geom_ribbon(aes(ymin = lower, ymax = upper, fill = sex), alpha = 0.2, color = NA) +
    geom_line(size = 1) +
    geom_vline(
      data = optimals_filtered,
      aes(xintercept = trait, color = sex),
      linetype = "dashed", linewidth = 0.7
    ) +
    scale_color_manual(values = c(female = "#EB5F2C", male = "#0072B5")) +
    scale_fill_manual(values = c(female = "#EB5F2C", male = "#0072B5")) +
    labs(
      y = "BAG",
      x = trait
    ) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text = element_text(color = "black")
    )
  
  # Combine plots
  p <- (p_points / p_fit) +
    plot_layout(heights = c(1, 1.2)) +
    plot_annotation(subtitle = "")
  
  safe_extract <- function(obj, colnames) {
    if (is.null(obj)) return(NA)
    for (col in colnames) {
      if (col %in% names(obj)) return(obj[[col]])
    }
    return(NA)
  }
  
  stats <- data.frame(
    Outcome = outcome,
    Family = best_family,
    Optimal_k = best_k,
    dietary_edf = safe_extract(main_dietary, c("edf")),
    dietary_pvalue = safe_extract(main_dietary, c("p-value")),
    Sex_coef = safe_extract(sex_diff, c("Estimate")),
    Sex_pvalue = coalesce(safe_extract(sex_diff, "Pr(>|z|)"), safe_extract(sex_diff, "Pr(>|t|)")),
    Sex_interaction_pvalue = safe_extract(sex_interaction_term, c("p-value")),
    Female_optimal = if ("female" %in% optimals$sex) optimals$trait[optimals$sex == "female"] else NA,
    Male_optimal = if ("male" %in% optimals$sex) optimals$trait[optimals$sex == "male"] else NA
  )
  
  ### select column for dietary Chart
  dietarychart_data <- ci_data %>%
    select(trait, sex, fit, lower, upper) %>%
    rename(
      BAG_predict = fit,
      BAG_predict_lower = lower,
      BAG_predict_upper = upper
    )
  write.table(dietarychart_data,
              paste0(output_dir, "/dietarychart_", trait, "_data_", outcome, ".tsv"),
              sep = "\t", row.names = FALSE)
  
  write.table(stats, 
              paste0(output_dir, "/dietarychart_", trait, "_stats_", outcome, ".tsv"),
              sep = "\t", row.names = FALSE)
  
  plot_file <- file.path(output_dir, paste0("dietarychart_", trait, "_", outcome, "_plot.rds"))
  saveRDS(p, file = plot_file)
  
  return(list(plot = p, stats = stats))
}

# Run the function
all_results <- lapply(BAG_list, fit_and_test_effects)
# Assign names only for those actually run
names(all_results) <- BAG_list