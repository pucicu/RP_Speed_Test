# speed test

# import required packages
from scipy.integrate import odeint
import numpy as np
import time
import sys
sys.path.append('..')
from Libs.rp import *

# results file
filename = '../Results/time_python_simple.csv'

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# solve the ODE
x = odeint(roessler, np.random.rand(3), np.arange(0, 5500, .05))

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(500000.),.075)). astype(int)


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
       for j in range(0,K):
           x = odeint(roessler, np.random.rand(3), np.arange(0, dt*(1000+N[i]), .05))
           xe = embed(x[1000:(1000+N[i]),0], 3, 6)

           try:
               start_time = time.time()
               R = rp(xe, 1.2)
               tRP_ += (time.time() - start_time)
               start_time = time.time()
               Q1 = np.mean(R)
               Q2 = det(R, lmin=2, hist=None, verb=False)
               Q3 = entr(R, lmin=2, hist=None, verb=False)
               tRQA_ += (time.time() - start_time)
           except:
               tRP_ = np.nan
               tRQA_ = np.nan
               break

       tspanRP[i] = tRP_ / K # average calculation time
       tspanRQA[i] = tRQA_ / K # average calculation time
       print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])

       # save results
       f.write(f"{N[i]}, {tspanRP[i]}, {tspanRQA[i]}\n")

       if tspanRP[i] + tspanRQA[i] >= maxT:
          break
