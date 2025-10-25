#!/bin/bash
#SBATCH --partition=all
#SBATCH --job-name=SelectVar
#SBATCH --mem-per-cpu=64G
#SBATCH --output=/cbica/home/wenju/output/SelectVar_%A_%a.out
#SBATCH --error=/cbica/home/wenju/output/SelectVar_%A_%a.err

module load python/anaconda/3
module load R/4.3

Rscript /cbica/home/wenju/Project/LifestyleChart/1_prepare_data/SelectVarLocalUKBBMRFullUKBBSample.R
