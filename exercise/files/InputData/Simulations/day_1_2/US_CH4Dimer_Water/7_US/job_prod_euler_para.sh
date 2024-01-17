#!/bin/bash
#SBATCH -n 8
#SBATCH --time=4:00:00
#SBATCH --job-name=umbrella

export OMP_NUM_THREADS=8

source $HOME/programs/plumed2/sourceme.sh
source $HOME/programs/gromacs-2023.2_plumed2_INSTALL/bin/GMXRC

cwd=$(pwd)

#PRODUCTION
gmx grompp -f $cwd/../../mdp_files/us_prod.mdp -c us_eq.gro -p $cwd/../../0_topo/topol.top -o us_prod.tpr -n $cwd/../../index.ndx -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm us_prod -plumed plumed.dat -cpi us_pr.cpt
