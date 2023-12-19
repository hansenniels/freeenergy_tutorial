#PBS -l nodes=1:ppn=7
#PBS -l walltime=02:00:00
#PBS -S /bin/bash
#PBS -N SolvDimer
#PBS -j oe
#PBS -o LOG
#PBS -q short

module purge
module load compiler/gnu/5.2
module load mpi/openmpi/1.10-gnu-5.2
module load devel/cuda/8.0
module load devel/perl/5.24
module load devel/automake/1.15

source ~/Programs/plumed-2.4.2_mathlib/sourceme.sh
source ~/Programs/gromacs-2016.4_plumed-2.4.2_mathlib_INSTALL/bin/GMXRC
export PLUMED_USE_LEPTON=yes

cd $PBS_O_WORKDIR

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
gmx_mpi grompp -f $MDP/EM/em_steep_$LAMBDA.mdp -c $FREE_ENERGY/../1_eq_npt/npt_eq.gro -p $FREE_ENERGY/../0_topo/topol.top -o min$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 1 
gmx_mpi mdrun -deffnm min$LAMBDA -plumed $FREE_ENERGY/plumed.dat -ntomp 7 -pin on
cd ../

#####################
# NVT EQUILIBRATION #
#####################

mkdir NVT
cd NVT
gmx_mpi grompp -f $MDP/NVT/nvt_$LAMBDA.mdp -c ../EM/min$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -o nvt$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 1
gmx_mpi mdrun -deffnm nvt$LAMBDA -plumed $FREE_ENERGY/plumed.dat -ntomp 7 -pin on
cd ../

#####################
# NPT EQUILIBRATION #
#####################

mkdir NPT
cd NPT
gmx_mpi grompp -f $MDP/NPT/npt_$LAMBDA.mdp -c ../NVT/nvt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NVT/nvt$LAMBDA.cpt -o npt$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 1
gmx_mpi mdrun -deffnm npt$LAMBDA -plumed $FREE_ENERGY/plumed.dat -ntomp 7 -pin on
cd ../

#################
# PRODUCTION MD #
#################

mkdir Production_MD
cd Production_MD
gmx_mpi grompp -f $MDP/Production_MD/md_$LAMBDA.mdp -c ../NPT/npt$LAMBDA.gro -p $FREE_ENERGY/../0_topo/topol.top -t ../NPT/npt$LAMBDA.cpt -o md$LAMBDA.tpr -n $FREE_ENERGY/../index.ndx -maxwarn 1
gmx_mpi mdrun -s md$LAMBDA -plumed $FREE_ENERGY/plumed.dat -ntomp 7 -pin on > mdrun.out 2>&1
echo "Ending. Job completed for lambda = $LAMBDA"
