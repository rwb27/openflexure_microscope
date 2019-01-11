#!/bin/bash

openscad=OpenSCAD
options="--render -D 'big_stage=true' -D 'sample_z=65' -D 'motor_lugs=true'"
input="../../openscad/main_body.scad"
output_prefix="main_body_LS65-M"

renders=(
  _side_3D
  300,0,300,0,20,40
  _side
  300,20,40,0,20,40
  _side_45
  300,-280,40,0,20,40
  _top
  0,0,400,0,0,0
  _bottom_3D
  0,-200,-300,0,0,0
)
for ((i=0;i<${#renders[@]};i+=2)) #iterate through 2-at-a-time
do
  cmd="${openscad} -o ${output_prefix}${renders[i]}.png ${options} --camera=${renders[i+1]} --imgsize=640,480 ${input}"
  echo "$cmd"
  eval "$cmd"
done

