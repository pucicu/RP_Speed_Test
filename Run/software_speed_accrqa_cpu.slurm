#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=accrqa_cpu_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python gcc/13.2.0 cuda libffi/3.4.4 openssl/3.0.12

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python ../Scripts/software_speed_accrqa.py --compFlag=cpu
