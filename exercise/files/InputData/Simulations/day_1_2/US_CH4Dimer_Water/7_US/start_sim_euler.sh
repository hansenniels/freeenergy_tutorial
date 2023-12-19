#!/bin/bash
#BSUB -n 8         # 8 cores
#BSUB -W 4:00      # 4-hour run time
#BSUB -J umbrella  

# Please adapt the paths to your executables and launch the job via
# bsub < start_sim_euler.sh

source /cluster/home/hansenni/Programs/plumed-2.7.1/sourceme.sh
source /cluster/home/hansenni/Programs/gromacs-2021.2_plumed-2.7.1_INSTALL/bin/GMXRC.bash

export OMP_NUM_THREADS=8

cwd=$(pwd)
window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.15; i+=0.10) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
    #1) SHORT EQUILIBRATION
    echo "$i, w_${window[$i]}"
    cd w_${window[$i]}
    pwd
    if [ "$i" == 0 ]
    then
        gmx grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/../6_eq_npt/npt_eq.gro -r $cwd/../6_eq_npt/npt_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 2
    else
        last=`echo "$i-1" | bc -l`
        gmx grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/w_${window[$last]}/us_eq.gro -r $cwd/../6_eq_npt/npt_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 2
    fi
    gmx mdrun -ntmpi 1 -ntomp 8 -deffnm us_eq -plumed plumed.dat
    mv COLVAR_${window[$i]} COLVAR_eq_${window[$i]}
    #2) PRODUCTION
    gmx grompp -f $cwd/../mdp_files/us_prod.mdp -c us_eq.gro -p $cwd/../0_topo/topol.top -o us_prod.tpr -n $cwd/../index.ndx -maxwarn 2
    gmx mdrun -ntmpi 1 -ntomp 8 -deffnm us_prod -plumed plumed.dat
    cd ../ 
}
