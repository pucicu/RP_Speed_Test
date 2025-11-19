#!/bin/bash

#SBATCH --qos=gpushort
#SBATCH --job-name=pyrqa_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=02:30:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python/3.12.3
module load cuda/12.6.0 

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python3.12 ../Scripts/software_speed_pyrqa.py
