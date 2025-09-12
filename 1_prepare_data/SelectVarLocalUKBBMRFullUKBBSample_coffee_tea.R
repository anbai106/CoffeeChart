library(dplyr)
sel.orig <- read.csv("/cbica/home/wenju/Reproducibile_paper/CoffeeChart/data/coffee_var.tsv", stringsAsFactors = FALSE, sep = "\t")

sel <- sel.orig %>%
  dplyr::select(Var)

sel_c = c('eid', sel$Var)

ukbb_all.orig <- read.csv("/cbica/projects/ISTAGING/Pipelines/ClinicalDataConsolidation_201911/Data/External_Data/UKBiobank/ukb_230717_FullUKBSample.csv", stringsAsFactors = FALSE)

for (i in 1:length(sel_c)) {
  vars <- names(ukbb_all.orig)[startsWith(names(ukbb_all.orig), sel_c[i])]
  if (i==1){
    sel_Var <- as.data.frame(vars)
  } else {
    sel_Var <- rbind(sel_Var, as.data.frame(vars))
  }}

ukbb_all <- ukbb_all.orig %>%
  dplyr::select(sel_Var$vars)

write.csv(ukbb_all, "/cbica/home/wenju/Reproducibile_paper/CoffeeChart/data/diet_data.csv", row.names = FALSE)