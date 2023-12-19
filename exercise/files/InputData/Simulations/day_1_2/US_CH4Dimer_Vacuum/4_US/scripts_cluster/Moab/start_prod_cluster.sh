#!/bin/bash

window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.20; i+=0.05) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
  cd w_${window[$i]}
  msub run_sim_cluster.sh 
  cd ../ 
}
