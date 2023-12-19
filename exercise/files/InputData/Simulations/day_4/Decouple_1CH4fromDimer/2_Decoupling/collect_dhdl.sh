#!/bin/bash

#copy and rename dhdl.xvg files into new folder
mkdir dhdl_files
for ((i=0; i<10; i++)){
  cp Lambda_$i/Production_MD/dhdl.xvg dhdl_files/dhdl.0$i.xvg
}

for ((i=10; i<11; i++)){
  cp Lambda_$i/Production_MD/dhdl.xvg dhdl_files/dhdl.$i.xvg
}
