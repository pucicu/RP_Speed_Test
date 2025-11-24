# speed test

# import required packages
import numpy as np
import time
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

# results files
timeResultsfile = f'../Results/time_python_accrqa_{compFlag}.csv'
rqaResultsfile = f'../Results/rqa_python_accrqa_{compFlag}.csv'

# data file
datafile = '../Libs/roessler.csv'

# import data
x = np.loadtxt(datafile)

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(1000000.),.075)). astype(int)

# calculate RP and RQA for different length
tspanRP = np.zeros(len(N));     # result vector computation time
tspanRQA = np.zeros(len(N));    # result vector computation time
mRQA = np.zeros((len(N), 6));   # result vector RQA average
vRQA = np.zeros((len(N), 6));   # result vector RQA variance
K = 10;                         # number of runs (for averaging time)
maxT = 600;                     # stop calculations if maxT is exceeded
m = 3;                          # embedding dimension
tau = 6;                        # embedding delay
e = 1.2;                        # recurrence threshold
lmin = 2;                       # minimal line length

with open(timeResultsfile, "w") as f_time, open(rqaResultsfile, "w") as f_rqa:
   for i in range(0,len(tspanRP)):
       tRP_ = 0
       tRQA_ = 0
       RQA_ = np.zeros((K, 6))

       rp = rqa.RP(x[0:N[i]], tau, m, e, distance_type=rqa.accrqaDistance("euclidean"));
       det = rqa.DET(x[0:N[i]], np.array([tau], dtype=np.intc), np.array([m], dtype=np.intc), np.array([lmin], dtype=np.intc), np.array([e]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag));
       lam = rqa.LAM(x[0:N[i]], np.array([tau], dtype=np.intc), np.array([m], dtype=np.intc), np.array([lmin], dtype=np.intc), np.array([e]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = False, comp_platform = rqa.accrqaCompPlatform(compFlag));

       for j in range(0,K):

           start_time = time.time()
           rp = rqa.RP(x[0:N[i]], tau, m, e, distance_type=rqa.accrqaDistance("euclidean"));
           tRP_ += (time.time() - start_time)
           
           start_time = time.time()
           det = rqa.DET(x[0:N[i]], np.array([tau], dtype=np.intc), np.array([m], dtype=np.intc), np.array([lmin], dtype=np.intc), np.array([e]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = True, comp_platform = rqa.accrqaCompPlatform(compFlag));
           lam = rqa.LAM(x[0:N[i]], np.array([tau], dtype=np.intc), np.array([m], dtype=np.intc), np.array([lmin], dtype=np.intc), np.array([e]), distance_type=rqa.accrqaDistance("euclidean"), calculate_ENTR = False, comp_platform = rqa.accrqaCompPlatform(compFlag));
           tRQA_ += (time.time() - start_time)

           RQA_[j,:] = [det.RR.item(), det.DET.item(), det.L.item(), det.ENTR.item(), lam.LAM.item(), lam.TT.item()]
           time.sleep(.1)                # wait until process has finished
           
       tspanRP[i] = tRP_ / K             # average calculation time
       tspanRQA[i] = tRQA_ / K           # average calculation time
       mRQA[i,:] = np.mean(RQA_, axis=0) # average RQA
       vRQA[i,:] = np.var(RQA_, axis=0)  # variance RQA
       print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])

       # save results
       f_time.write(f"{N[i]}, {tspanRP[i]}, {tspanRQA[i]}\n")
       f_time.flush()
       f_rqa.write(f"{N[i]}, {', '.join(str(v) for v in mRQA[i,:])}, {', '.join(str(v) for v in vRQA[i,:])}\n")
       f_rqa.flush()

       if tspanRP[i] + tspanRQA[i] >= maxT:
          break
