module load python/3.12.3
module load cuda/12.6.0 
module load julia/1.11.7

python3.12 software_speed_accrqa.py --compFlag=cpu
python3.12 software_speed_accrqa.py --compFlag=nv_gpu

python3 software_speed.py
python3 software_speed_pyunicorn.py
julia software_speed.jl
julia --threads 16 software_speed_parallel.jl
#rscript software_speed.R
#matlab -nodesktop < software_speed.m
