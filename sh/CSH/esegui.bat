#!/bin/csh
set DIM_TRANSFER_TYPE = $1
if ($DIM_TRANSFER_TYPE == "r" ) then 
  echo "non faccio nulla" > /home/dmsys/log/nuovo.log
  exit 0
endif
date >> /home/dmsys/log/history.log
