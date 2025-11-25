# Shell script to run a bunch of speedtests for RQA
# set SUBMIT_HPC to 1 if submitting to a HPC with SLURM

SUBMIT_HPC=1

if (( SUBMIT_HPC == 1 )); then
   # run different nodes of HPC
   
   sbatch software_speed_accrqa_cpu.slurm
   sbatch software_speed_accrqa_gpu.slurm
   sbatch software_speed_julia_microstates.slurm
   sbatch software_speed_julia_single.slurm
   sbatch software_speed_julia_parallel.slurm
   sbatch software_speed_julia_RQA_Samp.slurm
   sbatch software_speed_pyrqa.slurm
   sbatch software_speed_python.slurm
   sbatch software_speed_pyunicorn.slurm
   sbatch software_speed_R.slurm
   sbatch software_speed_RQA_OpenMP.slurm
   sbatch software_speed_RQA_HPC.slurm

else
   # run on login node (or any other local compute node)
   
   # if computer is using module based software management:
   module load python cuda julia R
   
   # use local Python environment
   source ../.venv/bin/activate  

   python3.12 ../Scripts/software_speed_accrqa.py --compFlag=cpu
   python3.12 ../Scripts/software_speed_accrqa.py --compFlag=nv_gpu
   python3.12 ../Scripts/software_speed_simple.py
   python3.12 ../Scripts/software_speed_pyunicorn.py
   python3.12 ../Scripts/software_speed_pyrqa.py
   julia --threads 1 ../Scripts/software_speed_microstates.jl
   julia --threads 1 ../Scripts/software_speed_RQA_Samp.jl
   julia --threads 1 ../Scripts/software_speed_DynSyst.jl --parallel false
   julia --threads 32../Scripts/ software_speed_DynSyst.jl --parallel true
   Rscript ../Scripts/software_speed.R
   # #matlab -nodesktop < ../Scripts/software_speed.m

fi
