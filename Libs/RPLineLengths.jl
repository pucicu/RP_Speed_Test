using Random
using Base.Threads


"""
    get_hist_diagonal_RP(x, e)

Compute the histogram of diagonal line lengths in a recurrence plot.

# Arguments
- `x::AbstractMatrix`: Input data matrix where rows represent observations and columns represent variables.
- `e::Real`: Recurrence threshold for determining if two state vectors are recurrent.

# Returns
- `L::Vector{Int}`: Histogram where `L[n]` counts the number of diagonal lines of length `n` in the recurrence plot.

# Description
The function:
1. Constructs the recurrence plot `R`, marking pairs of points as recurrent if their Euclidean distance is ≤ `e`.
2. Counts diagonal line segments in lower triangle of `R`, storing their length frequencies in `L`.
"""
function get_hist_diagonal_RP(x, e)
    N, dim = size(x)                  # Number of observations and variables
    L = zeros(Int, N)                 # Histogram for line lengths
    R = falses(N, N)                  # Boolean recurrence plot
    
    # Step 1: Construct recurrence plot
    for i in 1:N
        for j in 1:i
            D2 = 0.0                  # Squared distance accumulator
            for k in 1:dim  # Loop over dimensions
                D2 += (x[i, k] - x[j, k])^2
            end
            R[i, j] = sqrt(D2) <= e   # Mark recurrence if within threshold
        end
    end

    # Step 2: Count diagonal line lengths
    for i in 2:N # start with 2 to remove main diagonal
        cnt = 0
        for j in 1:(N - i + 1)
            if R[i + j - 1, j]
                cnt += 1              # Extend current diagonal
            else
                if cnt > 0
                    L[cnt] += 1       # Store completed line length
                end
                cnt = 0
            end
        end
        if cnt > 0
            L[cnt] += 1
        end
    end

    return L
end


"""
    get_hist_diagonal_woRP_noinbounds(x, e)

Compute the histogram of diagonal line lengths directly from a time series without 
explicitly building the recurrence plot.

# Arguments
- `x::AbstractMatrix`: Input data matrix where rows are observations and columns are variables.
- `e::Real`: Recurrence threshold (maximum allowed Euclidean distance for recurrence).

# Returns
- `L::Vector{Int}`: Histogram where `L[n]` counts the number of diagonal lines of length `n`.

# Description
This version avoids constructing the full recurrence plot matrix, computing line 
lengths directly by comparing shifted segments of the input. It iterates through 
offsets and counts consecutive recurrent points to build the histogram.
"""
function get_hist_diagonal_woRP_noinbounds(x, e)
    N, dim = size(x)                  # Number of observations and variables
    L = zeros(Int, N)                 # Histogram for line lengths
    e2 = e^2                          # Precompute squared threshold (avoids sqrt)

    for i in 2:N # start with 2 to remove main diagonal
        cnt = 0
        for j in 1:(N - i + 1)
            # Direct squared Euclidean distance computation

            # variant 1 (needs to replace test D2 < e2 with D < e)
#             @views diff .= x[i + j - 1, :] .- x[j, :]  # Avoid creating a new array
#             #diff .= x[i + j - 1, :] .- x[j, :]  ## Causes many allocations
#             D = norm(diff)  # Reuse `diff` instead of allocating new memory
            
            # variant 2 (needs to replace test D2 < e2 with D < e)
            # D = norm(x[i + j - 1, :] - x[j, :])
            
            # variant 3
            D2 = 0.0
            for k in 1:dim
                D2 += (x[i + j - 1, k] - x[j, k])^2
            end

            if D2 <= e2
                cnt += 1              # Extend current diagonal
            else
                if cnt > 0
                    L[cnt] += 1       # Store completed line length
                    cnt = 0
                end
            end
        end
        if cnt > 0
            L[cnt] += 1
        end
    end

    return L
end


"""
    get_hist_diagonal_woRP(x, e)

Compute the histogram of diagonal line lengths directly from a time series without 
explicitly building the recurrence plot.

# Arguments
- `x::AbstractMatrix`: Input data matrix where rows are observations and columns are variables.
- `e::Real`: Recurrence threshold (maximum allowed Euclidean distance for recurrence).

# Returns
- `L::Vector{Int}`: Histogram where `L[n]` counts the number of diagonal lines of length `n`.

# Description
This version avoids constructing the full recurrence plot matrix, computing line 
lengths directly by comparing shifted segments of the input. It iterates through 
offsets and counts consecutive recurrent points to build the histogram.
"""
function get_hist_diagonal_woRP(x, e)
    N, dim = size(x)                  # Number of observations and variables
    L = zeros(Int, N)                 # Histogram for line lengths
    e2 = e^2                          # Precompute squared threshold (avoids sqrt)

    @inbounds for i in 2:N # start with 2 to remove main diagonal
        cnt = 0
        @inbounds for j in 1:(N - i + 1)
            # Direct squared Euclidean distance computation

            # variant 1 (needs to replace test D2 < e2 with D < e)
