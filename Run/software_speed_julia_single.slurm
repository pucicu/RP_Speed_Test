#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=julia_single_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=03:50:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load julia/1.11.7
export JULIA_NUM_THREADS=1

julia --threads 1 ../Scripts/software_speed_DynSyst.jl --parallel false
