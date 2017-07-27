# OpenFlexure Microscope
A 3D Printable microscope and translation stage. 

The trick of making a microscope out of a webcam has been around for a little while, and produces good results.  However, getting a nice mechanical stage to focus the microscope and move around on the sample is tricky.  This project is a 3D printable design that enables very fine (sub-micron) mechanical positioning of the sample and the lens, with surprisingly good mechanical stability.  It's discussed in a [paper in Review of Scientific Instruments](http://dx.doi.org/10.1063/1.4941068) (open access).

## Kits and License
This project is open-source and is released under the CERN open hardware license.  You can buy a kit of the microscope from [WaterScope](http://www.waterscope.org/).  Currently, the kits being sold are version 5.15 and if you're looking for the assembly instructions they are in the [version 5.16 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.16.10-beta).

## Printing it yourself
To build the microscope, go to [version 5.16 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.16.10-beta) and
download the STL files and instructions.  Don't just print everything from the STL folder,
as currently it contains some parts that must be printed multiple times, and other parts
that are redundant.  The assembly instructions contain instructions on what parts to print - or you can consult the readme file in the [STL folder](https://github.com/rwb27/openflexure_microscope/tree/master/docs/stl).  The top-level STL folder is a bit of a mixed bag of files generated during development; we've left it in the repository because it's helpful to share things with people, but there's no guarantee the files in there are up to date, or compatible with any particular version of the microscope.

The previous release is on [DocuBricks](http://docubricks.com/projects/openflexure-microscope), and I will add the latest version once it's been road-tested a bit further. 

## Compiling from source
If you want to print the current development version, you can compile the STL from the OpenSCAD files - but please still consult the DocuBricks documentation for quantities and tips on print settings, etc.  You can use GNU Make to generate all the STL files (just run ``make all`` in the root directory of the repository).  More instructions, including hints for Windows users, are available in [COMPILE.md](https://github.com/rwb27/openflexure_microscope/blob/master/COMPILE.md).

## Get Involved!
This project is open so that anyone can get involved, and you don't have to learn OpenSCAD to help (although that would be great).  Ways you can contribute include:

* [Raise an issue](https://github.com/rwb27/openflexure_microscope/issues) if you spot something that's wrong, or something that could be improved.  This includes the instructions/documentation.
* Suggest better text or images for the instructions.
* Improve the design of parts - even if you don't use OpenSCAD, STL files or descriptions of changes are helpful.
* Fork it, and make pull requests - again, documentation improvements are every bit as useful as revised OpenSCAD files.

Things in need of attention are currently described in [issues](https://github.com/rwb27/openflexure_microscope/issues) so have a look there if you'd like to work on something but aren't sure what.
