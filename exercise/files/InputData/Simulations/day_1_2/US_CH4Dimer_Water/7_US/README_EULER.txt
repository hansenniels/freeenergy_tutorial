(1) to run the umbrella windows sequentially in one single job,
prepare the simulation with 
$ bash prepare_sim.sh 
and launch the script start_sim_euler.sh with
$ sbatch < start_sim_euler.ch

(2) to run each window as a separate job we use two scripts, 
one for equilibration (performed sequentially in a single job)
and one that starts the production runs in separate jobs.
First, prepare the directories for each window by running
$ bash prepare_sim_euler_para.sh
Next, start the equilibration run:
$ sbatch < start_eq_euler_seq.sh 
If the equilibration has finished, start the production runs:
$ bash start_prod_euler_para.sh 
Note that more windows are defined in the scripts prepared 
for the parallel execution compared to those prepared for the 
sequential execution. Therefore, the analysis scripts have to
be adapted.
