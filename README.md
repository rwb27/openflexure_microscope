# This repository has moved!
Active development continues on [GitLab.com](https://gitlab.com/openflexure/openflexure-microscope/) where you can find not only the up-to-date microscope designs, but also software and lots of other fun goodies.

# OpenFlexure Microscope
The OpenFlexure Microscope is a  3D printable microscope, including a precise mechanical stage to move the sample and focus the optics.  There are many different options for the optics, ranging from a webcam lens to a 100x, oil immersion objective.

![An OpenFlexure Microscope in an incubator (courtesy Stephanie Reichelt and Dario Bressan at CRUK, Cambridge)](https://rwb27.github.io/openflexure_microscope/images/microscope_in_incubator.jpg)

The trick of making a microscope out of a webcam has been around for a little while, and produces good results.  However, getting a nice mechanical stage to focus the microscope and move around on the sample is tricky.  This project is a 3D printable design that enables very fine (sub-micron) mechanical positioning of the sample and the lens, with surprisingly good mechanical stability.  It's discussed in various [media articles](https://github.com/rwb27/openflexure_microscope/wiki/Media-Articles) and a [paper in Review of Scientific Instruments](http://dx.doi.org/10.1063/1.4941068) (open access).

## Come join us!
Most of the development of this design has been done as part of various [research projects](http://www.bath.ac.uk/physics/contacts/academics/richard-bowman/index.html) - if you would like to join our research group at Bath, and you have funding or are interested in applying for it, do get in touch.  Check the University of Bath jobs site, or findaphd.com, to see if we are currently advertising any vacancies.  The team is bigger than Bath, though, and there are contibutors in Cambridge, Dar es Salaam, and beyond.

## Kits and License
This project is open-source and is released under the CERN open hardware license.  We are working on bring able to sell kits, and will update here once we have a good way of doing it,

## Printing it yourself
To build the microscope, go to [version 5.20 release](https://github.com/rwb27/openflexure_microscope/releases/tag/v5.20.0-b) and download the STL files and instructions.  Don't just print everything from the STL folder,
as there are a number of different configurations possible.  The [assembly instructions](http://rwb27.github.io/openflexure_microscope/docs/) contain instructions on what parts to print and how to build it.

If you've built one, let us know - add yourself to the [wiki page of builds](https://github.com/rwb27/openflexure_microscope/wiki/Assembly-Logs) or submit a [build report issue](https://github.com/rwb27/openflexure_microscope/issues/new?labels=build%20report).  This is a really helpful thing to do even if you don't suggest improvements or flag up problems.

## Instructions
The editable instructions are MarkDown format, in the [docs folder](./docs/), and [they can be viewed on github pages](http://rwb27.github.io/openflexure_microscope/docs/).

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
If you want to print the current development version, you can compile the STL from the OpenSCAD files - but please still consult the documentation for quantities and tips on print settings, etc.  You can use GNU Make to generate all the STL files (just run ``make all`` in the root directory of the repository).  More instructions, including hints for Windows users, are available in [COMPILE.md](https://github.com/rwb27/openflexure_microscope/blob/master/COMPILE.md).
