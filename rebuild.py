# -*- coding: utf-8 -*-
"""
OpenFlexure Microscope build script

This is the first version of my build script.  I should probably just use a
makefile, but this seems sensible for now.

"""

import os, sys, shutil

build_dir = "./builds"

configurations = {
                'common':{
                    'constants':{},
                    'build_files':['feet',
                                   'gears',
                                   'actuator_assembly_tools',
                                   'sample_clips',
                                   'small_gear',
                                   ]
                    },
                'SS':{
                    'constants':{'big_stage':'false',
                                 'motor_lugs':'false'},
                    'build_files':['main_body',
                                   'illumination_and_back_foot'
                                   ]
                    },
                'SS-M':{
                    'constants':{'big_stage':'false',
                                 'motor_lugs':'true'},
                    'build_files':['main_body',
                                   'illumination_and_back_foot',
                                   ]
                    },
                'LS65':{
                    'constants':{'big_stage':'true',
                                 'motor_lugs':'false'},
                    'build_files':['main_body',
                                   'illumination_and_back_foot'
                                   ]
                    },
                'LS65-M':{
                    'constants':{'big_stage':'true',
                                 'motor_lugs':'true'},
                    'build_files':['main_body',
                                   'illumination_and_back_foot'
                                   ]
                    },
                 }

# Start by cleaning out the build directory and making new folders.
# I should probably be smarter about this...
shutil.rmtree(build_dir, ignore_errors=True)
os.mkdir(build_dir)
