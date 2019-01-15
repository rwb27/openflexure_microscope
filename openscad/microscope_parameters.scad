/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope Parameters                   *
*                                                                 *
* This is the top-level configuration file for the OpenFlexure    *
* microscope, an open microscope and 3-axis translation stage.    *
* It gets really good precision over a ~10mm range, by using      *
* plastic flexure mechanisms.                                     *
*                                                                 *
* Generally I've tried to put parts (or collections of closely    *
* related parts) in their own files.  However, all the parts      *
* depend on the geometry of the microscope - so these parameters  *
* are gathered together here.  In general, the ones you might     *
* to change are towards the top!  Lower-down ones are defined in  *
* terms of higher-up ones - confusion might arise if you redefine *
* these later...                                                  *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
* http://www.github.com/rwb27/openflexure_microscope              *
* http://www.docubricks.com/projects/openflexure-microscope       *
* http://www.waterscope.org                                       *
*                                                                 *
******************************************************************/

d = 0.05;
$fn=32;

// These are the most useful parameters to change!
big_stage = true; //this option is obsolete and must now always be true...
motor_lugs = true;
endstops = false; //motor_lugs;
version_numstring = "5.20.0-b";
camera = "picamera_2"; //see cameras/camera.scad for valid values
optics = "pilens"; //see optics.scad for valid values
led_r = 5/2; //size of the LED used for illumination
feet_endstops = true;
beamsplitter = false; //enables a cut-out in some optics modules for a beamsplitter


// This sets the basic geometry of the microscope
sample_z = big_stage?65:40; // height of the top of the stage
leg_r = big_stage?30:25; // radius of innermost part of legs (stage size)
hole_r = big_stage?20:10; // size of hole in the stage
xy_lever_ratio = big_stage?4.0/7.0:1.0; // mechanical advantage of actuator over stage - can be used to trade speed and precision
z_lever_ratio = 1.0; // as above, for Z axis (must be >1)
// The variables below affect the position of the objective mount
z_strut_l = big_stage?18:15; //length of struts supporting Z carriage
objective_mount_y = big_stage?18:12; // y position of clip for optics
objective_mount_nose_w = 6; // width of the pointy end of the mount
condenser_clip_w = 14; // width of the dovetail clip for the condenser
foot_height=feet_endstops?15:15; //the endstops need a bit of extra height (or not)

// These variables set the dimensions of flexures
// You might want to tweak them if your material (or printer)
// is different from the ones I've tested, though ABS/PLA extrusion
// is generally fine with my parameters
stage_flex_w = 4; // width of XY axis flexures
zflex_l = 1.5;    // length of (all) flexible bits
zflex_t = 0.75;   // thickness of (all) flexible bits
zflex = [stage_flex_w, zflex_l, zflex_t]; // the above in new-style format
flex_a = 0.15;    // sine of the angle through which flexures can be bent

// Compile a sensible version string
version_string = str("v",version_numstring, big_stage?"-LS":"-SS", sample_z, motor_lugs?"-M":"");
echo(str("Compiling OpenFlexure Microscope ",version_string));

stage_t=5; //thickness of the XY stage (at thickest point, most is 1mm less)
flex_z1 = 0;      // z position of lower flexures for XY axis
flex_z2 = sample_z-stage_t; //height of upper XY flexures
z_strut_t = 6;  // (z) thickness of struts for Z axis
z_flex_w = 4;   // width of struts for Z axis
leg = [4,stage_flex_w,flex_z2+zflex_t]; // size of vertical legs
leg_middle_w = 12; // width of the middle part of each leg
actuator_h = 25; //height of the actuator columns
dz = 0.5; //small increment in Z (~ 2 layers)

leg_outer_w = leg_middle_w + 2*zflex_l + 2*leg[0]; // overall width of parallelogram legs that support the stagef
actuator = [3*1.2+2*2,(flex_z2 - flex_z1)*xy_lever_ratio,6]; // dimensions of the core part of the actuating levers for X and Y - NB should match the column_base_r in compact_nut_seat.scad
actuating_nut_r = (flex_z2 - flex_z1)*xy_lever_ratio; // distance from leg_r to the actuating nut/screw for the XY axes
xy_actuator_travel = actuating_nut_r*0.15; // distance moved by XY axis actuators

// Z axis
z_flexures_z1 = 8; // height of the lower Z flexure
z_flexures_z2 = min(sample_z - 12, 35); // " upper "
objective_mount_back_y = objective_mount_y + 2; //back of objective mount
z_anchor_y = objective_mount_back_y + z_strut_l + 2*zflex[1]; // fixed end of the flexure-hinged lever that actuates the Z axis
z_anchor_w = 20; //width of the Z anchor
zll = (z_strut_l + zflex[1])*z_lever_ratio; //required actuator lever length
zfz = z_flexures_z1; // shorthand for the next line only!
z_nut_y = z_anchor_y - zflex[1]/2 + sqrt(zll*zll - zfz*zfz);
z_actuator_travel = zll*0.15; // distance moved by the Z actuator
z_actuator_tilt = -asin(z_flexures_z1/zll); //angle of the Z actuator

z_flexure_x = (leg_r-zflex_l-max(5,leg[2]*0.1))*sqrt(2); // x position of the outside of the Z-axis static anchors (either side of the XY stage, on the X axis) (no longer used by Z axis but still in use elsewhere.)

bridge_dz = 10; // spacing between thin links on legs
base_t=1; // thickness of the flat base of the structure
wall_h=15; // height of the stiffening vertical(ish) walls
wall_t=2; //thickness of the stiffening walls
zawall_h = z_flexures_z2 - 10; //height of wall near Z anchor
zbwall_h = z_flexures_z2 - 10; //height of bridge over Z lever
illumination_clip_y = (-(leg_r-zflex_l-wall_t/2+leg_outer_w/2)/sqrt(2)
                       -wall_t/2-1); //position of clip for
                      // illumination/back foot.  This is set to
                      // coincide with the wall between the back
                      // two legs. TODO: remove this
illumination_arm_screws = [[20,z_nut_y,sample_z-2],[-20,z_nut_y,sample_z-2], 
                           [0,(leg_r + leg_outer_w)/sqrt(2) + 4,sample_z-2]];
                      // positions of screws that mount the adjustable version of the 
                      // illumination arm
condenser_clip_y = -8; //position of dovetail for old condenser assembly TODO: rename this
base_mounting_holes = [[-20,z_nut_y-4,0],
                       [20,z_nut_y-4,0],
                       [-z_flexure_x-4,big_stage?-8:-4,0],
                       [z_flexure_x+4,big_stage?-8:-4,0]]; 
                       // holes to screw the microscope to a baseplate

endstop_extra_ringheight=feet_endstops?1:0;
endstop_hole_offset=0;
//this is a temporary option to printfeet with smaller travel
//without this with 15mm hole the stage hits the objective
//the stage can move ~3mm in each direction, so the actuator only moves
//~1.7 mm
avoid_objective_xyfoot_offset=xy_actuator_travel-1.8;