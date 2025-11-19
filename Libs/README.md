# Compile instructions

## RQA_HPC

module load openmpi/5.0.8 gcc/14.1.0 mpich cmake
cmake .. -DCMAKE_C_COMPILER=$(which mpicc) -DCMAKE_CXX_COMPILER=$(which mpicxx)
make -j8

