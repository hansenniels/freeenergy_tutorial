#!/bin/bash
#SBATCH -n 8           # 8 cores
#SBATCH --time=4:00:00 # 4-hour run time
#SBATCH --job-name=umbrella  

# Please adapt the paths to your executables and launch the job via
# sbatch < start_sim_euler.sh

source /cluster/home/hansenni/programs/plumed2/sourceme.sh
source /cluster/home/hansenni/programs/gromacs-2023.2_plumed2_INSTALL/bin/GMXRC.bash

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
