#MSUB -l nodes=1:ppn=4
#MSUB -l walltime=07:00:00
#MSUB -N MET_US_VAC

#LOAD REQUIRED MODULES
module purge
module load mpi/openmpi/2.0-intel-16.0
source ~/Programs/plumed2-master/sourceme.sh
source ~/Programs/gromacs-5.1.4_INSTALL/bin/GMXRC 

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
    mpirun -np 4 gmx_mpi mdrun -deffnm us_eq -plumed plumed.dat
    cd ../ 
}
