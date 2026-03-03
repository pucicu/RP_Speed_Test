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
tspanRQA = numeric(length(N))  # result vector computation time
tspanRP = numeric(length(N))  # result vector computation time
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

# dry run
R = try(
  crqa(
    x[1:N[10]],
    x[1:N[10]],
    tau, m, 0, e, 0, lmin, lmin, 1,
    FALSE, FALSE, "both", "rqa", "euclidean", "continuous"
  ),
  silent = TRUE
)


for (i in 1:length(N)) {
   tRP_ = 0
   tRQA_ = 0
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
          tRP_ = NaN

        } else {

          X  = R$RP

          end_time = proc.time()[3]
          duration = end_time - start_time

          tRP_ = tRP_ + duration
        }
 
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
          tRQA_ = NaN

        } else {

          rr  = R[[1]]
          det = R[[2]]
          l   = R[[5]]
          ent = R[[6]]
          lam = R[[8]]
          tt  = R[[9]]

          end_time = proc.time()[3]
          duration = end_time - start_time

          tRQA_ = tRQA_ + duration
          RQA_[j, ] = c(rr, det, l, ent, lam, tt)
        }

       #cat("  ", j, "\n")
    }
    tspanRP[i] = tRP_ / K # average calculation time
    tspanRQA[i] = tRQA_ / K # average calculation time
    mRQA[i, ] = colMeans(RQA_/100) # RQA values are given in %
    vRQA[i, ] = apply(RQA_/100, 2, var)
    cat(N[i], ": ", tspanRQA[i], "\n")
        
    # save results
    writeLines(sprintf("%d, %f, %f", N[i], tspanRP[i], tspanRQA[i]), f_time)
    line <- paste(
      N[i],
      paste(mRQA[i, ], collapse = ", "),
      paste(vRQA[i, ], collapse = ", "),
      sep = ", "
    )
    writeLines(line, f_rqa)

    if (tspanRQA[i] >= maxT) {
       break
    }
}    

close(f_time)
close(f_rqa)
