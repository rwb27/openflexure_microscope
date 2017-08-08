# OpenFlexure Microscope: Compiling from source

The microscope is modelled using OpenSCAD.  This means there's a collection of scripts that, when run, generate STL files that you can then print.  The best way to get hold of the latest STL files is to generate them yourself.  To do this, you will need [OpenSCAD](http://www.openscad.org/) (available for Windows, Mac and Linux).  The simplest way to build all the necessary STL files is to use GNU Make.  If you use Linux you will almost certainly have this, Mac OS should either have it or be able to get it from homebrew etc., and Windows you can get it through Cygwin or MinGW.

To build all the STL files (NB you don't need to print all of these, there are some alternatives), simply change directory to the root folder of this repository and run ``make all``.  This will compile the files and put them in the ``builds/`` directory.

## Make on Windows
I was happy to find out that [you can use make in MSYS](https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058), which comes bundled with Git for Windows. If you install Git for Windows, you can then download a copy of the executable file for make and put it in the bin directory.  For me, this was ``C:\Users\me\AppData\Local\Programs\Git\mingw64\bin`` though your installation may be different.  NB to start MSYS on Windows, look for "Git Bash" in your Start menu.

## OpenSCAD command line
You'll need to make sure OpenSCAD is in your executable path.  This is probably the case on Linux, but on Windows I just ran ``PATH="$PATH:/c/Program Files/OpenSCAD/"`` before running make.  A more permanent solution is to symlink the OpenSCAD binary into your path.  I used the following command line (from within MSYS), which ought to work for most people though you may need to tweak the folders:
```
cd /mingw64/bin
ln -s /c/Program\ Files/OpenSCAD/openscad.exe openscad.exe
```
NB this must be run from MSYS (aka "Git Bash") *not* the usual Windows command prompt.  

On mac, you may need to add a symlink as well, probably from ``/usr/local/bin/openscad`` -> ``/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`` (I've not checked these paths but they should be approximately right).
