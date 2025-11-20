#!/bin/bash

#SBATCH --qos=gpushort
#SBATCH --job-name=accrqa_gpu_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=02:30:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python openmpi/5.0.8 gcc/13.2.0 cuda

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python3.12 ../Scripts/software_speed_accrqa.py --compFlag=nv_gpu
