#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=R_single_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500G

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load R/4.3.2

Rscript ../Scripts/software_speed.R
