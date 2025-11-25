#!/bin/bash
# script for RQA calculation using multithreaded C++ implementation

# ----------------------------------------
# CONFIG
# ----------------------------------------
DATAFILE="../Libs/roessler.csv"
TMPFILE="tmp_data_hpc.dat"
TMPRESULTSFILE="tmp_results_hpc.dat"
TIMERESULTSFILE="../Results/time_RQA_HPC.csv"
RQARESULTSFILE="../Results/rqa_RQA_HPC.csv"
EXEC="../Libs/RQA_HPC/build/RQA_MPI"
DIM=3
TAU=6
LMIN=2
E=1.2
ARGS=($DIM $TAU $LMIN 1 $E 0 0 $TMPFILE)

REPEATS=2

# Functions for mean and varianz
mean() {
    local arr=("$@")
    local sum=0
    for v in "${arr[@]}"; do sum=$(echo "$sum + $v" | bc -l); done
    echo "$(echo "$sum / ${#arr[@]}" | bc -l)"
}

variance() {
    local arr=("$@")
    local m=$(mean "${arr[@]}")
    local sumsq=0
    for v in "${arr[@]}"; do
        sumsq=$(echo "$sumsq + ($v - $m)^2" | bc -l)
    done
    echo "$(echo "$sumsq / ${#arr[@]}" | bc -l)"
}


# ----------------------------------------
# Create RESULTSFILE files
# ----------------------------------------
echo > "$TIMERESULTSFILE"
echo > "$RQARESULTSFILE"

# ----------------------------------------
# Generate the list of N values using awk
# ----------------------------------------
# N = round(10^(log10(200) + k*0.075))  for k = 0 ... until >= 500000
# Implemented below with awk for better floating point support.

generate_N_list() {
    awk '
        BEGIN {
            start = log(200)/log(10);
            stop  = log(500000)/log(10);
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
    head -n "$N" "$DATAFILE" | awk '{print $1}' > "$TMPFILE"

    # Measure runtime (10x)
    sum=0
    
    # Arrays for RQA measures
    RR=()
    DET=()
    L=()
    DE=()
    LAM=()
    TT=()

    for ((i=1; i<=REPEATS; i++)); do

        start=$(date +%s.%N)
        srun -n "$SLURM_NTASKS" "$EXEC" "${ARGS[@]}" > $TMPRESULTSFILE
        end=$(date +%s.%N)
        t=$(echo "$end - $start" | bc)
        echo $t

        # Sum up times
        sum=$(echo "$sum + $t" | bc -l)
        
        # sum RQA values
        vals=($(grep -E "Recurrence rate|Determinism|Average diagonal line length|Diagonal lines entropy|Laminarity|Average vertical line length" "$TMPRESULTSFILE" \
            | awk '{print $NF}'))

        RR+=("${vals[0]}")
        DET+=("${vals[1]}")
        L+=("${vals[2]}")
        DE+=("${vals[3]}")
        LAM+=("${vals[4]}")
        TT+=("${vals[5]}")        
    done

    # Compute mean
    mean=$(echo "$sum / $REPEATS" | bc -l)

    echo "  mean runtime = $mean sec"

    # Append to CSV
    echo "$N,NaN,NaN,$mean" >> "$TIMERESULTSFILE"
    
    # RQA mean and variance
    out=()
    for arr in RR DET L DE LAM TT; do
        eval "values=(\"\${$arr[@]}\")"
        m=$(mean "${values[@]}")
        v=$(variance "${values[@]}")
        out+=("$m,$v")
    done

    # Append to CSV
    echo "$N, ${out[*]}" | tr ' ' ',' >> "$RQARESULTSFILE"
   
done
rm $TMPFILE

echo "Done. Results written to $RESULTSFILE"
