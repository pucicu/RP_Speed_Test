# speed test

# import required packages
using DelayEmbeddings
using DynamicalSystems
using DelimitedFiles
using ArgParse


# find argument for prallelisation
s = ArgParseSettings(description = "Set parallel computation")

@add_arg_table s begin
    "--parallel"
        help = "Set parallel computation: 'true' or 'false' (default: 'true')"
        arg_type = String
        default = "true"
end

args = parse_args(s)
parallel = lowercase(args["parallel"]) in ["true", "t", "1"]

println("Active threads: ", Threads.nthreads())

# results file
timeResultsfile = "../Results/time_julia_single.csv"
rqaResultsfile = "../Results/rqa_julia_single.csv"
if parallel
    timeResultsfile = "../Results/time_julia_parallel.csv"
    rqaResultsfile = "../Results/rqa_julia_parallel.csv"
end

# data file
datafile = "../Libs/roessler.csv"

# import data
x = readdlm(datafile)

# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(500000.)));


# calculate RP and RQA for different length
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
xe = embed(x[1:1500], m, tau);
R = RecurrenceMatrix(xe, e, parallel=parallel);
Q = rqa(R, theiler = 1, onlydiagonal=false, parallel=parallel);

open(timeResultsfile, "w") do f_time
   open(rqaResultsfile, "w") do f_rqa
       for (i,N_) in enumerate(N)

          tRP_ = 0;
          tRQA_ = 0;
          RQA_ = zeros(K, 6)
          for j in 1:K
              try
                 xe = embed(x[1:N_], m, tau);
                 t1 = @timed local R = RecurrenceMatrix(xe, 1.2, parallel=parallel)
                 t2 = @timed local Q = rqa(R, theiler = 1, onlydiagonal=false, parallel=parallel)
                 tRP_ = tRP_ + t1.time;
                 tRQA_ = tRQA_ + t2.time;
                 RQA_[j,:] = [Q[:RR], Q[:DET], Q[:L], Q[:ENTR], Q[:LAM], Q[:TT]]

              catch
                 tRP_ = NaN
                 tRQA_ = NaN
                 RQA_[j,:] = [NaN,NaN,NaN,NaN,NaN,NaN]
              end
          end
          tspanRP[i] = tRP_ / K;            # average calculation time
          tspanRQA[i] = tRQA_ / K;          # average calculation time
          mRQA[i, :] = mean(RQA_, dims = 1) # average RQA
          vRQA[i, :] = var(RQA_, dims = 1)  # variance RQA

          print(N_, ": ", tspanRP[i], " - ", tspanRQA[i],"\n")
          flush(stdout)

          # save results
          write(f_time, "$N_, $(tspanRP[i]), $(tspanRQA[i]), $(tspanRP[i] + tspanRQA[i])\n")
          flush(f_time)
          write(f_rqa, string(N[i], ", ", join(mRQA[i, :], ", "), ", ", join(vRQA[i, :], ", "), "\n"))
          flush(f_rqa)

          if tspanRP[i] + tspanRQA[i] >= maxT
            break
          end
       end
   end
end
