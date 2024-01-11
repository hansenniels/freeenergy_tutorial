#!/bin/bash
#SBATCH -n 8
#SBATCH --time=4:00:00
#SBATCH --job-name=decoupling

export OMP_NUM_THREADS=8

source $HOME/programs/plumed2/sourceme.sh
source $HOME/programs/gromacs-2023.2_plumed2_INSTALL/bin/GMXRC

# Set some environment variables
FREE_ENERGY=$(pwd)
MDP=$FREE_ENERGY/mdp_files

LAMBDA=0

# A new directory will be created for each value of lambda and
# at each step in the workflow for maximum organization.

mkdir Lambda_$LAMBDA
cd Lambda_$LAMBDA

#################################
# ENERGY MINIMIZATION 1: STEEP  #
#################################

mkdir EM
cd EM
gmx grompp -f $MDP/EM/em_steep_$LAMBDA.mdp -c $FREE_ENERGY/../1_eq_npt/npt_eq.gro -r $FREE_ENERGY/../1_eq_npt/npt_eq.gro -p $FREE_ENERGY/../0_topo/topol.top -o min$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 2 
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm min$LAMBDA -plumed $FREE_ENERGY/plumed.dat
cd ../

#####################
# NVT EQUILIBRATION #
#####################

mkdir NVT
cd NVT
gmx grompp -f $MDP/NVT/nvt_$LAMBDA.mdp -c ../EM/min$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -o nvt$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm nvt$LAMBDA -plumed $FREE_ENERGY/plumed.dat
cd ../

#####################
# NPT EQUILIBRATION #
#####################

mkdir NPT
cd NPT
gmx grompp -f $MDP/NPT/npt_$LAMBDA.mdp -c ../NVT/nvt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NVT/nvt$LAMBDA.cpt -o npt$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm npt$LAMBDA -plumed $FREE_ENERGY/plumed.dat
cd ../

#################
# PRODUCTION MD #
#################

mkdir Production_MD
cd Production_MD
gmx grompp -f $MDP/Production_MD/md_$LAMBDA.mdp -c ../NPT/npt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NPT/npt$LAMBDA.cpt -o md$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -s md$LAMBDA -plumed $FREE_ENERGY/plumed.dat > mdrun.out 2>&1
echo "Ending. Job completed for lambda = $LAMBDA"
