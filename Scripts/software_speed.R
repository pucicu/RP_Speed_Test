# speed test

# import required packages
#install.packages(c("nonlinearTseries", "crqa", "abind", "tictoc"), repos="https://cloud.r-project.org/")

require(stats)
library(tictoc)
library(nonlinearTseries)
library(crqa)
library(abind)

# results file
filename = '../Results/time_R.csv'

# length of time series for RQA calculation test
N = round(10.^seq(log10(200),log10(100000), 0.075))

# calculate RP and RQA for different length
tspan = numeric(length(N)) # result vector computation time
K = 10 # number of runs (for averaging time)
maxT = 600 # stop calculations if maxT is exceeded
dt = 0.05 # sampling time

f = file(filename, open="w")
for (i in 1:length(N)) {
   t_ = 0
   for (j in 1:K) {

       # solve the Roessler ODE        
       r = rossler(start = runif(3, min = 0, max = 1), time=seq(0, dt*(1000+N[i]), by = dt));
       x = r$x

       start_time <- Sys.time()
       R = try(
          crqa(
            x[1000:(1000+N[i]-1)], 
            x[1000:(1000+N[i]-1)], 
            3, 6, 0, 1.2, 0, 2, 2, 0, 
            FALSE, FALSE, 'both', 'rqa', 'euclidean', 'continuous'
          ), 
          silent = TRUE
        )

        if (inherits(R, "try-error")) {
            cat("Error in crqa at i =", i, "j =", j, "- skip calculation\n")
            t_ = NaN
        }
 
        t_ = t_ + as.numeric(Sys.time() - start_time)
       #cat("  ", j, "\n")
    }
    tspan[i] = t_ / K # average calculation time
    cat(N[i], ": ", tspan[i], "\n")
        
    # save results
    writeLines(sprintf("%d, %f, %f, %f", N[i], NaN, NaN, tspan[i]), f)
    flush(f)

    if (is.nan(tspan[i]) || tspan[i] >= maxT) {
       break
    }
}    
close(f)
