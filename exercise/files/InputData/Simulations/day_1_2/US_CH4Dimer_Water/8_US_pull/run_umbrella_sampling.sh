#!/bin/bash

mkdir umbrella
cd umbrella

for (( i=0; i<=8; i++ ))
do
    echo "## RUNNING WINDOW ${i} ##"

    # equilibrate in each window
    gmx grompp -f ../../mdp_files/nvt_window.mdp -c ../window${i}.gro -r ../window${i}.gro -p ../../0_topo/topol.top -n ../../index.ndx -o nvt${i}.tpr -maxwarn 2
    gmx mdrun -v -deffnm nvt${i}

    gmx grompp -f ../../mdp_files/npt_window.mdp -c nvt${i}.gro -r nvt${i}.gro -p ../../0_topo/topol.top -n ../../index.ndx -o npt${i}.tpr -maxwarn 2
    gmx mdrun -v -deffnm npt${i} 

    # generate .mdp file for umbrella sampling from template
    dist=`echo 0.35 + $i*0.10 | bc | sed "s/^\./0\./g"`
    sed "s/XX/${dist}/g" ../../mdp_files/us_pull.tmpl > ../../mdp_files/us_pull${i}.mdp

    # run umbrella sampling 
    gmx grompp -f ../../mdp_files/us_pull${i}.mdp -c ../window${i}.gro -n ../../index.ndx -p ../../0_topo/topol.top -o us${i}.tpr -maxwarn 2
    gmx mdrun -v -deffnm us${i}  
done
