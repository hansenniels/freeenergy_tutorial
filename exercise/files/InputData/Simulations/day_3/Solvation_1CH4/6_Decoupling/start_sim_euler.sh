#!/bin/bash
#SBATCH -n 8
#SBATCH --time=4:00:00
#SBATCH --job-name=decoupling

# launch this script via sbatch < start_sim_euler.sh

export OMP_NUM_THREADS=8

for ((i=0; i<9; i++)){
  bash job_euler_$i.sh
}
