#!/bin/bash

#SBATCH --qos=gpushort
#SBATCH --job-name=accrqa_gpu_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=24:00:00
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --mem=640G

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python gcc/13.2.0 cuda libffi/3.4.4 openssl/3.0.12

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python3.12 ../Scripts/software_speed_accrqa.py --compFlag=nv_gpu
