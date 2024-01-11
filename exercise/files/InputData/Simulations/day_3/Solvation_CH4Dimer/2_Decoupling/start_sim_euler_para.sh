#!/bin/bash

for ((i=0; i<9; i++)){
  sbatch < job_euler_para_$i.sh
}
