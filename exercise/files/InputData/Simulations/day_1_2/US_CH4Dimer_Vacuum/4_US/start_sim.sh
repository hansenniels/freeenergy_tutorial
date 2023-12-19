#!/bin/bash

cwd=$(pwd)
window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.20; i+=0.05) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
    #1) SHORT EQUILIBRATION
    echo "$i, w_${window[$i]}"
    cd w_${window[$i]}
    pwd
    if [ "$i" == 0 ]
    then
        gmx grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/../3_eq_nvt/nvt_eq.gro -r $cwd/../3_eq_nvt/nvt_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 2
    else
        last=`echo "$i-1" | bc -l`
        gmx grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/w_${window[$last]}/us_eq.gro -r $cwd/../3_eq_nvt/nvt_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 2
    fi
    gmx mdrun -deffnm us_eq -plumed plumed.dat
    mv COLVAR_${window[$i]} COLVAR_eq_${window[$i]}
    #2) PRODUCTION
    gmx grompp -f $cwd/../mdp_files/us_prod.mdp -c us_eq.gro -p $cwd/../0_topo/topol.top -o us_prod.tpr -n $cwd/../index.ndx -maxwarn 2
    gmx mdrun -deffnm us_prod -plumed plumed.dat
    cd ../ 
}
