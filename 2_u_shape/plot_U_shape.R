library(dplyr)
library(ggplot2)
library(patchwork)
library(tidyverse)

weight_file="/Users/hao/cubic-home/Reproducibile_paper/GrowthChart/GAM/BAG/BAG_anthropometric_stats_GAM_CI_weight_f21002_0_0.tsv"
height_file="/Users/hao/cubic-home/Reproducibile_paper/GrowthChart/GAM/BAG/BAG_anthropometric_stats_GAM_CI_standing_height_f50_0_0.tsv"
waist_file="/Users/hao/cubic-home/Reproducibile_paper/GrowthChart/GAM/BAG/BAG_anthropometric_stats_GAM_CI_waist_circumference_f48_0_0.tsv"

df_weight = read.csv(weight_file, sep='\t')
df_weight$Anthropometric = 'weight_f21002_0_0'
df_height = read.csv(height_file, sep='\t')
df_height$Anthropometric = 'standing_height_f50_0_0'
df_waist = read.csv(waist_file, sep='\t')
df_waist$Anthropometric = 'waist_circumference_f48_0_0'

# Combine vertically and filter
df <- bind_rows(df_weight, df_height, df_waist) %>%
  filter(anthropometric_pvalue < 0.05/23/3)

# 1. Get list of significant outcomes from df
significant_results <- df %>%
  select(Outcome, Anthropometric) %>%
  mutate(plot_name = paste0("anthropometricchart_", Anthropometric, "_", Outcome, "_plot.rds"))

# 2. Create function to load and plot each significant result
plot_significant_results <- function(plot_name) {
  plot_path <- file.path("/Users/hao/cubic-home/Reproducibile_paper/GrowthChart/GAM/BAG", plot_name)
  
  if (file.exists(plot_path)) {
    # Print loading message with the plot name
    message("Loading plot: ", plot_name)
    
    p <- readRDS(plot_path)
    
    # Print confirmation message
    message("Successfully loaded: ", plot_name)
    cat("\n")  # Add blank line for better readability
    
    return(p)
  } else {
    warning("Plot file not found: ", plot_name)
    return(NULL)
  }
}

# Then when you run the plotting:
message("\nStarting to load significant plots...")
message("Total significant results to plot: ", nrow(significant_results))
message("=====================================")

significant_plots <- lapply(significant_results$plot_name, function(x) {
  cat("Processing:", x, "\n")
  plot_significant_results(x)
})

message("\nCompleted loading all plots.")
message("Successfully loaded ", sum(!sapply(significant_plots, is.null)), " out of ", length(significant_plots), " plots.")

# Remove NULL entries (for missing files)
significant_plots <- significant_plots[!sapply(significant_plots, is.null)]

# 4. Arrange plots in a grid (adjust ncol as needed)
combined_plot <- wrap_plots(significant_plots, ncol = 6) + 
  plot_annotation(title = "",
                  subtitle = "")

print('STOP...')