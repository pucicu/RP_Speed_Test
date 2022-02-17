# Comparison of calculation speed for recurrence plots/ recurrence quantification analysis for MATLAB, R, Python, and Julia

## General

Measuring the calculation time for creating a recurrence plot (RP)
and calculation of the standard recurrence quantification measures
for the Rössler system with the standard parameters (_a_ = 0.25, _b_ = 0.25, and _c_ = 4)
and a sampling time of _Δt_ = 0.05.
The RPs were calculated using Euclidean norm and a threshold of _ε_ = 1.2.

Only the _z_-component of the Rössler system is used, after removing the first 1,000
points as transients. A simple time delay embedding with _m_ = 3 and _τ_ = 6
is applied.
The RP and RQA calculations are implemented for MATLAB, R,
Julia, and Python using the following packages/ tools

Software | Package/ URL
---------|-------------
MATLAB   | simple _rp.m_ code <https://github.com/pucicu/rp>
R        | _crqa_ v2.0.2 <https://github.com/morenococo/crqa>
Julia    | _DynamicalSystems.jl_ v1.4.0 <https://juliadynamics.github.io/DynamicalSystems.jl/dev/>
Python   | simple RP and RQA implementation (included)
Python   | _pyunicorn_ v0.6.1 <https://pypi.org/project/pyunicorn/>
Python   | _PyRQA_ v8.0.0 <https://pypi.org/project/PyRQA/>

The _CRP Toolbox_ for MATLAB is not used,
because the implementation is interwoven with a graphical user interface and, thus,
the new rendering engine of MATLAB is strongly interfering and slowering
the calculations since its introduction
in 2014 (see <https://tocsy.pik-potsdam.de/CRPtoolbox/>).

## Requirements

Software | Requirements
---------|--------------
MATLAB   | install the code from <https://github.com/pucicu/rp> as a subfolder `rp`
R        | packages `nonlinearTseries`, `crqa`, `abind`, `tictoc`
Julia    | packages `OrdinaryDiffEq`, `DelayEmbeddings`, `DynamicalSystems`, `DelimitedFiles`
Python   | packages `PyRQA`, `pyunicorn`, `numpy`, `scipy`

## Procedure

The recurrence analysis is performed on the time series obtained from the
Rössler system with growing length,
starting with _N_ = 200, increasing in steps to provide equidistant points along the
_x_-axis in a log-log plot. The increase of length will be stopped when the calculation time
exceeds 30 sec. For each selected length, the calculation time is measured
10 times and then averaged.

Not for all implementations all RQA measures are available (e.g., for simple Python code).

## Results

The results presented here are from
calculations performed on a 2.3 GHz Quad-Core Intel Core i7 with 16GB RAM, except
the calculations using the _PyRQA_ package, which were performed on a Nvidia
GPU Tesla K40c with OpenCL 1.2.

![Computation speed for recurrence plots and recurrence quantification measures for the Rössler system.](software_speed.svg "Computation speed")