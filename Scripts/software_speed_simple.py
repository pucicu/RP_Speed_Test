# speed test

# import required packages
import numpy as np
import time
import sys
sys.path.append('..')
from Libs.rp import *

# results files
timeResultsfile = '../Results/time_python_simple.csv'
rqaResultsfile = '../Results/rqa_python_simple.csv'

# data file
datafile = '../Libs/roessler.csv'

# import data
x = np.loadtxt(datafile)

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(100000.),.075)). astype(int)


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
       for j in range(0,K):

           xe = embed(x[0:N[i]], m, tau)

           try:
               if tspanRPlast <= maxT:
                   start_time = time.time()
                   R = rp(xe, e)
                   tRP_ += (time.time() - start_time)
               else:
                   tRP_ = NaN;
               if tspanRQAlast <= maxT:
                   start_time = time.time()
                   Q1 = np.mean(R)
                   Q2 = det(R, lmin=lmin, hist=None, verb=False)
                   Q3 = entr(R, lmin=lmin, hist=None, verb=False)
                   tRQA_ += (time.time() - start_time)
                   RQA_[j,:] = [Q1, Q2, np.nan, Q3, np.nan, np.nan]
               else
                   RQA_[j,:] = np.nan
           except:
               tRP_ = np.nan
               tRQA_ = np.nan
               RQA_[j,:] = np.nan
               break

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

       if tspanRPlast >= maxT and tspanRQAlast >= maxT:
          break

