# speed test
# import required packages
from scipy.integrate import odeint
import numpy as np
import time
from pyrqa.time_series import TimeSeries
from pyrqa.settings import Settings
from pyrqa.analysis_type import Classic
from pyrqa.neighbourhood import FixedRadius
from pyrqa.metric import EuclideanMetric
from pyrqa.computation import RQAComputation

# the Roessler ODE
def roessler(x,t):
   return [-(x[1] + x[2]), x[0] + 0.25 * x[1], 0.25 + (x[0] - 4) * x[2]]

# solve the ODE
x = odeint(roessler, [0, 0, 0], np.arange(0, 5500, .05))

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(500000.),.075)). astype(int)


# calculate RP and RQA for different length
tspan = np.zeros(len(N)); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 50; # stop calculations if maxT is exceeded

for i in range(0,len(tspan)):
    xe = TimeSeries(x[1000:(1000+N[i]),0],
                         embedding_dimension=3,
                         time_delay=6)
    settings = Settings(xe,
                    analysis_type=Classic,
                    neighbourhood=FixedRadius(1.2),
                    similarity_measure=EuclideanMetric,
                    theiler_corrector=1)
    computation = RQAComputation.create(settings,
                                    verbose=True)
    t_ = 0
    for j in range(0, K):
        start_time = time.time()
        R = computation.run()
        t_ += (time.time() - start_time)
    tspan[i] = t_ / K # average calculation time
    print(N[i])
    
    if tspan[i] >= maxT:
       break

tspan

np.savetxt('time_python_pyrqa.csv',list(zip(N[4:],tspan[4:])))



