#!/bin/bash
#SBATCH --partition=all
#SBATCH --job-name=GAM
#SBATCH --array=0-19
#SBATCH --mem-per-cpu=12G
#SBATCH --time=0-23:59:00
#SBATCH --output=/cbica/home/wenju/output/GAM_%A_%a.out
#SBATCH --error=/cbica/home/wenju/output/GAM_%A_%a.err


trait_array=( cooked_vegetable_intake_f1289_0_0 salad_raw_vegetable_intake_f1299_0_0 fresh_fruit_intake_f1309_0_0 dried_fruit_intake_f1319_0_0 oily_fish_intake_f1329_0_0 nonoily_fish_intake_f1339_0_0 processed_meat_intake_f1349_0_0 poultry_intake_f1359_0_0 beef_intake_f1369_0_0 lambmutton_intake_f1379_0_0 pork_intake_f1389_0_0 cheese_intake_f1408_0_0 bread_intake_f1438_0_0 cereal_intake_f1458_0_0 tea_intake_f1488_0_0 coffee_intake_f1498_0_0 water_intake_f1528_0_0 average_weekly_red_wine_intake_f1568_0_0 average_weekly_champagne_plus_white_wine_intake_f1578_0_0 )
trait=${trait_array[$SLURM_ARRAY_TASK_ID]}

dietary_file=/cbica/home/wenju/Reproducibile_paper/LifeStyleChart/data/dietary_data_encoded.tsv
bag_file=/cbica/home/wenju/Reproducibile_paper/SleepAging/data/MomoBAG.tsv
cov_file=/cbica/home/wenju/Reproducibile_paper/PRS_UKBB/prediction/data/UKBB_fullsample_covariate.csv
output_dir=/cbica/home/wenju/Reproducibile_paper/LifeStyleChart/GAM/BAG
mkdir -p $output_dir

output_file="${output_dir}/BAG_dietary_stats_GAM_CI_${trait}.tsv"
if [ ! -f ${output_file} ]; then
  echo "Run GAM for: ${trait}..."
  bash /cbica/home/wenju/Project/LifeStyleChart/2_u_shape/GAM/fit_gam.sh ${dietary_file} ${bag_file} ${cov_file} ${output_dir} ${trait}
else
  :
fi
