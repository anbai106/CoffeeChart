#!/bin/bash

 dietary_file=$1
bag_file=$2
cov_file=$3
output_dir=$4
trait=$5

module load R/4.2.2
echo "Start training"
Rscript /cbica/home/wenju/Project/LifeStyleChart/2_u_shape/GAM/fit_gam.R ${dietary_file} ${bag_file} ${cov_file} ${output_dir} ${trait}
echo "Finish!"
