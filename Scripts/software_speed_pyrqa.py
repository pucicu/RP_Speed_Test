# speed test
# import required packages
import numpy as np
import time
from pyrqa.time_series import TimeSeries
from pyrqa.settings import Settings
from pyrqa.analysis_type import Classic
from pyrqa.neighbourhood import FixedRadius
from pyrqa.metric import EuclideanMetric
from pyrqa.computation import RQAComputation
from pyrqa.computation import RPComputation

# results files
timeResultsfile = '../Results/time_python_pyrqa.csv'
rqaResultsfile = '../Results/rqa_python_pyrqa.csv'

# data file
datafile = '../Libs/roessler.csv'

# import data
x = np.loadtxt(datafile)

# length of time series for RQA calculation test
N = np.round(10**np.arange(np.log10(200.),np.log10(10000.),.075)). astype(int)

# calculate RP and RQA for different length
tspanRP = np.zeros(len(N));     # result vector computation time
tspanRQA = np.zeros(len(N));    # result vector computation time
mRQA = np.zeros((len(N), 6));   # result vector RQA average
vRQA = np.zeros((len(N), 6));   # result vector RQA variance
K = 10;                         # number of runs (for averaging time)
maxT = 600;                     # stop calculations if maxT is exceeded
dt = 0.05;                      # sampling time
m = 3;                          # embedding dimension
tau = 6;                        # embedding delay
e = 1.2;                        # recurrence threshold
lmin = 2;                       # minimal line length



# dry run to setup environment
xe = TimeSeries(x[1:10000], embedding_dimension=m, time_delay=tau)
settings = Settings(xe,
           analysis_type=Classic,
           neighbourhood=FixedRadius(e),
           similarity_measure=EuclideanMetric,
           theiler_corrector=1)
rqaComputation = RQAComputation.create(settings, verbose=True)
R = rqaComputation.run()

rpComputation = RPComputation.create(settings, verbose=True)
R = rpComputation.run()

# computation loop testing different time series lenghts
with open(timeResultsfile, "w") as f_time, open(rqaResultsfile, "w") as f_rqa:
   for i in range(0,len(tspanRP)):

       tRP_ = 0
       tRQA_ = 0
       RQA_ = np.zeros((K, 6))

       xe = TimeSeries(x[9:N[i]],
                       embedding_dimension=m,
                       time_delay=tau)
       settings = Settings(xe,
                       analysis_type=Classic,
                       neighbourhood=FixedRadius(e),
                       similarity_measure=EuclideanMetric,
                       theiler_corrector=1)
       for j in range(0, K):

           try:
               start_time = time.time()
               rpComputation = RPComputation.create(settings, verbose=False)
               rpR = rpComputation.run()
               tRP_ += (time.time() - start_time)
               
               start_time = time.time()
               rqaComputation = RQAComputation.create(settings, verbose=False)
               R = rqaComputation.run()
               R.min_diagonal_line_length = lmin
               R.min_vertical_line_length = lmin

               rr = R.recurrence_rate
               det = R.determinism
               l = R.average_diagonal_line
               entr = R.entropy_diagonal_lines
               lam = R.laminarity
               tt = R.trapping_time
               
               tRQA_ += (time.time() - start_time)
               RQA_[j,:] = [rr, det, l, entr, lam, tt]
           except:
               print(f'Error in run {i}')
               R = 0
               tRP_ = np.nan
               tRQA_ = np.nan
               RQA_[j,:] = [np.nan,np.nan,np.nan,np.nan,np.nan,np.nan]
               break

       tspanRP[i] = tRP_ / K             # average calculation time
       tspanRQA[i] = tRQA_ / K           # average calculation time
       mRQA[i,:] = np.mean(RQA_, axis=0) # average RQA
       vRQA[i,:] = np.var(RQA_, axis=0)  # average RQA
       print(N[i], ": ", tspanRP[i], " ", tspanRQA[i])

       # save results
       f_time.write(f"{N[i]}, {tspanRP[i]}, {tspanRQA[i]}\n")
       f_time.flush()
       f_rqa.write(f"{N[i]}, {', '.join(str(v) for v in mRQA[i,:])}, {', '.join(str(v) for v in vRQA[i,:])}\n")
       f_rqa.flush()

       if tspanRP[i] + tspanRQA[i] >= maxT:
          break
