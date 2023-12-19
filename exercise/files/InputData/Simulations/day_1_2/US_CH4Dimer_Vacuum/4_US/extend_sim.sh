#!/bin/bash

window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.20; i+=0.05) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
  cd w_${window[$i]}
  #APPEND SIMULATION TIME
  gmx convert-tpr -s us_prod.tpr -extend 500 -o us_prod_ext.tpr
  mv us_prod_ext.tpr us_prod.tpr
  gmx mdrun -deffnm us_prod -plumed plumed.dat
  cd ../ 
}
