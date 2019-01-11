# OpenFlexure Microscope
The OpenFlexure Microscope is a  3D printable microscope, including a precise mechanical stage to move the sample and focus the optics.  There are many different options for the optics, ranging from a webcam lens to a 100x, oil immersion objective.

![An OpenFlexure Microscope in an incubator (courtesy Stephanie Reichelt and Dario Bressan at CRUK, Cambridge)](https://rwb27.github.io/openflexure_microscope/images/microscope_in_incubator.jpg)

The trick of making a microscope out of a webcam has been around for a little while, and produces good results.  However, getting a nice mechanical stage to focus the microscope and move around on the sample is tricky.  This project is a 3D printable design that enables very fine (sub-micron) mechanical positioning of the sample and the lens, with surprisingly good mechanical stability.  It's discussed in various [media articles](https://github.com/rwb27/openflexure_microscope/wiki/Media-Articles) and a [paper in Review of Scientific Instruments](http://dx.doi.org/10.1063/1.4941068) (open access).

## Come join us!
Most of the development of this design has been done as part of [Richard's research](http://www.bath.ac.uk/physics/contacts/academics/richard-bowman/index.html) - if you would like to join our research group at Bath, and you have funding or are interested in applying for it, do get in touch.  Check the University of Bath jobs site, or findaphd.com, to see if we are currently advertising any vacancies.

## Kits and License
This project is open-source and is released under the CERN open hardware license.  You can buy a kit of the microscope from [WaterScope](http://www.waterscope.org/).  Currently, the kits being sold are version 5.15 and if you're looking for the assembly instructions they are in the [version 5.16 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.16.10-beta).

## Printing it yourself
To build the microscope, go to [version 5.16 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.16.10-beta) and
download the STL files and instructions.  Don't just print everything from the STL folder,
as currently it contains some parts that must be printed multiple times, and other parts
that are redundant.  The assembly instructions contain instructions on what parts to print - or you can consult the readme file in the [builds folder](https://github.com/rwb27/openflexure_microscope/tree/master/builds) if you want the latest version.  The top-level STL folder is a bit of a mixed bag of files generated during development; we've left it in the repository because it's helpful to share things with people, but there's no guarantee the files in there are up to date, or compatible with any particular version of the microscope.

If you've built one, let us know - add yourself to the [wiki page of builds](https://github.com/rwb27/openflexure_microscope/wiki/Assembly-Logs) or submit a [build report issue](https://github.com/rwb27/openflexure_microscope/issues/new?labels=build%20report).  This is a really helpful thing to do even if you don't suggest improvements or flag up problems.

## Instructions
The instructions are MarkDown format, in the [docs folder](./docs/).

## Get Involved!
This project is open so that anyone can get involved, and you don't have to learn OpenSCAD to help (although that would be great).  Ways you can contribute include:

* Get involved in [discussions on gitter](https://gitter.im/OpenFlexure-Microscope/Lobby) [![Join the chat at https://gitter.im/OpenFlexure-Microscope/Lobby](https://badges.gitter.im/OpenFlexure-Microscope/Lobby.svg)](https://gitter.im/OpenFlexure-Microscope/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* Share your microscope images (of both microscopes and what you've seen with them) in the [gallery](http://rwb27.github.io/openflexure_microscope/gallery/)
* [Raise an issue](https://github.com/rwb27/openflexure_microscope/issues) if you spot something that's wrong, or something that could be improved.  This includes the instructions/documentation.
* Suggest better text or images for the instructions.
* Improve the design of parts - even if you don't use OpenSCAD, STL files or descriptions of changes are helpful.
* Fork it, and make pull requests - again, documentation improvements are every bit as useful as revised OpenSCAD files.

Things in need of attention are currently described in [issues](https://github.com/rwb27/openflexure_microscope/issues) so have a look there if you'd like to work on something but aren't sure what.

## Related Repositories
Most of the Openflexure Microscope stuff lives on GitHub, under [my account](https://github.com/rwb27/).  Particularly useful ones are:
* The ["sangaboard" motor controller](https://github.com/rwb27/openflexure_nano_motor_controller/) based on an Arduino Nano + Darlington Pair ICs, developed collaboratively with [STICLab](http://www.sticlab.co.tz)
* The ["fergboard" motor controller](https://github.com/fr293/motor_board) by Fergus Riche
* An as-yet-quite-basic set of scripts that should become the [microscope software](https://github.com/rwb27/openflexure_microscope_software/)
* The higher precision, smaller range [block stage](https://github.com/rwb27/openflexure_block_stage)
* Some [characterisation scripts for analysing images of the USAF resolution test target](https://github.com/rwb27/usaf_analysis/)

## Compiling from source
If you want to print the current development version, you can compile the STL from the OpenSCAD files - but please still consult the DocuBricks documentation for quantities and tips on print settings, etc.  You can use GNU Make to generate all the STL files (just run ``make all`` in the root directory of the repository).  More instructions, including hints for Windows users, are available in [COMPILE.md](https://github.com/rwb27/openflexure_microscope/blob/master/COMPILE.md).
