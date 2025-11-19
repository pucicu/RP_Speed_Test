#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=accrqa_cpu_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python/3.12.3
module load cuda/12.6.0 

source ../.venv/bin/activate  

python3.12 ../Scripts/software_speed_accrqa.py --compFlag=cpu
