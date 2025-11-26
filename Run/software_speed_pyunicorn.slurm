#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=pyunicorn_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=660G

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python gcc/13.2.0 openssl/3.0.12 libffi/3.4.4

source ../.venv/bin/activate  
export PYTHONUNBUFFERED=1

python ../Scripts/software_speed_pyunicorn.py
