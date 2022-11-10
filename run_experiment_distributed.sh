#!/bin/bash

for size in 18 17 16 
do
   for P in 8
   do
     for turn in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
     do
        echo $size.$turn.structured
        PATH_REPO=$PWD $JULIA_PATH/julia --threads=$1 --machine-file hosts.$P ./run_sample_distributed.jl 0 $size $turn >> output.d.structured.0.$size   
        echo $size.$turn.adhoc
        PATH_REPO=$PWD $JULIA_PATH/julia --threads=$1 --machine-file hosts.$P ./run_sample_distributed.jl 1 $size $turn >> output.d.adhoc.1.$size
     done
   done
done
