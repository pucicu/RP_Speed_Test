# Compile instructions

## PyRQA

Just install using `pip install PyRQA`. Make sure to load required modules first
and activate the Python envrionment:

```
module load gcc/13.2.0 python cuda openssl/3.0.12 libffi/3.4.4
source .venv/bin/activate
pip install PyRQA
```


## AccRQA

Change to the AccRQA folder and call

```
module load python gcc/13.2.0 mpfr cuda cmake libffi/3.4.4 openssl/3.0.12
source ../../.venv/bin/activate
pip install .
```



## RQA_HPC

Change to the RQA_HPC folder and then into folder `build` and call

```
module load mpich cmake
cmake ..
make
```

## RQA_OpenMP

Change to the RQA_OpenMP folder and use one of the following options.

1. Using GNU compiler:

```
module load gcc/14.1.0 mpfr
g++ -O3 -fopenmp -o rqa_omp rqa_omp.cpp
```

2. Using LLVM (a bit faster):

```
module load aocc llvm gcc
clang++ -O3 -ffast-math -fopenmp -o rqa_omp rqa_omp.cpp
```

