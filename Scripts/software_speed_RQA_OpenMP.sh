#!/bin/bash
# script for RQA calculation using multithreaded C++ implementation

# ----------------------------------------
# CONFIG
# ----------------------------------------
DATAFILE="../Libs/RQA_OpenMP/roessler.dat"
TMPFILE="tmp_data.dat"
RESULTSFILE="../Results/time_RQA_OpenMP.csv"
EXEC="../Libs/RQA_OpenMP/rqa_omp"
ARGS=(-i $TMPFILE -e 1.04 -s)

REPEATS=10

# ----------------------------------------
# Create RESULTSFILE file
# ----------------------------------------
echo > "$RESULTSFILE"

# ----------------------------------------
# Generate the list of N values using awk
# ----------------------------------------
# N = round(10^(log10(200) + k*0.075))  for k = 0 ... until >= 500000
# Implemented below with awk for better floating point support.

generate_N_list() {
    awk '
        BEGIN {
            start = log(200)/log(10);
            stop  = log(1000000)/log(10);
            step = 0.075;

            for (x=start; x<=stop+1e-12; x+=step) {
                N = sprintf("%.0f", 10^x);
                print N;
            }
        }
    '
}

# ----------------------------------------
# Main Loop
# ----------------------------------------
for N in $(generate_N_list); do
    echo "----------------------------------------"
    echo "Processing N=$N"

    # Extract first N lines from the time series
    head -n "$N" "$DATAFILE" > "$TMPFILE"

    # Measure runtime (10x)
    sum=0

    for ((i=1; i<=REPEATS; i++)); do

        start=$(date +%s.%N)
        "$EXEC" "${ARGS[@]}"
        end=$(date +%s.%N)
        t=$(echo "$end - $start" | bc)

        # Sum up times
        sum=$(echo "$sum + $t" | bc -l)
    done

    # Compute mean
    mean=$(echo "$sum / $REPEATS" | bc -l)

    echo "  mean runtime = $mean sec"

    # Append to CSV
    echo "$N,$mean" >> "$RESULTSFILE"
done
rm $TMPFILE

echo "Done. Results written to $RESULTSFILE"
