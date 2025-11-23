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

Only the _x_-component of the Rössler system is used, after removing the first 1,000
points as transients. A simple time delay embedding with _m_ = 3 and _τ_ = 6
is applied.
The RP and RQA calculations are implemented for MATLAB, R,
Julia, and Python using the following packages/ tools

Software | Package/ URL
---------|-------------
MATLAB   | simyple _rp.m_ v1.2 code <https://github.com/pucicu/rp>
R        | _crqa_ v2.0.2 <https://github.com/morenococo/crqa>
Julia    | _DynamicalSystems.jl_ v1.4.0 <https://juliadynamics.github.io/DynamicalSystems.jl/dev/>
Julia    | _RecurrenceMicrostatesAnalysis.jl_ 0.2.24 <https://github.com/DynamicsUFPR/RecurrenceMicrostatesAnalysis.jl>
Julia    | _RQA_Samp_ <https://doi.org/10.5281/zenodo.17620044> (required file `RPLineLengths.jl` included)
Python   | simple RP and RQA implementation (required file `rp.py` included)
Python   | _pyunicorn_ v0.8.2 <https://pypi.org/project/pyunicorn/>
Python   | _PyRQA_ v8.1.0 <https://pypi.org/project/PyRQA/>
Python   | _AccRQA_ v0.9.1 <https://pypi.org/project/accrqa/>

The _CRP Toolbox_ for MATLAB is not used,
because the implementation is interwoven with a graphical user interface and, thus,
the new rendering engine of MATLAB is strongly interfering and slowering
the calculations since its introduction
in 2014 (see <https://tocsy.pik-potsdam.de/CRPtoolbox/>).

## Requirements

Software | Requirements
---------|--------------
MATLAB   | install the code from <https://github.com/pucicu/rp> as a subfolder `rp` in `Libs`
R        | packages `nonlinearTseries`, `crqa`, `abind`, `tictoc`
Julia    | packages `OrdinaryDiffEq`, `DelayEmbeddings`, `DynamicalSystems`, `DelimitedFiles`, `RecurrenceMicrostatesAnalysis`; and file `RPLineLengths.jl` placed in `Libs`
Python   | packages `PyRQA`, `pyunicorn`, `accrqa`, `numpy`, `scipy`
C/C++    | repos `AccRQA`, `RQA_HPC`, `RQA_OpenMP` should be cloned into `Libs` (build instructions in `Libs/README.md`)

For Python, see file `requirements.txt` (you can use `pip install -r requirements.txt` to get the required Python packages). The external 

## Procedure

The recurrence analysis is performed on the time series obtained from the Rössler system with growing length, starting with _N_ = 200 (ending at max. _N_ = 500,000 or _N_ = 1,000,000), increasing in steps to provide equidistant points along the _x_-axis in a log-log plot. The increase of length will be stopped when the calculation time exceeds 600 sec. For each selected length, the calculation time is measured 10 times and then averaged.

Not for all implementations all RQA measures are available (e.g., for simple Python code). The calculation of network measures were disabled in all examples.

The scripts can be called by the shell script `run_software_test.sh`. For submitting as jobs to a HPC, slurm scripts are provided and can be used by setting the variable `SUBMIT_HPC=1` in this script.

The openMP based multithreaded implementations used 128 threads at the HPC "Foote".

## Results

The results presented here are from calculations performed on the "Foote" high performance cluster at PIK. A compute node consists of one AMD EPYC 9554 32-Core Processor with 128 CPUs, 3.75 GHz, and with 754GB RAM max per node. The GPU calculations using the _AccRQA_ and _PyRQA_ package were performed on a Nvidia H100 HBM3 with 80GB and OpenCL 3.0 CUDA. For _crqa_ (R), _AccRQA_, _RQA_OpenMP_, _RQA_Samp_, _RecurrenceMicrostates_, and _PyRQA_ the calculation cannot be separated into RP and RQA calculations, therefore, they appear only in the figure on the total computation time.

_Note:_ Not all implementations completed successfully; some terminated prematurely due to excessive RAM usage before reaching the target data length.

![Computation speed for recurrence plots and recurrence quantification measures for the Rössler system.](https://raw.githubusercontent.com/pucicu/RP_Speed_Test/master/rp_rqa_speed-test.svg "Computation speed")
