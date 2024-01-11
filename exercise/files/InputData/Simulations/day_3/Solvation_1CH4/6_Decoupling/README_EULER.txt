(1) to run the decoupling steps sequentially in one single job, 
generate the job files with:
$ perl write_sh.pl job_euler.sh
and launch the script 'start_sim_euler.sh' with:
$ sbatch < start_sim_euler.sh

(2) to run each lambda-point in one separate job,
generate the job files with:
$ perl write_sh.pl job_euler_para.sh
and launch the script 'start_sim_euler_para.sh' with:
$ bash start_sim_euler_para.sh'


