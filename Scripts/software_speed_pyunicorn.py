# speed test

# import required packages
import numpy as np
import time
import gc
from pyunicorn.timeseries import RecurrencePlot

# results files
timeResultsfile = '../Results/time_python_pyunicorn.csv'
rqaResultsfile = '../Results/rqa_python_pyunicorn.csv'

# data file
datafile = '../Libs/roessler.csv'

# import data
x = np.loadtxt(datafile)

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(60000.),.075)). astype(int)

# calculate RP and RQA for different length
tspanRPlast = 0;                # current calculation time (used for skipping calculation)
tspanRQAlast = 0;               # current calculation time (used for skipping calculation)
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

       gc.disable()

       for j in range(0,K):

           try:
               if tspanRPlast <= maxT:
                   start_time = time.time()
                   R = RecurrencePlot(x[0:N[i]], dim=m, tau=tau, metric="euclidean",
                                   normalize=False, threshold=e, silence_level=12)
                   tRP_ += (time.time() - start_time)
               else:
                   tRP_ = NaN;
               if tspanRQAlast <= maxT:
                   start_time = time.time()
                   rr = R.recurrence_rate()
                   det = R.determinism(l_min=lmin)
                   l = R.average_diaglength(l_min=lmin)
                   ent = R.diag_entropy(l_min=lmin)
                   lam = R.laminarity(v_min=lmin)
                   tt = R.trapping_time(v_min=lmin)
                   tRQA_ += (time.time() - start_time)
                   RQA_[j,:] = [rr, det, l, ent, lam, tt]
               else
                   RQA_[j,:] = np.nan
           except:
               tP_ = np.nan
               tRQA_ = np.nan
               RQA_[j,:] = np.nan
               break

       gc.enable()

       tspanRP[i] = tRP_ / K             # average calculation time
       tspanRQA[i] = tRQA_ / K           # average calculation time
       tspanRPlast = tspanRP[i];
       tspanRQAlast = tspanRQA[i)];
       mRQA[i,:] = np.mean(RQA_, axis=0) # average RQA
       vRQA[i,:] = np.var(RQA_, axis=0)  # variance RQA
       print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])

       # save results
       f_time.write(f"{N[i]}, {tspanRP[i]}, {tspanRP[i]+tspanRQA[i]}\n") # RQA needs precalculated RP
       f_time.flush()
       f_rqa.write(f"{N[i]}, {', '.join(str(v) for v in mRQA[i,:])}, {', '.join(str(v) for v in vRQA[i,:])}\n")
       f_rqa.flush()

       # stop if calculation exceeds limit
       if tspanRPlast >= maxT and tspanRQAlast >= maxT:
          break
