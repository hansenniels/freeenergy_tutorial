#! /usr/bin/python
"""
Application of MBAR to compute a PMF from an umbrella sampling
"""

# based in parts on the python script from
# https://github.com/choderalab/pymbar/blob/master/examples/umbrella-sampling-fes/umbrella-sampling.py

print(__doc__)


import numpy as np
import pymbar # multistate Bennett acceptance ratio
from pymbar import timeseries # timeseries analysis

# Constants
# assume a single T -> we don't have to read in energies
RT = 8.31446e-3*300 # Thermal energy in kJ/mol
beta = 1.0/(RT)

forceconst_DR = 500
rc0_k = np.arange(0.35,1.2,0.05)
K = len(rc0_k)

# Parameters
N_max = 1000 # maximum number of snapshots/simulation

rc_min = rc0_k[0] # min for PMF
rc_max = rc0_k[-1] # max for PMF
#nbins = len(rc0_k)+1 # number of bins for 1D PMF
nbins = 25
bin_edges = np.linspace(rc_min, rc_max, nbins + 1)

# Allocate storage for simulation data
N_k = np.zeros([K], np.int32) # N_k[k] is the number of snapshots from umbrella simulation k
K_k = np.ones(K,float)*forceconst_DR # K_k[k] is the spring constant for umbrella simulation k
rc_kn = np.zeros([K,N_max], np.float64) # rc_kn[k,n] is the actual reaction coordinate for snapshot n from umbrella simulation k
u_kn = np.zeros([K,N_max], np.float64) # u_kn[k,n] is the reduced potential energy without umbrella restraints of snapshot n of umbrella simulation k
g_k = np.zeros([K],np.float32);

# Read the simulation data
for k in range(K):
    window = str('{:.2f}'.format( rc0_k[k] ))
    print(window)
    colvar = np.genfromtxt("../../w_"+window+"/COLVAR_"+window, comments='#', usecols=1, max_rows=N_max)
    rc_kn[k,:] = colvar
    N_k[k] = len(colvar)

    #Compute correlation times
    g_k[k] = timeseries.statistical_inefficiency( rc_kn[k,0:N_k[k]] )
    indices = timeseries.subsample_correlated_data( rc_kn[k,0:N_k[k]], g=g_k[k] )

    # Subsample data.
    N_k[k] = len(indices)
    u_kn[k,0:N_k[k]] = u_kn[k,indices]
    rc_kn[k,0:N_k[k]] = rc_kn[k,indices]

N_max = np.max(N_k) # shorten the array size
u_kln = np.zeros([K,K,N_max], np.float64) # u_kln[k,l,n] is the reduced potential energy of snapshot n from umbrella simulation k evaluated at umbrella l

# Set zero of u_kn -- this is arbitrary.
u_kn -= u_kn.min()

# Construct bins
print("Binning data...")
delta = (rc_max - rc_min) / float(nbins)

# compute bin centers
bin_center_i = np.zeros([nbins], np.float64)
for i in range(nbins):
    bin_center_i[i] = rc_min + delta/2 + delta * i

N = np.sum(N_k)
rc_n = pymbar.utils.kn_to_n(rc_kn, N_k=N_k)

# Bin data
bin_kn = np.zeros([K,N_max], np.int32)
for k in range(K):
    for n in range(N_k[k]):
        # Compute bin assignment.
        bin_kn[k,n] = int((rc_kn[k,n] - rc_min) / delta)

# Evaluate reduced energies in all umbrellas
print("Evaluating reduced potential energies...")
for k in range(K):
    for n in range(N_k[k]):
        # Compute deviation from umbrella center l
        drc = rc_kn[k,n] - rc0_k

        # Compute energy of snapshot n from simulation k in umbrella potential l
        #u_kln[k,:,n] = u_kn[k,n] + beta_k[k] * (K_k/2.0) * drc**2
        u_kln[k,:,n] = u_kn[k,n] + beta * (K_k/2.0) * drc**2

# initialize free energy profile with data collected
fes = pymbar.FES(u_kln, N_k, verbose=True)

# Compute free energy profile in unbiased potential (in units of kT)
histogram_parameters = {}
histogram_parameters["bin_edges"] = bin_edges
fes.generate_fes(u_kn, rc_n, fes_type="histogram", histogram_parameters=histogram_parameters)
results = fes.get_fes(bin_center_i, reference_point="from-lowest", uncertainty_method="analytical")
center_f_i = results["f_i"]
center_df_i = results["df_i"]

#Free energies in kJ/mol
f_i_histo = center_f_i * RT
df_i_histo = center_df_i * RT

# Write out PMF
out_data = np.zeros([nbins,3])
out_data[:,0]=bin_center_i
out_data[:,1]=f_i_histo
out_data[:,2]=df_i_histo
np.savetxt("pmf_mbar_histo.out", out_data, fmt=['%8.3f','%8.3f','%8.3f'], header='bin f df')

# NOW KDE
kde_parameters = {}
kde_parameters["bandwidth"] = 0.5 * ((rc_max - rc_min) / nbins)
fes.generate_fes(u_kn, rc_n, fes_type="kde", kde_parameters=kde_parameters)
results = fes.get_fes(bin_center_i, reference_point="from-lowest")
center_f_i = results["f_i"]

#Free energies in kJ/mol
f_i_kde = center_f_i * RT

# Write out PMF
out_data = np.zeros([nbins,2])
out_data[:,0]=bin_center_i
out_data[:,1]=f_i_kde
np.savetxt("pmf_mbar_kde.out", out_data, fmt=['%8.3f','%8.3f'], header='bin f')
