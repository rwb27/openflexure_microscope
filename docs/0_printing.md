# Printing the microscope
First, you will need to print or obtain the 3D printed parts.  If you bought a kit, skip this step! 

## Print settings
The microscope is designed to print without support material.  This is quite important; if you use support material it will require a lot of cleaning up, and you may well damage the mechanism.  I usually print with a layer size of 0.24mm on my Ormerod, which takes 8 hours for the main structure.  "low" quality on an Ultimaker 2 (0.15mm layers) produced similar results in about 5 hours.  Our Prusa i3 Mk3 takes a similar time.

If your printer has a standard-sized bed (180mmx180mm should be fine) then it should be possible to print the complete microscope in one go.  I do this if I'm using a machine that is well calibrated and reliable.  However, I find that it's often more reliable to print in batches (as small parts at the edge of the print bed can detach and cause it to fail).  I would recommend: 

*   Batch 1: Microscope, illumination and Optics module (main part)
*   Batch 2: Feet, gears, camera cover, camera board gripper, camera lens remover, gear riser

There is a test file that prints a single leg of the microscope - the Microscope leg test object. It's worth printing this first to check your settings are OK.

## Step
Make sure you have all the necessary parts and tools.  The parts should all be listed in the bill of materials, which is currently a work in progress.  We reccommend reading through all the instructions, rather than trusting what is currently listed here. 

**Plastic parts:** 
*   See the readme file in the [builds folder]()../builds).

**Metal hardware:** 
*   3x M3 hexagon head 25mm screws, stainless steel
*   3x M3 brass nut
*   8x M3 stainless steel washer
*   3-14x M3 8mm cap head screw (optional, for sample clips)
*   2x M2 6mm cap head screws

**Electronic parts:** 
*   White LED, resistor, wire, and 2-way JST header connector (assembled as one cable in the kit)
*   Raspbery Pi camera module (v2, though v1 works if you substitute the relevant STL files)
*   Raspberry Pi (with associated power supply, keyboard, monitor, etc.)

**Tools (not supplied in kit):** 
*   2.5mm hex key (optional, for attaching sample clips)
*   1.5mm hex key (to secure the camera using M2 screws)
*   tape (electrical tape or PTFE plumbers tape work, though regular sticky tape is also fine)
*   sharp craft knife (for trimming tape)
*   3mm drill bit in hand chuck (if you printed the parts yourself and need to open out the holes)

Don't forget the raspberry pi, camera module, and associated screen, power supply, SD card, keyboard, mouse, etc. (I have not listed these explicitly, but they're needed to run the Pi). Also, if you use the high resolution optics module or want to add motors, more parts are required.

## Clean-up of printed parts
If you printed the parts yourself, start by opening out the three holes in the microscope body with a drill as shown.  Make sure to go all the way through.  If you don't have a drill, you can improvise by screwing in an M3 screw all the way, then forcibly rotating it with a screwdriver.  Also, remove any loose strings of plastic from the underside of the sample stage, using a pair of pliers. The last step shouldn't be necessary if your machine is calibrated nicely for printing bridges.  If you purchased a kit, this may well have been done for you.

![](./images/main_body_drill.jpg)
