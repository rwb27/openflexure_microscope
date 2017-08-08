# OpenFlexure Microscope: Compiling from source

The microscope is modelled using OpenSCAD.  This means there's a collection of scripts that, when run, generate STL files that you can then print.  The best way to get hold of the latest STL files is to generate them yourself.  To do this, you will need [OpenSCAD](http://www.openscad.org/) (available for Windows, Mac and Linux).  The simplest way to build all the necessary STL files is to use GNU Make.  If you use Linux you will almost certainly have this, Mac OS should either have it or be able to get it from homebrew etc., and Windows you can get it through Cygwin or MinGW.

To build all the STL files (NB you don't need to print all of these, there are some alternatives), simply change directory to the root folder of this repository and run ``make all``.  This will compile the files and put them in the ``builds/`` directory.

## Make on Windows
I was happy to find out that [you can use make in MSYS](https://gist.github.com/evanwill/0207876c3243bbb6863e65ec5dc3f058), which comes bundled with Git for Windows. If you install Git for Windows, you can then download a copy of the executable file for make and put it in the bin directory.  For me, this was ``C:\Users\me\AppData\Local\Programs\Git\mingw64\bin`` though your installation may be different.  NB to start MSYS on Windows, look for "Git Bash" in your Start menu.

## OpenSCAD command line
You'll need to make sure OpenSCAD is in your executable path so the build script can [run it from the command line](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment).  This is probably the case on Linux, but on Windows I just ran ``PATH="$PATH:/c/Program Files/OpenSCAD/"`` before running make.  A more permanent solution is to put that command line into a text file ``.bash_profile`` in your home directory (i.e. ``C:\Users\me\.bash_profile``).  If it doesn't exist, just create a new text file with that as the only line.  Once you've done this, OpenSCAD will automatically be added to your path every time you start MSYS (aka Git Bash).  NB the filename does not have a ``.txt`` extension, and it won't work if you leave one there.  Symlinking the OpenSCAD binary into your mingw64 binaries folder seems to break things like the OpenSCAD includes directory, so use the method above in preference if you can.

On mac, you may need to add a symlink as well, probably from ``/usr/local/bin/openscad`` -> ``/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`` (I've not checked these paths but they should be approximately right).
