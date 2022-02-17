# speed test

# import required packages
from scipy.integrate import odeint
import numpy as np
import time
from rp import *

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# solve the ODE
x = odeint(roessler, [0, 0, 0], np.arange(0, 5500, .05))

# length of time series for RQA calculation test
N = np.round(10**np.arange(2.3,4.65,.075)). astype(int)


# calculate RP and RQA for different length
tspan = np.zeros(len(N)); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 30; # stop calculations if maxT is exceeded

for i in range(0,len(tspan)):
    t_ = 0
    for j in range(0,K):
        start_time = time.time()
        R = rp(x[1000:(1000+N[i]),2], 3, 6, 1.2)
        Q1 = mean(R)
        Q2 = det(R, lmin=2, hist=None, verb=False)
        Q3 = entr(R, lmin=2, hist=None, verb=False)
        t_ += (time.time() - start_time)
        print("  ", j)
    tspan[i] = t_ / K # average calculation time
    print(N[i], ": ", tspan[i])
    
    if tspan[i] >= maxT:
       break

tspan

np.savetxt('time_python_default.csv',list(zip(N,tspan)))

