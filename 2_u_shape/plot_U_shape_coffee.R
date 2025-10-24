library(dplyr)
library(ggplot2)
library(patchwork)
library(tidyverse)

# Define folder
plot_dir <- "/Users/hao/cubic-home/Reproducibile_paper/LifeStyleChart/GAM/BAG"

# 1. Get all *_plot.rds files
plot_files <- list.files(
  plot_dir, 
  pattern = "coffee_intake_f1498_0_0.*_plot\\.rds$", 
  full.names = TRUE
)

# 2. Function to load and plot each RDS file
plot_significant_results <- function(file_path) {
  plot_name <- basename(file_path)
  
  if (file.exists(file_path)) {
    message("Loading plot: ", plot_name)
    p <- readRDS(file_path)
    message("Successfully loaded: ", plot_name, "\n")
    return(p)
  } else {
    warning("Plot file not found: ", plot_name)
    return(NULL)
  }
}

# 3. Load all plots
significant_plots <- lapply(plot_files, plot_significant_results)

message("\nCompleted loading all plots.")
message("Successfully loaded ", sum(!sapply(significant_plots, is.null)), 
        " out of ", length(significant_plots), " plots.")

# Remove NULL entries (for missing files)
significant_plots <- significant_plots[!sapply(significant_plots, is.null)]

# 4. Arrange plots in a grid (adjust ncol as needed)
combined_plot <- wrap_plots(significant_plots, ncol = 6) + 
  plot_annotation(
    title = "All Coffee/Tea Results",
    subtitle = paste0("Loaded ", length(significant_plots), " plots")
  )

# Display
print(combined_plot)
