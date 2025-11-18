# speed test

# import required packages
using OrdinaryDiffEq
using DelayEmbeddings
using DelimitedFiles
using RecurrenceMicrostatesAnalysis

# Define RQA using microstates approach
function rqa(x,e,m)
    dist = distribution(x', e, m);
    RR = rrate(dist)           # Recurrence rate
    DET = determinism(RR, dist) # Determinism
end

# the Roessler ODE
function roessler!(dx, x, p, t)
    dx[1] = -(x[2] + x[3]);
    dx[2] = x[1] + 0.25 * x[2];
    dx[3] = 0.25 + (x[1] - 4) * x[3];
end

# solve the ODE        
dt = 0.05; # sampling time
prob = ODEProblem(roessler!, rand(3), (0.,20500.));
sol = solve(prob, Tsit5(), dt=dt,saveat=dt);
x = embed(sol[1,1000:1500], 3, 6);

# length of time series for RQA calculation test
N = round.(Int, 10 .^ (log10(200.):.075:log10(500000.)));


# calculate  RQA for different length
tspanRP = zeros(length(N),1); # result vector computation time
tspanRQA = zeros(length(N),1); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 600; # stop calculations if maxT is exceeded
m = 3 # motif size


# dry run to pre-compile
x = reduce(hcat,x)'
Q = rqa(x, 1.2, m);

for (i,N_) in enumerate(N)

   tRQA_ = 0;
   for j in 1:K
       local prob = ODEProblem(roessler!, rand(3), (0., dt*(1000+N_)));
       local sol = solve(prob, Tsit5(), dt=dt,saveat=dt);
       local x = embed(sol[1,1000:1000+N_], 3, 6);
       x = reduce(hcat,x)'
       try
           t = @timed local Q = rqa(x, 1.2, m);
           tRQA_ = tRQA_ + t.time;
       catch
           tRQA_ = NaN
           println("ERROR: Skip")
       end
       flush(stdout)
   end
   tspanRQA[i] = tRQA_ / K; # average calculation time
   print(N_, ": ", tspanRQA[i],"\n")
   flush(stdout)
   
   if tspanRQA[i] >= maxT
     break
   end
end


filename = "time_julia_microstates.csv"

open(filename, "w") do io
   writedlm(io, [N tspanRQA], ',')
end;
       

