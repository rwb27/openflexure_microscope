OpenFlexure Microscope: STL files
=================================

This folder contains the printable files you'll need in order to make an
OpenFlexure microscope.  My intention is that the printing is described in
the DocuBricks format documentation, but this file is here for convenience.

These files are all designed to print without support material or adhesion layer.  If you do use an adhesion layer, go for a raft rather than a brim; many of the moving parts will be rendered useless by a brim, and require lots of work with a craft knife to sort them out.  While there's no need for support, there are a few bridges; it might be a good idea to print the "just_leg_test.stl" file first, to make sure your printer can print them.

To build a basic OpenFlexure microscope you need:

Plastic tools:
* actuator_assembly_tools.stl
* [optional] tool to insert the condenser lens: condenser_lens_tool.stl
* [optional] tool to insert the tube lens: tube_lens_tool.stl
* [optional] tools to remove the Raspberry Pi camera's lens: picam2_board_gripper.stl, picam2_lens_remover.stl

Components:
* body of the microscope (there are 4 versions).
* 3 feet: feet.stl (contains all 3)
* 3 gears: gears.stl (contains 3)
* illumination arm (there are multiple versions).
* 2 sample clips: sample_clip.stl (need to print 2)
* optics module (there are 6 versions)
* [optional] camera cover: picam_cover.stl

Which version of the body you need depends on two things: firstly, whether you want to use a large optics module (versions with LS65 in the name) or a small one (versions with SS), and secondly whether you want attachment lugs for motors (files with -M in the name).  All the files start with `body_`.You need the SS version if you're using a Raspberry Pi camera or a Logitech C270 camera, together with the lens that came on the camera.  If you're using a microscope objective, or the USB camera with M12 lens, you need the LS65 version.  The microscope body takes around 8 hours on a RepRapPro Ormerod (and many other low-end printers) or about 5 hours on Ultimaker, MakerBot, and the like.  

The illumination arm is available in 4 versions: they all start with `illumination_and_back_foot_` and then you can choose either adjustable arm with a bare LED, or bare LED plus tape (`adj`) or one that uses a condenser lens (`condenser`).  It's important to match the type of microscope you're using (LS65 or SS).  If you are using a riser to make space for a larger objective (if you've got a 35mm parfocal length objective) you'll need the LS75 version.

There are several versions of the optics module, depending on your camera (Raspberry Pi Camera v2, Logitech C270, or WaterScope USB camera) and on whether you will use the lens from the camera (pilens, M12, ownlens) or an RMS objective and 40mm tube lens.  Make sure you pick the right STL file for your camera module!  There is a cover that fits over the Raspberry Pi camera module, and holds it firmly onto the optics module.

The optics module needs to print with some fine detail, so the dovetail meshes nicely with the stage.  A good way to ensure this is to print it at the same time as other parts - either print more than one optics module at a time, or print it at the same time as the microscope body.  This slows down the time for each layer, and means the plastic can cool more completely before the layer on top is deposited, resulting in a higher-quality part.  The optics module is best printed in black to cut down on stray light inside the tube - though it will still work in other colours.

