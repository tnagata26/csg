#!/bin/bash

if [ "$1" = "--help" ]; then
   echo "This scripts cleans up the dpot tables for each interaction when using IMC"
   echo "Usage: ${0##*/}"
   echo USES:  do_external run_or_exit csg_get_interaction_property csg_get_property log csg_resample
   echo NEEDS: name min max step cg.inverse.kBT
   exit 0
fi

check_deps "$0"

name=$(csg_get_interaction_property name)
min=$(csg_get_interaction_property min)
max=$(csg_get_interaction_property max)
step=$(csg_get_interaction_property step)
kBT=$(csg_get_property cg.inverse.kBT)
log "purifying dpot for $name"

run_or_exit csg_resample --in ${name}.dpot.imc --out ${name}.dpot.new --grid ${min}:${step}:${max}

scheme=( $(csg_get_interaction_property do_potential 1) )
scheme_nr=$(( ( $1 - 1 ) % ${#scheme[@]} ))

if [ "${scheme[$scheme_nr]}" = 1 ]; then
  log "Update potential ${name} : yes"
  logrun do_external table linearop --withflag o ${name}.dpot.new 0 0
  logrun do_external table linearop --withflag i ${name}.dpot.new $kBT 0

  logrun do_external shift dpotnb ${name}.dpot.new ${name}.dpot.new
else
  log "Update potential ${name} : no"
  logrun do_external table linearop ${name}.dpot.new 0 0
fi
