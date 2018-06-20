OpenFlexure Microscope: STL files
=================================

This folder contains the printable files you'll need in order to make an
OpenFlexure microscope.  My intention is that the printing is described in
the DocuBricks format documentation, but this file is here for convenience.

As of the cantilevered objective mount version (5.19.0-b) the docubricks instructions are out of date, so use this file.

NB there are three locations in this repository that have STL files; the ``docs/stl`` folder (which is updated least frequently - these files should correspond to the current version of the documentation), the ``builds/`` folder (automatically built files, usually up to date and consistently named), and the ``stl/`` folder (a mixed bag of stuff, some of which is non-standard).  This is the best folder to use if you want to make sure your STL files match the documentation.

Use this folder if you want to get the latest version of the microscope.  

These files are all designed to print without support material or adhesion layer.  If you do use an adhesion layer, go for a raft rather than a brim; many of the moving parts will be rendered useless by a brim, and require lots of work with a craft knife to sort them out.  While there's no need for support, there are a few bridges; it might be a good idea to print the "just_leg_test.stl" file first, to make sure your printer can print them.  There are some versions of the main body that include a baked-in brim in the STL file.  This brim does a better job of not fouling the mechanism than most slicers, and is a good option if it won't stick without a brim.

To build an OpenFlexure microscope you need:

Plastic tools:
* band and nut insertion tools ``actuator_assembly_tools.stl``
* [optional] tool to insert the condenser lens: ``condenser_lens_tool.stl``
* [optional] tool to insert the tube lens: ``tube_lens_tool.stl``
* [optional] tools to remove the Raspberry Pi camera's lens: ``picamera_2_gripper.stl``, ``picamera_2_lens_gripper.stl``

Components:
* body of the microscope: ``body_<stage size><height>[-M].stl``.
* 3 feet: ``feet.stl`` or ``feet_tall.stl`` (contains all 3)
* 3 gears: ``gears.stl`` (contains all 3)
* illumination:
 - ``illumination_dovetail.stl``
 - ``condenser.stl``
* 2 sample clips: ``sample_clips.stl`` (contains both)
* optics module: ``optics_<camera>_<lens>_<stage size><height>.stl``
* [optional] camera cover: ``picamera_2_cover.stl``
* [optional] 3 small gears for motors: ``small_gears.stl`` (contains all 3)
* [optional] riser for the sample: ``sample_riser_<stage size><thickness>.stl``
* [optional] slide holder that works better if using immersion oil: ``slide_riser_LS10.stl``

In the filenames above, where there are multiple versions, parameters are included in angle brackets:
* ``<stage size>`` will be either ``SS`` for small stage or ``LS`` for large stage
* ``<height>`` is the height from the bottom of the main body to the top of the stage in mm, usually ``40`` or ``65`` (occasionally ``75`` if you are using a sample riser, or a larger body).
* Usually the above two parameters occur next to each other, so you will see ``SS40`` or ``LS65``.
* ``<camera>`` is the camera you are using, either ``picamera_2`` for the Raspberry Pi camera module v2, ``c270`` for the Logitech C270, or ``m12`` for a camera with a screw-on M12 lens mount.
* ``<lens>`` is the lens you are using, either ``pilens``, ``c270_lens``, or ``m12_lens`` if you are using the lens that came with your camera.  To use a finite-conjugate objective lens, you should specify ``rms_f40d16`` (to use a Comar tube lens, focal length 40mm, diameter 16mm) or ``rms_f50d13`` (for a 50mm focal length ThorLabs ac127-050-a lens)
* ``<thickness>`` is the thickness of a stage riser - the amount it adds to the height.  Usually a 10mm riser is used with a 65mm body to allow a taller objective to be used.
Optional bits of filenames are in square brackets above:
* ``-M`` in the body name means it has motor lugs to allow 28BYJ-48 stepper motors to be fitted
* ``_condenser`` in the illumination name means there is a mount for a plastic condenser lens
* ``_tall`` on the illumination or the feet means the body sits 26mm off the ground rather than 15mm, to give clearance for larger camera modules.

