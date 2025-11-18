module load python/3.12.3
module load cuda/12.6.0 
module load julia/1.11.7
module load R/4.3.2

python3.12 software_speed_accrqa.py --compFlag=cpu
python3.12 software_speed_accrqa.py --compFlag=nv_gpu
python3.12 software_speed.py
python3.12 software_speed_pyunicorn.py
python3.12 software_speed_pyrqa.py
julia --threads 1 software_speed_microstates.jl
julia --threads 1 software_speed_RQA_Samp.jl
julia --threads 1 software_speed.jl --parallel false
julia --threads 32 software_speed.jl --parallel true
Rscript software_speed.R
# #matlab -nodesktop < software_speed.m

