# Comparison of calculation speed for recurrence plots/ recurrence quantification analysis for MATLAB, R, Python, and Julia

[![SWH](https://archive.softwareheritage.org/badge/origin/https://github.com/pucicu/RP_Speed_Test/)](https://archive.softwareheritage.org/browse/origin/?origin_url=https://github.com/pucicu/RP_Speed_Test)
![file size](https://img.shields.io/github/repo-size/pucicu/RP_Speed_Test)
![GitHub Release](https://img.shields.io/github/v/release/pucicu/RP_Speed_Test)


## General

Measuring the calculation time for creating a recurrence plot (RP)
and calculation of the standard recurrence quantification measures
for the Rössler system with the standard parameters (_a_ = 0.25, _b_ = 0.25, and _c_ = 4)
and a sampling time of _Δt_ = 0.05.
The RPs were calculated using Euclidean norm and a threshold of _ε_ = 1.2.
Selected RQA measures are calculated and compared for the used tools.

Only the _x_-component of the Rössler system is used, after removing the first 1,000
points as transients. A simple time delay embedding with _m_ = 3 and _τ_ = 6
is applied.
The RP and RQA calculations are implemented for MATLAB, R,
Julia, Python, and a C++-based tool using the following packages/ tools

Software | Package/ URL
---------|-------------
MATLAB   | simple _rp.m_ v1.2 code <https://github.com/pucicu/rp>
MATLAB   | _CRP Toolbox_ v5.26(R36) code <https://tocsy.pik-potsdam.de/CRPtoolbox>
R        | _crqa_ v2.0.2 <https://github.com/morenococo/crqa>
Julia    | _DynamicalSystems.jl_ v1.4.0 <https://juliadynamics.github.io/DynamicalSystems.jl/dev/>
Julia    | _RecurrenceMicrostatesAnalysis.jl_ 0.2.24 <https://github.com/DynamicsUFPR/RecurrenceMicrostatesAnalysis.jl>
Julia    | _RQA_Samp_ <https://github.com/pucicu/RQA_Samp>
Python   | simple RP and RQA implementation (included)
Python   | _pyunicorn_ v0.6.1 <https://pypi.org/project/pyunicorn/>
Python   | _PyRQA_ v8.0.0 <https://pypi.org/project/PyRQA/>
Python   | _AccRQA_ v0.9.1 <https://pypi.org/project/accrqa/>
C++      | _RQA_OpenMP_ v1.414 <https://github.com/pucicu/RQA_OpenMP>

## Requirements

Software | Requirements
---------|--------------
MATLAB   | install the code from <https://github.com/pucicu/rp> as a subfolder `rp`
MATLAB   | install the code from <https://tocsy.pik-potsdam.de/CRPtoolbox> by calling the installer file `install` from the MATLAB commandline
R        | packages `nonlinearTseries`, `crqa`, `abind`, `tictoc`
Julia    | packages `OrdinaryDiffEq`, `DelayEmbeddings`, `DynamicalSystems`, `DelimitedFiles`, `RecurrenceMicrostatesAnalysis`, and `RQA_Samp`
Python   | packages `PyRQA`, `pyunicorn`, `accrqa`, `numpy`, `scipy`
OpenMP   | download the code from <https://github.com/pucicu/RQA_OpenMP> to a subfolder `Libs` and compile it as specified in the `README.md`

For Python, see file `requirements.txt` (you can use `pip install -r requirements.txt` to get the required Python packages).

## Procedure

The recurrence analysis is performed on the time series obtained from the Rössler system with growing length, starting with _N_ = 200 (ending at max. _N_ = 500,000), increasing in steps to provide equidistant points along the _x_-axis in a log-log plot. The increase of length will be stopped when the calculation time exceeds 600 sec. For each selected length, the calculation time is measured 10 times and then averaged.

Not all RQA measures are available across all implementations (e.g., in simple Python code or in RQA_Samp). Network measure calculations were disabled in all examples.

The calculation time is measured for:
- Recurrence Plot (RP) computation (where applicable), and
- Recurrence Quantification Analysis (RQA).

__Note:__ If RQA calculations require a precomputed RP, the RQA time includes the RP calculation time.

For calculations using the different implementations, individual scripts are available. These scripts can be executed in batch via the shell script `run_software_test.sh`.

For high-performance computing (HPC), SLURM scripts are provided. To enable HPC submission, set the flag `SUBMIT_HPC=1` in the script `run_software_test.sh`.

## Results

The results presented here were primarily computed on a single node of the "Foote" high-performance cluster at PIK. Each node is equipped with:

- 1 × AMD EPYC 9554 Genoa processor (64 cores @ 3.1 GHz), 
- 768 GB RAM.

For GPU-based calculations (using the AccRQA and PyRQA packages), we utilised:

- NVIDIA H100 HBM3 (80 GB, OpenCL 3.0, CUDA).

MPI-based calculations for AccRQA were executed across 128 compute nodes.

Recurrence plots (RPs) cannot be calculated using _RQA_OpenMP_, _RQA_Samp_, and _RecurrenceMicrostates_. Therefore, RP calculation times are not available for these implementations.

![Computation speed for recurrence plots and recurrence quantification measures for the Rössler system.](https://raw.githubusercontent.com/pucicu/RP_Speed_Test/master/rp_rqa_speed-test.svg "Computation speed")

![Relative deviations in selected RQA measures for the Rössler system.](https://raw.githubusercontent.com/pucicu/RP_Speed_Test/refs/heads/master/rp_rqa_value-test.svg "RQA relative deviations")

## Copyright

Norbert Marwan\
Potsdam Institute for Climate Impact Research\
3/2026

License: GPLv3+
