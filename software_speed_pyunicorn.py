# speed test

# import required packages
from scipy.integrate import odeint
import numpy as np
import time
from pyunicorn.timeseries import RecurrencePlot

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# solve the ODE
x = odeint(roessler, [0, 0, 0], np.arange(0, 5500, .05))

# length of time series for RQA calculation test
N = np.round(10**np.arange(2.3,5.06,.075)). astype(int)


# calculate RP and RQA for different length
tspanRP = np.zeros(len(N)); # result vector computation time
tspanRQA = np.zeros(len(N)); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 60; # stop calculations if maxT is exceeded

for i in range(0,len(tspanRP)):
    tRP_ = 0
    tRQA_ = 0
    for j in range(0,K):
        start_time = time.time()
        R = RecurrencePlot(x[1000:(1000+N[i]),0], dim=3, tau=6, metric="euclidean",
                        normalize=False, threshold=1.2, silence_level=12)
        tRP_ += (time.time() - start_time)
        start_time = time.time()
        Q = R.rqa_summary(l_min=2)           
        Q2 = R.white_vert_entropy()        
        tRQA_ += (time.time() - start_time)
        print("  ", j)
    tspanRP[i] = tRP_ / K # average calculation time
    tspanRQA[i] = tRQA_ / K # average calculation time
    print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])
    
    if tspanRP[i] + tspanRQA[i] >= maxT:
       break

tspanRP

np.savetxt('time_python_pyunicorn.csv',list(zip(N, tspanRP, tspanRQA)))

