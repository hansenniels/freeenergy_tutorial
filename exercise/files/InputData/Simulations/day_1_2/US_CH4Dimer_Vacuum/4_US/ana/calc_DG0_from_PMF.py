#!/usr/bin/python
"""
DETERMINATION OF STANDARD BINDING FREE ENTHALPY FROM INTEGRATION OF A 1D-PMF ALONG THE RADIAL DISTANCE
"""

# example call: python calc_DG0_from_PMF.py -f UI/pmf_UI.dat -rbound 0.8 -t 300 -skiprows 1

print(__doc__)

import numpy as np
import matplotlib.pyplot as plt
import argparse
import configparser

#########--PARSE INPUT--############
parser = argparse.ArgumentParser()
parser.add_argument('-f', dest='pmf', help='PMF file', type=str)
parser.add_argument('-rbound', dest='rbound', help='Cutoff distance bound/unbound region', type=float)
parser.add_argument('-t', dest='temp', help='Temperature in K', type=float, default = '300')
parser.add_argument('-skiprows', dest='skiprows', help='Skip this number of rows of PMF file (header)', type=int, default= '0')
args = parser.parse_args()
#########---------------############

#DEFINITION VARIABLES AND FUNCTIONS
RT = 8.314e-3*args.temp #Thermal Energy [kJ/mol]
V0 = 1.661              #Standard state volume [nm^3]

def PMF_correction(order_param, pmf_raw, r0=1.0):
    #Jacobian Correction for spherical coordinates
    jacobi = 4.0*np.pi*(order_param/r0)**2.0
    pmf_corr = pmf_raw + RT*np.log(jacobi)
    return pmf_corr

def calc_PMF_depth(order_param, pmf_raw, r0=1.0):
    pmf_corr = PMF_correction(order_param, pmf_raw, r0)
    #For PMF depth take negative (!) last value of corrected PMF
    PMF_depth = -pmf_corr[-1]
    return PMF_depth

def bound_volume(order_param, pmf_raw, r_bound, r0=1.0):
    #Determine index corrsponding to cutoff radius for bound/unbound region
    ind_bound = np.where(abs(order_param - r_bound) < 0.01)[0][0]
    pmf_boltzman = np.exp(-pmf_raw/RT)
    #Determine bound volume from numerical integration of "raw" (uncorrected) PMF over bound region
    Vb = r0**2.0*np.trapz(pmf_boltzman[0:ind_bound+1], order_param[0:ind_bound+1])
    return Vb

def calc_DG0(order_param, pmf_raw, r_bound, r0=1.0):
    PMF_depth = calc_PMF_depth(order_param, pmf_raw, r0)
    Vb = bound_volume(order_param, pmf_raw, r_bound, r0)
    DG0 = PMF_depth - RT*np.log(Vb/V0)
    return DG0

#READ IN AND PROCESS DATA
pmf_raw = np.genfromtxt(args.pmf, skip_header=args.skiprows)
#Shift global PMF minimum vertically to 0
pmf_raw[:,1] -= min(pmf_raw[:,1])

#CALCULATION
#ind_min = np.where(pmf_raw[:,1] == min(pmf_raw[:,1]))[0][0]
#r0 = pmf_raw[ind_min,0]
r0 = 1.0
Vb = bound_volume(pmf_raw[:,0], pmf_raw[:,1], args.rbound, r0)
DG_Vol = - RT*np.log(Vb/V0)
DG_PMF = calc_PMF_depth(pmf_raw[:,0], pmf_raw[:,1], r0)
DG0 = calc_DG0(pmf_raw[:,0], pmf_raw[:,1], args.rbound, r0)

print("DG_PMF = %f kJ/mol" % (DG_PMF))
print("DG_Vol = %f kJ/mol" % (DG_Vol))
print("DG0 = %f kJ/mol" % (DG0))

#PLOTTING
plt.clf()
fig, ax = plt.subplots()

#(1) Raw vs Corrected PMF
pmf_corr = PMF_correction(pmf_raw[:,0], pmf_raw[:,1], r0)
plt.plot(pmf_raw[:,0], pmf_raw[:,1], marker='None', ls='-', color='black', label='Raw')
plt.plot(pmf_raw[:,0], pmf_corr, marker='None', ls='-', color='red', label='Corrected')
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.xlabel('radial distance / nm',fontsize=12)
plt.ylabel('PMF / kJ mol$^{-1}$',fontsize=12)
plt.legend(loc='best', fontsize=10)
plt.savefig('PMF_raw_vs_corr.pdf', format='pdf', dpi=1000)

plt.clf()
fig, ax = plt.subplots()

#(2) Slope of corrected and Boltzmann Factor of raw PMF
#Determine Gradient
dr = pmf_raw[1,0]-pmf_raw[0,0]
pmf_gradient_corr = np.gradient(pmf_corr,dr)
#Normalization for Plotting
pmf_gradient_corr /= max(pmf_gradient_corr)
plt.plot(pmf_raw[:,0], pmf_gradient_corr, marker='None', ls='-', color='black', label='Normalized Slope Corr. PMF')
plt.plot(pmf_raw[:,0], np.exp(-pmf_raw[:,1]/RT), marker='None', ls='-', color='red', label='Boltzmann Raw PMF')
plt.xlabel('radial distance / nm',fontsize=12)
plt.legend(loc='best', fontsize=10)
plt.savefig('PMF_slope_vs_boltzmann.pdf', format='pdf', dpi=1000)
