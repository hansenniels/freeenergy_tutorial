#! /usr/bin/python
"""
Transforms COLVAR files to required format for WHAM analysis:
(1) time | (2) order parameter - reference value
"""
print(__doc__)


import numpy as np
import sys
import os
from subprocess import call

#Define used force constant and reference values for restraints for every window
refpos = np.arange(0.35,1.2,0.05)
forceconst_DR = 500

def generate_pdo(num):
  window=str('{:.2f}'.format(num))
  print (window)
  filename = "pullx_umbrella_" + window + ".pdo"
  with open(filename, "w") as pdo_file:
    pdo_file.write("# UMBRELLA      3.0\n")
    pdo_file.write("# Component selection: 0 0 1\n")
    pdo_file.write("# nSkip 1\n")
    pdo_file.write("# Ref. Group 'TestAtom'\n")
    pdo_file.write("# Nr. of pull groups 1\n")
    pdo_file.write("# Group 1 '1POH'  Umb. Pos. " + window + " Umb. Cons. " + str(forceconst_DR) + "\n")
    pdo_file.write("#####\n")
  return filename

for i in refpos:
  window=str('{:.2f}'.format(i))
  generate_pdo(i)
  time=np.genfromtxt("../../w_"+window+"/COLVAR_"+window, comments='#', usecols=0)
  colvar=np.genfromtxt("../../w_"+window+"/COLVAR_"+window, comments='#', usecols=1)
  #SUBSTRACT REFERENCE VALUE FROM ACTUAL VALUE
  colvar-=i
  data = np.array([time, colvar])
  data = data.T
  datafile_id = open("pullx_umbrella_" + window + ".pdo", 'a+')
  np.savetxt(datafile_id, data, fmt=['%8.3f','%8.3f'])
  datafile_id.close()
  with open("pdo-files.dat", "a") as pdolistfile:
    pdolistfile.write("pullx_umbrella_" + window + ".pdo\n")
