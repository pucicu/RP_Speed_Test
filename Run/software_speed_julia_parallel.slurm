#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=julia_parallel_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=01:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=400000
#SBATCH --cpus-per-task=128

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

free -h

## 
module load julia/1.11.7
export JULIA_NUM_THREADS=128
export PYTHONUNBUFFERED=1

julia --threads 128 ../Scripts/software_speed_DynSyst.jl --parallel true
