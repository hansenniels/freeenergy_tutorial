#PBS -l nodes=1:ppn=7
#PBS -l walltime=20:00:00
#PBS -S /bin/bash
#PBS -N CH4_Dimer_Water
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
window=($(LC_NUMERIC="C" awk 'BEGIN{ for (i=0.35; i < 1.20; i+=0.08) printf("%.2f\n", i); }'))
length=${#window[@]}

for (( i=0; i<$length; i++ )){
    #SHORT EQUILIBRATION
    echo "$i, w_${window[$i]}"
    cd w_${window[$i]}
    pwd
    if [ "$i" == 0 ]
    then
        gmx_mpi grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/../3_eq_nvt/nvt_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 1
    else
        last=`echo "$i-1" | bc -l`
        gmx_mpi grompp -f $cwd/../mdp_files/us_eq.mdp -c $cwd/w_${window[$last]}/us_eq.gro -p $cwd/../0_topo/topol.top -o us_eq.tpr -n $cwd/../index.ndx -maxwarn 1
    fi
    gmx_mpi mdrun -deffnm us_eq -plumed plumed.dat -pin on -ntomp 7
    cd ../ 
}
