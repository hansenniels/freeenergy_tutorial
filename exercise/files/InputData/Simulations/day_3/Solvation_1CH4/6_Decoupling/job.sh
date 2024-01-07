#!/bin/bash
source $HOME/VL_ETH_24/programs/plumed2/sourceme.sh
source $HOME/VL_ETH_24/programs/gromacs-2023.2_plumed2_INSTALL/bin/GMXRC

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
gmx grompp -f $MDP/EM/em_steep_$LAMBDA.mdp -c $FREE_ENERGY/../5_eq_npt/npt_eq.gro -r $FREE_ENERGY/../5_eq_npt/npt_eq.gro -p $FREE_ENERGY/../0_topo/topol.top -o min$LAMBDA.tpr -maxwarn 4
gmx mdrun -deffnm min$LAMBDA
cd ../

#####################
# NVT EQUILIBRATION #
#####################

mkdir NVT
cd NVT
gmx grompp -f $MDP/NVT/nvt_$LAMBDA.mdp -c ../EM/min$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -o nvt$LAMBDA.tpr -maxwarn 4
gmx mdrun -deffnm nvt$LAMBDA
cd ../

#####################
# NPT EQUILIBRATION #
#####################

mkdir NPT
cd NPT
gmx grompp -f $MDP/NPT/npt_$LAMBDA.mdp -c ../NVT/nvt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NVT/nvt$LAMBDA.cpt -o npt$LAMBDA.tpr -maxwarn 4
gmx mdrun -deffnm npt$LAMBDA
cd ../

#################
# PRODUCTION MD #
#################

mkdir Production_MD
cd Production_MD
gmx grompp -f $MDP/Production_MD/md_$LAMBDA.mdp -c ../NPT/npt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NPT/npt$LAMBDA.cpt -o md$LAMBDA.tpr -maxwarn 4
gmx mdrun -s md$LAMBDA > mdrun.out 2>&1
echo "Ending. Job completed for lambda = $LAMBDA"
