library(ggplot2)
library(dplyr)

# Categorize based on epidemiological evidence
diet_data <- data.frame(
  trait = c("Cooked vegetables", "Raw vegetables", "Fresh fruit", "Dried fruit",
            "Oily fish", "Non-oily fish", "Tea", "Coffee", "Water",
            "Poultry", "Beef", "Lamb/mutton", "Pork", "Cheese", "Bread", "Cereal",
            "Red wine", "White wine/champagne",
            "Processed meat", "Spirits", "Cigarettes"),

  category = c("Protective", "Protective", "Protective", "Protective",
               "Protective", "Protective", "Dose-dependent", "Dose-dependent", "Protective",
               "Dose-dependent", "Dose-dependent", "Dose-dependent", "Dose-dependent",
               "Dose-dependent", "Neutral/mixed", "Dose-dependent",
               "Dose-dependent", "Dose-dependent",
               "Risky", "Risky", "Risky")
)

# Assign numeric values for y-axis (evidence strength)
# Protective = -2, Dose-dependent = -1, Neutral/mixed = 0, Risky = +2
diet_data <- diet_data %>%
  mutate(evidence_score = case_when(
    category == "Protective" ~ -2,
    category == "Dose-dependent" ~ -1,
    category == "Neutral/mixed" ~ 0,
    category == "Risky" ~ 2
  ))

# Set colors
category_colors <- c("Protective" = "darkgreen",
                     "Dose-dependent" = "goldenrod",
                     "Neutral/mixed" = "gray50",
                     "Risky" = "red")

# Plot
ggplot(diet_data, aes(x = reorder(trait, evidence_score), y = evidence_score, fill = category)) +
  geom_col(color = "black", width = 0.7) +
  scale_fill_manual(values = category_colors) +
  scale_y_continuous(breaks = c(-2, -1, 0, 2),
                     labels = c("Protective", "Dose-dependent", "Neutral", "Risky")) +
  coord_flip() +
  labs(x = "Dietary trait",
       y = "Epidemiological evidence",
       title = "Dietary Traits Across the Protective–Risk Spectrum (Literature-based)") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold", size = 16))
