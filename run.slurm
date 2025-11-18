#!/bin/bash

#SBATCH --qos=short
#SBATCH --ntasks=1
#SBATCH --nodes=1

###############################################
#  BLOCK A — CPU job (128 cores)
###############################################
#SBATCH --job-name=128cpu_tasks
#SBATCH --array=0-1
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --time=01:30:00
#SBATCH --cpus-per-task=128

if (( SLURM_ARRAY_TASK_ID == 0 )); then
    # --------------------------------------
    # Task 0: Julia Parallel
    # --------------------------------------
    export SLURM_JOB_NAME="julia_parallel"
    echo "Running $SLURM_JOB_NAME"
    module load julia/1.11.7
    export JULIA_NUM_THREADS=128
    export PYTHONUNBUFFERED=1
    julia --threads 128 software_speed.jl --parallel true

elif (( SLURM_ARRAY_TASK_ID == 1 )); then
    # --------------------------------------
    # Task 1: AccRQA CPU
    # --------------------------------------
    export SLURM_JOB_NAME="python_accrqa_cpu"
    echo "Running $SLURM_JOB_NAME"
    module load python
    source .venv/bin/activate  
    python3.12 software_speed_accrqa.py --compFlag=cpu

fi


###############################################
#  BLOCK B — GPU jobs
###############################################
#SBATCH --job-name=gpu_tasks
#SBATCH --array=2-3
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --time=01:30:00
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

if (( SLURM_ARRAY_TASK_ID == 2 )); then
    # --------------------------------------
    # Task 2: PyRQA (GPU)
    # --------------------------------------
    export SLURM_JOB_NAME="python_pyrqa"
    echo "Running $SLURM_JOB_NAME"
    module load python/3.12.3 cuda/12.6.0 
    source .venv/bin/activate  
    export PYTHONUNBUFFERED=1
    python3.12 software_speed_pyrqa.py

elif (( SLURM_ARRAY_TASK_ID == 3 )); then
    # --------------------------------------
    # Task 3: ACCRQA GPU
    # --------------------------------------
    export SLURM_JOB_NAME="python_accrqa_gpu"
    echo "Running $SLURM_JOB_NAME"
    module load python/3.12.3 cuda/12.6.0 
    source .venv/bin/activate  
    python3.12 software_speed_accrqa.py --compFlag=nv_gpu

fi


###############################################
#  BLOCK C — CPU jobs (1 core each)
###############################################
#SBATCH --job-name=1cpu_tasks
#SBATCH --array=4-9
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=200GB

if (( SLURM_ARRAY_TASK_ID == 4 )); then
    # --------------------------------------
    # Task 4: R Single
    # --------------------------------------
    export SLURM_JOB_NAME="R_single"
    echo "Running $SLURM_JOB_NAME"
    module load R/4.3.2
    Rscript software_speed.R

elif (( SLURM_ARRAY_TASK_ID == 5 )); then
    # --------------------------------------
    # Task 5: Julia Single
    # --------------------------------------
    export SLURM_JOB_NAME="julia_single"
    echo "Running $SLURM_JOB_NAME"
    module load julia/1.11.7
    export JULIA_NUM_THREADS=1
    julia --threads 1 software_speed.jl --parallel false

elif (( SLURM_ARRAY_TASK_ID == 6 )); then
    # --------------------------------------
    # Task 6: Julia RQA Samp
    # --------------------------------------
    export SLURM_JOB_NAME="julia_rqa_samp"
    echo "Running $SLURM_JOB_NAME"
    module load julia/1.11.7
    export JULIA_NUM_THREADS=1
    julia --threads 1 software_speed_RQA_Samp.jl

elif (( SLURM_ARRAY_TASK_ID == 7 )); then
    # --------------------------------------
    # Task 7: Julia Microstates
    # --------------------------------------
    export SLURM_JOB_NAME="julia_microstates"
    echo "Running $SLURM_JOB_NAME"
    module load julia/1.11.7
    export JULIA_NUM_THREADS=1
    julia --threads 1 software_speed_microstates.jl

elif (( SLURM_ARRAY_TASK_ID == 8 )); then
    # --------------------------------------
    # Task 8: Python Simple
    # --------------------------------------
    export SLURM_JOB_NAME="python_simple"
    echo "Running $SLURM_JOB_NAME"
    module load python
    python3.12 software_speed.py

elif (( SLURM_ARRAY_TASK_ID == 9 )); then
    # --------------------------------------
    # Task 9: Python pyunicorn
    # --------------------------------------
    export SLURM_JOB_NAME="python_pyunicorn"
    echo "Running $SLURM_JOB_NAME"
    module load python
    python3.12 software_speed_pyunicorn.py

fi
