# Compile instructions

## AccRQA

Change to the AccRQA folder and call

```
module load python openmpi/5.0.8 gcc/13.2.0 cuda cmake
source ../../.venv/bin/activate
pip install .
```



## RQA_HPC

Change to the AccRQA folder and call

```
module load openmpi/5.0.8 gcc/14.1.0 mpich cmake
source ../../.venv/bin/activate  
cmake .. -DCMAKE_C_COMPILER=$(which mpicc) -DCMAKE_CXX_COMPILER=$(which mpicxx)
make -j8
```

## RQA_OpenMP

Using GNU compiler:

```
module load gcc/14.1.0 
g++ -O3 -fopenmp -o rqa_omp rqa_omp_n.cpp
```

Using LLVM:

```
module load llvm
clang++ -O3 -ffast-math -fopenmp -o rqa_omp rqa_omp_.cpp
```

