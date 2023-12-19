#!/bin/bash

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

cwd=$(pwd)

window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.20; i+=0.08) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
  cd w_${window[$i]}
  gmx_mpi grompp -f $cwd/../mdp_files/us_prod.mdp -c us_eq.gro -p $cwd/../0_topo/topol.top -o us_prod.tpr -n $cwd/../index.ndx -maxwarn 1
  qsub job_prod_cluster.sh 
  cd ../ 
}
