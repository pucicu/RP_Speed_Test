#!/bin/bash

#SBATCH --qos=gpushort
#SBATCH --job-name=accrqa_gpu_speedtest
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=04:30:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python/3.12.3
module load cuda/12.6.0 

source .venv/bin/activate  

python3.12 software_speed_accrqa.py --compFlag=nv_gpu
