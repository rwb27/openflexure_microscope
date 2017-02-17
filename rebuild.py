# -*- coding: utf-8 -*-
"""
OpenFlexure Microscope build script

This is the first version of my build script.  I should probably just use a
makefile, but this seems sensible for now.

"""

import os, sys, shutil

build_dir = "./builds"

configurations = {}

# Start by cleaning out the build directory and making new folders.
# I should probably be smarter about this...
shutil.rmtree(build_dir, ignore_errors=True)
os.mkdir(build_dir)
