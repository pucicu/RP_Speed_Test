module load python/3.12.3
module load cuda/12.6.0 
module load julia/1.11.7
module load R/4.3.2

python3.12 software_speed_accrqa.py --compFlag=cpu
python3.12 software_speed_accrqa.py --compFlag=nv_gpu
python3.12 software_speed.py
python3.12 software_speed_pyunicorn.py
python3.12 software_speed_pyrqa.py
julia software_speed.jl
julia --threads 16 software_speed_parallel.jl
Rscript software_speed.R
#matlab -nodesktop < software_speed.m
