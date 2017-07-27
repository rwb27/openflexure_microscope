# OpenFlexure Microscope: Compiling from source

The microscope is modelled using OpenSCAD.  This means there's a collection of scripts that, when run, generate STL files that you can then print.  The best way to get hold of the latest STL files is to generate them yourself.  To do this, you will need [OpenSCAD](http://www.openscad.org/) (available for Windows, Mac and Linux).  The simplest way to build all the necessary STL files is to use GNU Make.  If you use Linux you will almost certainly have this, Mac OS should either have it or be able to get it from homebrew etc., and Windows you can get it through Cygwin or MinGW.

To build all the STL files (NB you don't need to print all of these, there are some alternatives), simply change directory to the root folder of this repository and run ``make all``.  This will compile the files and put them in the ``builds/`` directory.

## Make on Windows
I was happy to find out that [you can use make in MSYS](https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058), which comes bundled with Git for Windows. If you install Git for Windows, you can then download a copy of the executable file for make and put it in the bin directory.  For me, this was ``C:\Users\me\AppData\Local\Programs\Git\mingw64\bin`` though your installation may be different.

## OpenSCAD command line
You'll need to make sure OpenSCAD is in your executable path.  This is probably the case on Linux, but on Windows I just ran ``PATH="$PATH:/c/Program Files/OpenSCAD/"`` before running make.  I'm sure neater solutions exist...
