# speed test

# import required packages
#install.packages("nonlinearTseries")
#install.packages("crqa")
#install.packages("abind")
#install.packages("tictoc")

require(stats)
library(tictoc)
library(nonlinearTseries)
library(crqa)
library(abind)

# solve the Roessler ODE        
r = rossler(time=seq(0,4500,by = 0.05));
x = r$x

# length of time series for RQA calculation test
N = round(10.^seq(2.3,4.35, 0.075))


# calculate RP and RQA for different length
tspan = numeric(length(N)) # result vector computation time
K = 10 # number of runs (for averaging time)
maxT = 30 # stop calculations if maxT is exceeded

for (i in 1:length(N)) {
   t_ = 0
   for (j in 1:K) {
       start_time <- Sys.time()
       R <- crqa(x[1000:(1000+N[i]-1)], x[1000:(1000+N[i]-1)], 3, 6, 0, 1.2, 0, 2, 2, 0, FALSE, FALSE, 'both', 'rqa','euclidean', 'continuous')
       t_ <- t_ + as.numeric(Sys.time() - start_time)
       cat("  ", j, "\n")
    }
    tspan[i] <- t_ / K # average calculation time
    cat(N[i], ": ", tspan[i], "\n")
    
    if (tspan[i] >= maxT) {
       break
    }
}
print(tspan)

ex = abind(N, tspan, along=2)
     
write.table(ex, file = "time_R.csv", col.names=FALSE, row.names=FALSE)
