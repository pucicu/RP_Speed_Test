# speed test

# import required packages
using DelayEmbeddings
using DelimitedFiles
include("../Libs/RPLineLengths.jl")

# results file
timeResultsfile = "../Results/time_julia_RQA_Samp.csv"
rqaResultsfile = "../Results/rqa_julia_RQA_Samp.csv"

# data file
datafile = "../Libs/roessler.csv"

# import data
x = readdlm(datafile)

# define RQA using sampling approach RQA_Samp
function rqa(x,e,M)
    P, N = get_hist_diagonal_sampled(x, e, M) # histogram of line lengths
    p = P / sum(P)                         # probability distribution
    RR = sum((1:length(P)) .* P) / (N + sum((1:length(P)) .* (P .-1)))
    DET = sum((2:length(p)) .* P[2:end]) / sum((1:length(P)) .* P)
    L = sum((2:length(P)) .* P[2:end]) / sum(P[2:end])
    ENTR = -sum(pi > 0 ? pi * log(pi) : 0 for pi in p)
    return RR, DET, L, ENTR, NaN, NaN
end


# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(2000000.)));


# calculate  RQA for different length
tspanRP = fill(NaN, length(N), 1)  # result vector computation time
tspanRQA = fill(NaN, length(N), 1) # result vector computation time
mRQA = zeros(length(N), 6);        # result vector RQA average
vRQA = zeros(length(N), 6);        # result vector RQA variance
K = 10;                            # number of runs (for averaging time)
maxT = 600;                        # stop calculations if maxT is exceeded
m = 3;                             # embedding dimension
tau = 6;                           # embedding delay
e = 1.2;                           # recurrence threshold
lmin = 2;                          # minimal line length


# dry run to pre-compile
xe = embed(x[1:1000], m, tau);
xe_ = reduce(hcat, xe.data)';
M = 4 * length(xe)               # number of random subsamples for RQA_Samp
Q = rqa(xe_, e, M);

open(timeResultsfile, "w") do f_time
   open(rqaResultsfile, "w") do f_rqa
       for (i,N_) in enumerate(N)

          tRQA_ = 0;
          RQA_ = zeros(K, 6)
          for j in 1:K
              local xe = embed(x[1:N_], m, tau);
              local xe_ = reduce(hcat, xe.data)';
              try
                  local M = 4 * length(xe) # number of random subsamples 
                  t = @timed local Q = rqa(xe_, e, M);
                  tRQA_ = tRQA_ + t.time;
                  RQA_[j,:] .= Q
              catch
                  tRQA_ = NaN
                  RQA_[j,:] = [NaN,NaN,NaN,NaN,NaN,NaN]
                  println("ERROR: Skip")
              end
              flush(stdout)
          end
          tspanRQA[i] = tRQA_ / K; # average calculation time
          mRQA[i, :] = mean(RQA_, dims = 1) # average RQA
          vRQA[i, :] = var(RQA_, dims = 1)  # variance RQA
          print(N_, ": ", tspanRQA[i],"\n")
          flush(stdout)

          # save results
          write(f_time, "$N_, $(tspanRP[i]), $(tspanRQA[i])\n")
          flush(f_time)
          write(f_rqa, string(N[i], ", ", join(mRQA[i, :], ", "), ", ", join(vRQA[i, :], ", "), "\n"))
          flush(f_rqa)

          if tspanRQA[i] >= maxT
            break
          end
       end
   end
end
