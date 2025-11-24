# speed test
# import required packages
from scipy.integrate import odeint
import numpy as np
import time
import gc
from pyrqa.time_series import TimeSeries
from pyrqa.settings import Settings
from pyrqa.analysis_type import Classic
from pyrqa.neighbourhood import FixedRadius
from pyrqa.metric import EuclideanMetric
from pyrqa.computation import RQAComputation

# results file
filename = '../Results/time_python_pyrqa.csv'

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(1000000.),.075)). astype(int)


# calculate RP and RQA for different length
tspan = np.zeros(len(N)); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 600; # stop calculations if maxT is exceeded
dt = 0.05; # sampling time


# dry run to setup environment
x = odeint(roessler, np.random.rand(3), np.arange(0, dt*5000, .05))

xe = TimeSeries(x[:,0], embedding_dimension=3, time_delay=6)
settings = Settings(xe,
           analysis_type=Classic,
           neighbourhood=FixedRadius(1.2),
           similarity_measure=EuclideanMetric,
           theiler_corrector=1)
computation = RQAComputation.create(settings, verbose=True)
R = computation.run()

# computation loop testing different time series lenghts
with open(filename, "w") as f:
   for i in range(0,len(tspan)):

       # solve the ODE
       x = odeint(roessler, np.random.rand(3), np.arange(0, dt*(1000+N[i]), .05))

       xe = TimeSeries(x[1000:(1000+N[i]),0],
                       embedding_dimension=3,
                       time_delay=6)
       settings = Settings(xe,
                       analysis_type=Classic,
                       neighbourhood=FixedRadius(1.2),
                       similarity_measure=EuclideanMetric,
                       theiler_corrector=1)
       t_ = 0
       gc.disable()
       for j in range(0, K):

           try:
               computation = RQAComputation.create(settings, verbose=False)
               start_time = time.time()
               R = computation.run()
               t_ += (time.time() - start_time)
           except:
               R = 0
               t_ = np.nan
               break
           
       tspan[i] = t_ / K # average calculation time
       print(N[i], ": ", tspan[i])
       gc.enable()

       # save results
       f.write(f"{N[i]}, {tspan[i]}\n")
       f.flush()

       if tspan[i] >= maxT:
          break
