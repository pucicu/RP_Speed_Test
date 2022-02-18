# speed test

# import required packages
using OrdinaryDiffEq
using DelayEmbeddings
using DynamicalSystems
using DelimitedFiles


# the Roessler ODE
function roessler!(dx, x, p, t)
    dx[1] = -(x[2] + x[3]);
    dx[2] = x[1] + 0.25 * x[2];
    dx[3] = 0.25 + (x[1] - 4) * x[3];
end

# solve the ODE        
dt = 0.05;
prob = ODEProblem(roessler!, [0., 0., 0.], (0.,5500.));
sol = solve(prob, Tsit5(), dt=dt,saveat=dt);

# length of time series for RQA calculation test
N = round.(Int, 10 .^ (2.3:.075:4.65));


# calculate RP and RQA for different length
tspanRP = zeros(length(N),1); # result vector computation time
tspanRQA = zeros(length(N),1); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 30; # stop calculations if maxT is exceeded

# dry run to pre-compile
x = embed(sol[1,1000:1500], 3, 6);
R = RecurrenceMatrix(x, 1.2, parallel=false);
Q = rqa(R, theiler = 1, onlydiagonal=false);

for (i,N_) in enumerate(N)
   x = embed(sol[1,1000:1000+N_], 3, 6);
   tRP_ = 0;
   tRQA_ = 0;
   for j in 1:K
       t1 = @elapsed R = RecurrenceMatrix(x, 1.2, parallel=false);
       t2 = @elapsed Q = rqa(R, theiler = 1, onlydiagonal=false);
       tRP_ = tRP_ + t1;
       tRQA_ = tRQA_ + t2;
       print("  " ,j, "\n")
   end
   tspanRP[i] = tRP_ / K; # average calculation time
   tspanRQA[i] = tRQA_ / K; # average calculation time
   print(N_, ": ", tspanRP[i], " - ", tspanRQA[i],"\n")
   
   if tspanRP[i] + tspanRQA[i] >= maxT
     break
   end
end

tspanRP

open("time_julia.csv", "w") do io
   writedlm(io, [N tspanRP tspanRQA], ',')
end;
       

