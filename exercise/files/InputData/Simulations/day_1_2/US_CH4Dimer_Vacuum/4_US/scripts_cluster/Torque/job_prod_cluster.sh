#PBS -l nodes=1:ppn=7
#PBS -l walltime=20:00:00
#PBS -S /bin/bash
#PBS -N CH4Dim_Water
#PBS -j oe
#PBS -o LOG
#PBS -q short

#LOAD REQUIRED MODULES
module purge
module load compiler/gnu/5.2
module load mpi/openmpi/1.10-gnu-5.2
module load devel/cuda/8.0
module load devel/perl/5.24
module load devel/automake/1.15

source ~/Programs/plumed-2.4.2_mathlib/sourceme.sh
source ~/Programs/gromacs-2016.4_plumed-2.4.2_mathlib_INSTALL/bin/GMXRC
export PLUMED_USE_LEPTON=yes

#CHANGE TO CURRENT DIRECTORY
cd $PBS_O_WORKDIR
cwd=$(pwd)

#PRODUCTION
gmx_mpi grompp -f $cwd/../mdp_files/us_prod.mdp -c us_eq.gro -p $cwd/../0_topo/topol.top -o us_prod.tpr -n $cwd/../index.ndx -maxwarn 1
gmx_mpi mdrun -deffnm us_prod -plumed plumed.dat -pin on -ntomp 7 -cpi us_pr.cpt
