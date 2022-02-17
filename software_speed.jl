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
tspan = zeros(length(N),1); # result vector computation time
K = 10; # number of runs (for averaging time)
maxT = 30; # stop calculations if maxT is exceeded

# dry run to pre-compile
x = embed(sol[3,1000:1500], 3, 6);
t1 = @elapsed R = RecurrenceMatrix(x, 1.2);
t2 = @elapsed Q = rqa(R, theiler = 1);

for (i,N_) in enumerate(N)
   x = embed(sol[3,1000:1000+N_], 3, 6);
   t_ = 0;
   for j in 1:K
       t1 = @elapsed R = RecurrenceMatrix(x, 1.2);
       t2 = @elapsed Q = rqa(R, theiler = 1);
       t_ = t_ + t1 + t2;
       print("  " ,j, "\n")
   end
   tspan[i] = t_ / K; # average calculation time
   print(N_, ": ", tspan[i], "\n")
   
   if tspan[i] >= maxT
     break
   end
end

tspan

open("time_julia.csv", "w") do io
   writedlm(io, [N tspan], ',')
end;
       

