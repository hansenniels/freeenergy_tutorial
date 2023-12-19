#!/bin/bash

for (( i=0; i<11; i++ )){
  cd Lambda_$i/Production_MD
  #APPEND SIMULATION TIME
  gmx convert-tpr -s md$i.tpr -extend 500 -o md_ext.tpr
  mv md_ext.tpr md$i.tpr
  gmx mdrun -s md$i -plumed ../../plumed.dat -cpi state.cpt > mdrun.out 2>&1
  cd ../../
}
