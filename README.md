# OpenFlexure Microscope
A 3D Printable microscope and translation stage. 

The trick of making a microscope out of a webcam has been around for a little while, and produces good results.  However, getting a nice mechanical stage to focus the microscope and move around on the sample is tricky.  This project is a 3D printable design that enables very fine (sub-micron) mechanical positioning of the sample and the lens, with surprisingly good mechanical stability.  It's discussed in a [paper in Review of Scientific Instruments](http://dx.doi.org/10.1063/1.4941068) (open access).

## Kits and License
This project is open-source and is released under the CERN open hardware license.  You can buy a kit of the microscope from [WaterScope](http://www.waterscope.org/).  Currently, the kits being sold are version 5.15 and if you're looking for the assembly instructions they are in the [version 5.15 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.15.1-rc0).

## Printing it yourself
To build the microscope, go to h[version 5.15 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.15.1-rc0) and
download the STL files and instructions.  Don't just print everything from the STL folder,
as currently it contains some parts that must be printed multiple times, and other parts
that are redundant.  I plan to implement an automated build system in the future, that will
generate a nice STL folder (or even pre-plated prints), but for now please refer to 
the DocuBricks documentation for printing instructions.

The previous release is on [DocuBricks](http://docubricks.com/projects/openflexure-microscope), and I will add the latest version once it's been road-tested a bit further. 

If you want to print the current development version, you can compile the STL from the 
OpenSCAD files or download the STL files from this repository - but please still consult the DocuBricks
documentation for quantities and tips on print settings, etc.


