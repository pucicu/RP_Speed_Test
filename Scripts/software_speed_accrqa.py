# speed test

# import required packages
from scipy.integrate import odeint
import numpy as np
import time
import gc
import accrqa as rqa
import argparse

# argumentParser
parser = argparse.ArgumentParser(description="Set computation flag")

# optional argument --compFlag, default 'nv_gpu'
parser.add_argument(
    '--compFlag',
    type=str,
    choices=['nv_gpu', 'cpu'],
    default='nv_gpu',
    help="Computation flag: 'nv_gpu' or 'cpu' (default: 'nv_gpu')"
)

# parse arguments
args = parser.parse_args()

# set computation type
compFlag = args.compFlag


# results file
filename = f'../Results/time_python_accrqa_{compFlag}.csv'


# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(1000000.),.075)). astype(int)


# calculate RP and RQA for different length
tspanRP = np.zeros(len(N)); # result vector computation time
tspanRQA = np.zeros(len(N)); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 600; # stop calculations if maxT is exceeded
dt = 0.05; # sampling time


with open(filename, "w") as f:
   for i in range(0,len(tspanRP)):
       tRP_ = 0
       tRQA_ = 0
       # initialize calculation (avoids artifical large compute times for first run)
       x = odeint(roessler, np.random.rand(3), np.arange(0, dt*(1000+N[i]), .05))
       output_RR = rqa.RR(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);
       output_DET = rqa.DET(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([2], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);
       output_LAM = rqa.LAM(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([2], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);
       gc.disable()

       for j in range(0,K):

           # solve the ODE
           x = odeint(roessler, np.random.rand(3), np.arange(0, dt*(1000+N[i]), .05))

           start_time = time.time()

           output_RR = rqa.RR(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);
           output_DET = rqa.DET(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([2], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);
           output_LAM = rqa.LAM(x[1000:(1000+N[i]),0], np.array([6], dtype=np.intc), np.array([3], dtype=np.intc), np.array([2], dtype=np.intc), np.array([1.2]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag), tidy_data = False);

           #tRP_ += (time.time() - start_time)
           tRQA_ += (time.time() - start_time)
           
       tspanRP[i] = tRP_ / K # average calculation time
       tspanRQA[i] = tRQA_ / K # average calculation time
       print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])
       gc.enable()

       # save results
       f.write(f"{N[i]}, {tspanRQA[i]}\n")
       f.flush()

       if tspanRP[i] + tspanRQA[i] >= maxT:
          break
