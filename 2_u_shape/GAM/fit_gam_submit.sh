#!/bin/bash
#SBATCH --partition=all
#SBATCH --job-name=GAM
#SBATCH --array=0-1
#SBATCH --mem-per-cpu=12G
#SBATCH --time=0-23:59:00
#SBATCH --output=/cbica/home/wenju/output/GAM_%A_%a.out
#SBATCH --error=/cbica/home/wenju/output/GAM_%A_%a.err


trait_array=( coffee_intake_f1498_0_0 tea_intake_f1488_0_0 )
trait=${trait_array[$SLURM_ARRAY_TASK_ID]}

coffee_file=/cbica/home/wenju/Reproducibile_paper/CoffeeChart/data/coffee_data_encoded.tsv
bag_file=/cbica/home/wenju/Reproducibile_paper/SleepAging/data/MomoBAG.tsv
cov_file=/cbica/home/wenju/Reproducibile_paper/PRS_UKBB/prediction/data/UKBB_fullsample_covariate.csv
output_dir=/cbica/home/wenju/Reproducibile_paper/CoffeeChart/GAM/BAG
mkdir -p $output_dir

output_file="${output_dir}/BAG_coffee_stats_GAM_CI_${trait}.tsv"
if [ ! -f ${output_file} ]; then
  echo "Run GAM for: ${trait}..."
  bash /cbica/home/wenju/Project/CoffeeChart/2_u_shape/GAM/fit_gam.sh ${coffee_file} ${bag_file} ${cov_file} ${output_dir} ${trait}
else
  :
fi