#             @views diff .= x[i + j - 1, :] .- x[j, :]  # Avoid creating a new array
#             #diff .= x[i + j - 1, :] .- x[j, :]  ## Causes many allocations
#             D = norm(diff)  # Reuse `diff` instead of allocating new memory
            
            # variant 2 (needs to replace test D2 < e2 with D < e)
            # D = norm(x[i + j - 1, :] - x[j, :])
            
            # variant 3
            D2 = 0.0
            @inbounds for k in 1:dim
                D2 += (x[i + j - 1, k] - x[j, k])^2
            end

            if D2 <= e2
                cnt += 1              # Extend current diagonal
            else
                if cnt > 0
                    L[cnt] += 1       # Store completed line length
                    cnt = 0
                end
            end
        end
        if cnt > 0
            L[cnt] += 1
        end
    end

    return L
end


"""
    get_hist_diagonal_parallel(x, e)

Compute the histogram of diagonal line lengths in parallel using multiple threads.

# Arguments
- `x::AbstractMatrix`: Input data matrix where rows are observations and columns are variables.
- `e::Real`: Recurrence threshold (maximum Euclidean distance for recurrence).

# Returns
- `L::Vector{Int}`: Histogram where `L[n]` counts the number of diagonal lines of length `n`.

# Description
This function is a parallelized version of `get_hist_diagonal_woRP`.  
It avoids building the full recurrence plot and instead counts diagonal lines directly,  
splitting work across threads. Each thread accumulates results in a local histogram,  
which are summed at the end.

Parallelization reduces computation time for large datasets while avoiding lock contention  
by keeping per-thread histograms.
"""
function get_hist_diagonal_parallel(x, e)
    N, dim = size(x)                  # Number of observations and variables
    L_local = [zeros(Int, N) for _ in 1:nthreads()] # Thread-local histograms
    e2 = e^2                          # Precompute squared threshold (avoids sqrt)

    @threads for i in 2:N 
        tid = threadid()
        cnt = 0

        @simd for j in 1:(N - i + 1)
            D2 = 0.0
            @simd for k in 1:dim
                D2 += (x[i + j - 1, k] - x[j, k])^2
            end

            if D2 <= e2
                cnt += 1              # Extend current diagonal
            else
                if cnt > 0
                    L_local[tid][cnt] += 1  # Store completed line length
                end
                cnt = 0
            end
        end
        if cnt > 0
            L_local[tid][cnt] += 1
        end
    end

    return reduce(+, L_local)         # Merge histograms
end


"""
    get_hist_diagonal_sampled(x, e, M)

Compute an approximate histogram of diagonal line lengths by random sampling,  
reducing computation cost compared to a full scan.

# Arguments
- `x::AbstractMatrix`: Input data matrix where rows are observations and columns are variables.
- `e::Real`: Recurrence threshold (maximum Euclidean distance for recurrence).
- `M::Int`: Number of valid diagonal lines to sample.

# Returns
- `L::Vector{Int}`: Histogram where `L[n]` counts the number of sampled diagonal lines of length `n`.

# Description
This version speeds up diagonal line length computation by:
1. Randomly selecting starting indices `i` instead of checking all.
2. Stopping each search as soon as a line is found (`break`), avoiding unnecessary calculations.
3. Repeating until `M` lines have been successfully found.

The result is an **approximate** histogram that is much faster for large datasets,  
at the cost of reduced completeness compared to full enumeration.
"""
function get_hist_diagonal_sampled(x::AbstractMatrix{T}, e::T, M::Int) where {T<:AbstractFloat}
    N, dim = size(x)                  # Number of observations and variables
    L_local = zeros(Int, N)           # Histogram for line lengths
    e2 = e^2                          # Squared threshold (avoids sqrt)
    count = 0                         # Number of valid lines found
    countAll = 0                      # Number of searches

    while count < M
        countAll += 1                 # Count number of searches
        i_start = rand(2:N)           # Random starting index for i
        j_start = rand(1:i_start-1)   # Random starting index for j

        # Check if R(i_start,j_start) = 1 (start point)
        D2 = zero(T)
        @inbounds for k in 1:dim
            D2 += (x[i_start,k] - x[j_start,k])^2
        end
        if D2 > e2
            continue  # kein Linienstart, nächster Versuch
        end

        # Check if preceeding point R(i_start-1, j_start-1) = 0 (beginning of a line)
        if i_start == 1 || j_start == 1
            # We are at the lower border – no previous points
        else
            D2_prev = 0.0
            @inbounds for k in 1:dim
                D2_prev += (x[i_start-1,k] - x[j_start-1,k])^2
            end
            if D2_prev <= e2
                continue  # no begin of a line, try again
            end
        end

        # Line found, now count line length
        cnt = 0
        @inbounds for offset in 0:(N - i_start)
            D2_line = 0.0
            for k in 1:dim
                D2_line += (x[i_start + offset,k] - x[j_start + offset,k])^2
            end
            if D2_line <= e2          # Count points belonging to diagonal
                cnt += 1              # Extend diagonal
            else
                break                 # Line ends
            end
        end

        # Store line length to histogram variable
        if cnt > 0 #&& !((i_start, j_start) in seen)
            L_local[cnt] += 1         # Store completed line length
            #push!(seen, (i_start, j_start))
            count += 1                # Count found lines (only counted if a line was found)
        end
    end

    return L_local, countAll
end
