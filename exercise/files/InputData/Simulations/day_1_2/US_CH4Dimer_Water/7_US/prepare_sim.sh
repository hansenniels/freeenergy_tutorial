#!/bin/bash

function gen_plumedfile {
     #initialize local variable
     local file="plumed.dat"
     echo "#PLUMED INPUT FOR UMBRELLA SAMPLING" >> $file
     echo "#Definition of Groups" >> $file
     echo "CH41: GROUP ATOMS=1" >> $file
     echo "CH42: GROUP ATOMS=2" >> $file
     echo "#Definition of Collective Variables" >> $file
     echo "Dist_CH41_CH42: DISTANCE ATOMS=CH41,CH42" >> $file
     echo "Dist_CH41_CH42_comp: DISTANCE ATOMS=CH41,CH42 COMPONENTS" >> $file
     echo "#Definition of Restraints" >> $file
     echo "#Force Constant KAPPA, Equilibrium Value AT" >> $file
     echo "disrest: RESTRAINT ARG=Dist_CH41_CH42 KAPPA=500.0 AT=$1" >> $file
     echo "#Write to File" >> $file
     echo "PRINT ARG=Dist_CH41_CH42,Dist_CH41_CH42_comp.x,Dist_CH41_CH42_comp.y,Dist_CH41_CH42_comp.z,disrest.bias STRIDE=250 FILE=COLVAR_$1" >> $file
     echo "ENDPLUMED" >> $file
}

window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.15; i+=0.10) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
  mkdir w_${window[$i]}
  cd w_${window[$i]}
  gen_plumedfile ${window[$i]}
  cd ../ 
}
