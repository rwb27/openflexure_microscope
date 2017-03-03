# -*- coding: utf-8 -*-
"""
Created on Fri Mar  3 08:48:08 2017

@author: rwb34
"""

import subprocess

print("Initiating build of OpenFlexure Microscope body")
for suffix, constants in [("SS", ['motor_lugs=false', 'big_stage=false']),
                        ("SS-M", ['motor_lugs=true', 'big_stage=false']),
                        ("LS65", ['motor_lugs=false', 'big_stage=true', 'sample_z=65']),
                        ("LS65-M", ['motor_lugs=true', 'big_stage=true', 'sample_z=65']),
                        ]:
    output_filename = "body_{}.stl".format(suffix)
    options = ' '.join(["-D " + c for c in constants])
    command_string = r'"C:\Program Files\OpenSCAD\openscad.com" ' \
    '-o builds/{filename} {options} OpenSCAD/main_body.scad'.format(
            filename=output_filename, options=options)
    
    print("Generating {}...  ".format(output_filename), end='')
    status, output = subprocess.getstatusoutput(command_string)
    if status != 0:
        print("\nerror:")
        print("command:\n{}\n".format(command_string))
        print("output:")
        print(output)
    else:
        print("done")
