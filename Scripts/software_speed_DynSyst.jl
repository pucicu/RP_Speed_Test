# speed test

# import required packages
using OrdinaryDiffEq
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


# results file
filename = "../Results/time_julia_single.csv"
if parallel
    filename = "../Results/time_julia_parallel.csv"
end



println("Active threads: ", Threads.nthreads())

# the Roessler ODE
function roessler!(dx, x, p, t)
    dx[1] = -(x[2] + x[3]);
    dx[2] = x[1] + 0.25 * x[2];
    dx[3] = 0.25 + (x[1] - 4) * x[3];
end

# solve the ODE        
dt = 0.05; # sampling time
prob = ODEProblem(roessler!, rand(3), (0.,10500.));
sol = solve(prob, Tsit5(), dt=dt,saveat=dt);

# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(500000.)));


# calculate RP and RQA for different length
tspanRP = zeros(length(N),1); # result vector computation time
tspanRQA = zeros(length(N),1); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 600; # stop calculations if maxT is exceeded

# dry run to pre-compile
x = embed(sol[1,1000:1500], 3, 6);
R = RecurrenceMatrix(x, 1.2, parallel=parallel);
Q = rqa(R, theiler = 1, onlydiagonal=true, parallel=parallel);

open(filename, "w") do io
   for (i,N_) in enumerate(N)

      tRP_ = 0;
      tRQA_ = 0;
      for j in 1:K
          local prob = ODEProblem(roessler!, rand(3), (0., dt*(1000+N_)));
          local sol = solve(prob, Tsit5(), dt=dt,saveat=dt);
          local x = embed(sol[1,1000:1000+N_], 3, 6);

          try
             t1 = @timed local R = RecurrenceMatrix(x, 1.2, parallel=parallel)
             t2 = @timed local Q = rqa(R, theiler = 1, onlydiagonal=true, parallel=parallel)
             tRP_ = tRP_ + t1.time;
             tRQA_ = tRQA_ + t2.time;
          catch
             tRP_ = NaN
             tRQA_ = NaN
          end
          flush(stdout)
      end
      tspanRP[i] = tRP_ / K; # average calculation time
      tspanRQA[i] = tRQA_ / K; # average calculation time
      print(N_, ": ", tspanRP[i], " - ", tspanRQA[i],"\n")
      flush(stdout)

      # save results
      write(io, "$N_, $(tspanRP[i]), $(tspanRQA[i])\n")
      flush(io)

      if tspanRP[i] + tspanRQA[i] >= maxT
        break
      end
   end
end
