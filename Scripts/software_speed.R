# speed test

# import required packages
#install.packages(c("crqa", "tictoc"), repos="https://cloud.r-project.org/")

library(tictoc)
library(crqa)

# results files
timeResultsfile = '../Results/time_R.csv'
rqaResultsfile = '../Results/rqa_R.csv'

# data file
datafile = '../Libs/roessler.csv'

# import data
x = as.matrix(read.table(datafile))

# length of time series for RQA calculation test
N = round(10.^seq(log10(200),log10(100000), 0.075))

# calculate RP and RQA for different length
tspan = numeric(length(N))  # result vector computation time
mRQA = matrix(0, nrow = length(N), ncol = 6) # result vector RQA average
vRQA = matrix(0, nrow = length(N), ncol = 6) # result vector RQA variance
K = 10                      # number of runs (for averaging time)
maxT = 600                  # stop calculations if maxT is exceeded
m = 3;                      # embedding dimension
tau = 6;                    # embedding delay
e = 1.2;                    # recurrence threshold
lmin = 2;                   # minimal line length

f_time = file(timeResultsfile, open="w")
f_rqa = file(rqaResultsfile, open="w")
for (i in 1:length(N)) {
   t_ = 0
   RQA_ = matrix(0, nrow = K, ncol = 6)

   for (j in 1:K) {

        start_time = proc.time()[3]

        R = try(
          crqa(
            x[1:N[i]],
            x[1:N[i]],
            tau, m, 0, e, 0, lmin, lmin, 1,
            FALSE, FALSE, "both", "rqa", "euclidean", "continuous"
          ),
          silent = TRUE
        )

        if (inherits(R, "try-error")) {

          cat("Error in crqa at i =", i, "j =", j, "- skip calculation\n")
          t_ = NaN

        } else {

          rr  = R[[1]]
          det = R[[2]]
          l   = R[[5]]
          ent = R[[6]]
          lam = R[[8]]
          tt  = R[[9]]

          end_time = proc.time()[3]
          duration = end_time - start_time

          t_ = t_ + duration
          RQA_[j, ] = c(rr, det, l, ent, lam, tt)
        }

       #cat("  ", j, "\n")
    }
    tspan[i] = t_ / K # average calculation time
    mRQA[i, ] = colMeans(RQA_)
    vRQA[i, ] = apply(RQA_, 2, var)
    cat(N[i], ": ", tspan[i], "\n")
        
    # save results
    writeLines(sprintf("%d, %f", N[i], NaN, NaN, tspan[i]), f_time)
    line <- paste(
      paste(mRQA[i, ], collapse = ", "),
      paste(vRQA[i, ], collapse = ", "),
      sep = ", "
    )
    writeLines(line, f_rqa)

    if (tspan[i] >= maxT) {
       break
    }
}    
