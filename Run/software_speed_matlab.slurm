#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=matlab_single_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=640G

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
export PATH=$PATH:/p/projects/synchronet/matlab/R2024b/bin

matlab -nodesktop < ../Scripts/software_speed.m
