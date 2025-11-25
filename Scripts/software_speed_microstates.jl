# speed test

# import required packages
using DelayEmbeddings
using DelimitedFiles
using RecurrenceMicrostatesAnalysis

# results file
timeResultsfile = "../Results/time_julia_microstates.csv"
rqaResultsfile = "../Results/rqa_julia_microstates.csv"

# data file
datafile = "../Libs/roessler.csv"

# import data
x = readdlm(datafile)

# define RQA using microstates approach
function rqa(x,e,m)
    dist = distribution(x', e, m);
    RR = rrate(dist)            # Recurrence rate
    DET = determinism(RR, dist) # Determinism
    LAM = laminarity(RR, dist)  # Laminarity
    return RR, DET, LAM
end


# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(500000.)));


# calculate  RQA for different length
tspanRP = fill(NaN, length(N), 1)  # result vector computation time
tspanRQA = fill(NaN, length(N), 1) # result vector computation time
mRQA = zeros(length(N), 6);        # result vector RQA average
vRQA = zeros(length(N), 6);        # result vector RQA variance
K = 10;                            # number of runs (for averaging time)
maxT = 600;                        # stop calculations if maxT is exceeded
m = 3                              # motif size
e = 1.2;                           # recurrence threshold
lmin = 2;                          # minimal line length


# dry run to pre-compile
Q = rqa(x[1:1000], e, m);

open(timeResultsfile, "w") do f_time
   open(rqaResultsfile, "w") do f_rqa
       for (i,N_) in enumerate(N)

          tRQA_ = 0;
          RQA_ = zeros(K, 6)
          for j in 1:K
              try
                  t = @timed local Q = rqa(x[1:N_], e, m);
                  tRQA_ = tRQA_ + t.time;
                  RQA_[j,:] = [Q[1], Q[2], NaN, NaN, Q[3], NaN]
              catch
                  tRQA_ = NaN
                  RQA_[j,:] = [NaN,NaN,NaN,NaN,NaN,NaN]
                  println("ERROR: Skip")
              end
          end
          tspanRQA[i] = tRQA_ / K; # average calculation time
          mRQA[i, :] = mean(RQA_, dims = 1) # average RQA
          vRQA[i, :] = var(RQA_, dims = 1)  # variance RQA
          print(N_, ": ", tspanRQA[i],"\n")
          flush(stdout)

          # save results
          write(f_time, "$N_, $(tspanRP[i]), $(tspanRQA[i]), $(tspanRP[i] + tspanRQA[i])\n")
          flush(f_time)
          write(f_rqa, string(N[i], ", ", join(mRQA[i, :], ", "), ", ", join(vRQA[i, :], ", "), "\n"))
          flush(f_rqa)

          if tspanRQA[i] >= maxT
            break
          end
       end
   end
end
