#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=07:00:00
#MSUB -N MET_US_VAC

#LOAD REQUIRED MODULES
module purge
module load mpi/openmpi/2.0-intel-16.0
source ~/Programs/plumed2-master/sourceme.sh
source ~/Programs/gromacs-5.1.4_INSTALL/bin/GMXRC 

#PRODUCTION
gmx_mpi grompp -f ../../us_prod.mdp -c us_eq.gro -p ../../0_topo/topol.top -o us_prod.tpr -n ../../index.ndx -maxwarn 1
mpirun -np 4 gmx_mpi mdrun -deffnm us_prod -plumed plumed.dat
