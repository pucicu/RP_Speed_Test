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
module load python
module load cuda

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python ../Scripts/software_speed_pyrqa.py
