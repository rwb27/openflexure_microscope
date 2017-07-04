OpenFlexure Microscope: OpenSCAD Source
=======================================

This folder contains the source code that generates the STL files that you print to produce the microscope.  The relationship between the source files and the STL files is not yet 1:1, though I'm gradually working on that.  Most of the SCAD files produce a corresponding STL, but there are a few key support files that don't:

* ``microscope_parameters.scad`` defines most of the important variables (parameters) used in the design, for example the size of the microscope, whether or not it has motor lugs, etc. etc. - this is the file you are most likely to need to modify, for example to produce a microscope with particular settings.
* ``utilities.scad`` contains lots of handy functions I've coded along the way.  It's a slightly random assortment, but they are used in most of the other files and save a fair bit of typing.
* ``dovetail.scad`` defines the dovetail clips used to hold the optics module and the condenser.
* ``compact_nut_seat.scad`` defines the actuator column (the bit that holds the screw, nut and elastic band).  This is one of the most useful files for other projects - e.g. the OpenFlexure Block Stage uses it extensively.
* ``logo.scad`` is used to stamp the WaterScope logo on the microscope

Then for the main parts of the microscope:
* ``main_body.scad`` defines the main body.  This is by far the biggest file as you might expect.
* ``feet.scad`` produces the three front feet (two tilted and one untilted)
* ``gears.scad`` makes 3 gears for the actuators.
* ``illumination_and_rear_foot.scad`` produces the illumination column, which is combined with the back foot.  It's now in three pieces, for easier printing and to allow some adjustment of the condenser position.
* ``optics.scad`` defines, amongst other things, the optics module (the mount for the camera and objective).  This has a number of commented-out sections that must be uncommented depending on what you want to produce.  In particular, you must choose manually between an RMS objective and using a simpler lens.  You must also uncomment the correct line at the top of the file for the camera - the design will work with several camera modules defined in the ``cameras`` folder.
* ``sample_clip_2.scad`` produces clips to hold microscope slides onto the microscope stage.  This is now set to print two, and produces an STL file that is print-ready (i.e. the clips are on their side).
* ``sample_riser_2.scad`` makes a 10mm thick platform for a microscope slide.  You may need to use comments at the bottom of the file to print either the sample riser or the clip that holds the slide on.  A small spring is required to put the clip in the right place.
* ``small_gear.scad`` makes the gear you fit on a motor if you want to motorise the microscope.  NB it only makes one gear.

There are some that make tools too:
* ``actuator_assembly_tools.scad`` defines the tool for inserting elastic bands, and the tooll for pushing nuts into nut slots.  NB there is a new double-ended band tool defined at the bottom of the file, you'll need to use the comments to either produce this or the old-style one.
* ``tube_lens_tool.scad`` produces a ring of plastic, suitable for pushing the tube lens into its push-fit mount without damaging it.
* ``condenser_lens_tool.scad`` produces a ring of plastic, suitable for pushing the condenser lens into its push-fit mount without damaging it.
* ``lens_removal_tools.scad`` produces the tools needed to remove the lens from the Raspberry Pi camera module.  NB the lens removal tool is now superseded by the injection-moulded tool supplied by Raspberry Pi with each camera, but the board holder still helps to avoid damaging the flex.

Other files:
* ``baseplate.scad`` and ``baseplate_minimal.scad`` generate a baseplate, suitable for gluing onto some foam, if you want to mount the microscope in a box.  It's still work in progress...
* ``illustrations/`` contains various SCAD files that aim to create the illustrations needed for the instructions.  Very much work in progress, it's nowhere near finished.