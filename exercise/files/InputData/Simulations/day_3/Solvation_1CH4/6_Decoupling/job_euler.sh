#!/bin/bash

source $HOME/Programs/plumed-2.7.1/sourceme.sh
source $HOME/Programs/gromacs-2021.2_plumed-2.7.1_INSTALL/bin/GMXRC

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
gmx grompp -f $MDP/EM/em_steep_$LAMBDA.mdp -c $FREE_ENERGY/../5_eq_npt/npt_eq.gro -r $FREE_ENERGY/../5_eq_npt/npt_eq.gro -p $FREE_ENERGY/../0_topo/topol.top -o min$LAMBDA.tpr -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm min$LAMBDA
cd ../

#####################
# NVT EQUILIBRATION #
#####################

mkdir NVT
cd NVT
gmx grompp -f $MDP/NVT/nvt_$LAMBDA.mdp -c ../EM/min$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -o nvt$LAMBDA.tpr -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm nvt$LAMBDA
cd ../

#####################
# NPT EQUILIBRATION #
#####################

mkdir NPT
cd NPT
gmx grompp -f $MDP/NPT/npt_$LAMBDA.mdp -c ../NVT/nvt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NVT/nvt$LAMBDA.cpt -o npt$LAMBDA.tpr -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -deffnm npt$LAMBDA
cd ../

#################
# PRODUCTION MD #
#################

mkdir Production_MD
cd Production_MD
gmx grompp -f $MDP/Production_MD/md_$LAMBDA.mdp -c ../NPT/npt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NPT/npt$LAMBDA.cpt -o md$LAMBDA.tpr -maxwarn 2
gmx mdrun -ntmpi 1 -ntomp 8 -s md$LAMBDA > mdrun.out 2>&1
echo "Ending. Job completed for lambda = $LAMBDA"
