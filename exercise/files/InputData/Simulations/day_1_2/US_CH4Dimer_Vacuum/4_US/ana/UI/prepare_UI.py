#! /usr/bin/python
"""
Transforms COLVAR files to required format for UI analysis:
(1) order parameter | (2) forceconst. | (3) reference value
"""

print(__doc__)

import numpy as np

#Define used force constant and reference values for restraints for every window
forceconst_DR = 500
refpos = np.arange(0.35,1.2,0.05)

for i in refpos:
  window=str('{:.2f}'.format(i))
  print(window)
  time=np.genfromtxt("../../w_"+window+"/COLVAR_"+window, comments='#', usecols=0)
  comdist_win_i=np.genfromtxt("../../w_"+window+"/COLVAR_"+window, comments='#', usecols=1)
  out_data=np.zeros((np.size(comdist_win_i,axis=0),4))
  out_data[:,0]=time
  out_data[:,1]=comdist_win_i[:]
  out_data[:,2]=i
  out_data[:,3]=forceconst_DR
  np.savetxt("UI_"+window+".out", out_data, fmt=['%8.6f','%8.6f','%8.6f','%8.6f'])
