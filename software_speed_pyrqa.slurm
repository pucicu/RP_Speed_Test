#!/bin/bash

#SBATCH --qos=gpushort
#SBATCH --job-name=pyrqa_speedtest
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=30
#SBATCH --partition=gpu
#SBATCH --gres=gpu:4

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python/3.12.3
module load cuda/12.6.0 

source .venv/bin/activate  

python3.12 software_speed_pyrqa.py