## Malaria microscope
For the malaria imaging version of the microscope, you need all the optional parts above, except the slide holder, we are using ``sample_riser_LS10.stl`` for now.  This goes with the ``main_body_LS65-M.stl``, ``feet.stl``, and ``optics_picamera_rms_f50d13_LS65.stl``.  You also need to use ``microscope_stand.stl`` to raise it above the table, or the camera will hit the table.  You can mount the ``sangaboard`` motor controller in ``microscope_stand_plus_sangaboard.stl``.  That means you need:
* band and nut insertion tools ``actuator_assembly_tools.stl``
* tool to insert the condenser lens: ``condenser_lens_tool.stl`` - this can also be used for the tube lens.
* [optional] tools to remove the Raspberry Pi camera's lens: ``picamera_2_gripper.stl``, ``picamera_2_lens_gripper.stl``
* body of the microscope: ``body_LS65-M.stl``.  There are three versions, two of which have built-in brims - the no brim version is best if it sticks reliably, but if you have adhesion issues try using one of the ones with brim.  This brim should be easier to remove than the brim added by most slicing programs.
* 3 feet: ``feet.stl`` (contains all 3)
* 3 gears: ``gears.stl`` (contains all 3)
* illumination:
 - ``illumination_dovetail.stl``
 - ``condenser.stl``
* 2 sample clips: ``sample_clips.stl`` (contains both)
* optics module: ``optics_picamera_rms_f50d13_LS65.stl``
* camera cover: ``picamera_2_cover.stl``
* 3 small gears for motors: ``small_gears.stl`` (contains all 3)
* riser for the sample: ``sample_riser_LS10.stl``


## Versions
**NB on this branch, only the LS65 body works, and optics will need to be recompiled.**

Which version of the body you need depends on two things: firstly, whether you want to use a large optics module (versions with LS65 or LS75 in the name) or a small one (versions with SS), and secondly whether you want attachment lugs for motors (files with -M in the name).  All the files start with `body_`.You need the SS version if you're using a Raspberry Pi camera or a Logitech C270 camera, together with the lens that came on the camera.  If you're using a microscope objective, or the USB camera with M12 lens, you need the LS65 version.  The microscope body takes around 8 hours on a RepRapPro Ormerod (and many other low-end printers) or about 5 hours on Ultimaker, MakerBot, and the like.  

There are several versions of the optics module, depending on your camera (Raspberry Pi Camera v2, Logitech C270, or WaterScope USB camera) and on whether you will use the lens from the camera (pilens, M12, ownlens) or an RMS objective and 40mm tube lens.  Make sure you pick the right STL file for your camera module!  There is a cover that fits over the Raspberry Pi camera module, and holds it firmly onto the optics module.  The following table shows compatibility:

| Optics Module | Microscope Version | Illumination Version | Feet |
|---------------|--------------------|----------------------|------|
| Raspberry Pi webcam & built-in lens | SS | SS40 | standard |
| Logitech c270 webcam & built-in lens | SS | SS40 | standard |
| WaterScope USB webcam & built-in lens | LS65 | LS65 | standard |
| Any camera, 35mm parfocal objective, 40mm tube lens | LS65 | LS65 | standard |
| Any camera, 45mm parfocal objective, 40mm tube lens | LS75 or LS65 + 10mm riser | LS75 | standard |
| Any camera, 35mm parfocal objective, 50mm tube lens | LS65 | LS65 | tall |
| Any camera, 45mm parfocal objective, 50mm tube lens | LS75 or LS65 + 10mm riser | LS75 | tall |

The optics module needs to print with some fine detail, so the dovetail meshes nicely with the stage.  A good way to ensure this is to print it at the same time as other parts - either print more than one optics module at a time, or print it at the same time as the microscope body.  This slows down the time for each layer, and means the plastic can cool more completely before the layer on top is deposited, resulting in a higher-quality part.  The optics module is best printed in black to cut down on stray light inside the tube - though it will still work in other colours.

