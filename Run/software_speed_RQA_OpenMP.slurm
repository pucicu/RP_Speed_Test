#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=rqa_openmp_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
bash ../Scripts/software_speed_RQA_OpenMP.sh
