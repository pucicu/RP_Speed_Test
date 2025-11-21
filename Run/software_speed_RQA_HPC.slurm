#!/bin/bash

#SBATCH --qos=short
#SBATCH --job-name=rqa_hpc_speedtest
#SBATCH --output=../Logs/%x-%j.out
#SBATCH --error=../Logs/%x-%j.err
#SBATCH --time=00:30:00
#SBATCH --nodes=16
#SBATCH --ntasks=128
#SBATCH --mem=600G

echo "------------------------------------------------------------"
echo "SLURM JOB ID: $SLURM_JOBID"
echo "------------------------------------------------------------"

## 
module load mpich

bash ../Scripts/software_speed_RQA_HPC.sh
