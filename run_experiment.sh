!/bin/bash

for size in 15 16
do
   for version in 5 4 3 2 1
   do
      for turn in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
      do
	      echo $size.$version.$turn
         if [ $1 == "adhoc" ]; then
            $JULIA_PATH/julia ./run_sample.jl $version $size $turn >> output.adhoc.$version.$size
         else 
            PLATFORM_DESCRIPTION=Platform.$version.toml $JULIA_PATH/julia --threads=$2 ./run_sample.jl -$version $size $turn >> output.structured.$version.$size   	
         fi
      done
   done
done
