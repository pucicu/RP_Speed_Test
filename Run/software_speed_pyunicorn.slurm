#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=pyunicorn_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=03:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500000

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load python/3.12.3

source ../.venv/bin/activate  

python3.12 ../Scripts/software_speed_pyunicorn.py
