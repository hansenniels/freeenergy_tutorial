#!/bin/bash

for ((i=0; i<11; i++)){
  sbatch < job_euler_para_$i.sh
}
