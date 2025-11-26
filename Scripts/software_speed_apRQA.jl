# speed test

# import required packages
Pkg.activate("../Libs/apRQA")
using OrdinaryDiffEq
using DelimitedFiles
using apRQA


# results file
filename = "../Results/time_julia_apRQA.csv"


# the Roessler ODE
function roessler!(dx, x, p, t)
    dx[1] = -(x[2] + x[3]);
    dx[2] = x[1] + 0.25 * x[2];
    dx[3] = 0.25 + (x[1] - 4) * x[3];
end

# solve the ODE        
dt = 0.05; # sampling time
prob = ODEProblem(roessler!, rand(3), (0.,dt*(2000000+1000)));
sol = solve(prob, Tsit5(), dt=dt,saveat=dt);

# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(2000000.)));


# calculate RP and RQA for different length
tspanRP = zeros(length(N),1); # result vector computation time
tspanRQA = zeros(length(N),1); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 600; # stop calculations if maxT is exceeded

# dry run to pre-compile
x = sol[1,1000:1500]
RR, DET, L, LAM = approximate_rqa(sol[1,1000:1500], 1.2, 2);

open(filename, "w") do io
   for (i,N_) in enumerate(N)

      tRP_ = 0;
      tRQA_ = 0;
      for j in 1:K
          local x = sol[1,1000:1000+N_];

          try
             t = @timed local Q = RR, DET, L, LAM = approximate_rqa(x, 1.2, 2);
             tRP_ = NaN;
             tRQA_ = tRQA_ + t.time;
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
      write(io, "$N_, $(tspanRP[i]), $(tspanRQA[i]), $(tspanRP[i] + tspanRQA[i])\n")
      flush(io)

      if tspanRP[i] + tspanRQA[i] >= maxT
        break
      end
   end
end
