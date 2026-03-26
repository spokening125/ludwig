##############################################################################
#
#  unix-mpicc-default.mk
#
#  Compile for parallel execution assuming an mpi compiler
#  wrapper "mpicc" is available.
#
##############################################################################

BUILD   = parallel
MODEL   = -D_D3Q19_
TARGET  =

CC      = mpicc -fopenmp
CFLAGS  = -O2 -g -DNDEBUG