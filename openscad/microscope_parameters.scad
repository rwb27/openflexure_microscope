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
big_stage = true;
motor_lugs = false;
version_numstring = "5.15.2";

// This sets the basic geometry of the microscope
sample_z = big_stage?65:40; // height of the top of the stage
leg_r = big_stage?30:25; // radius of innermost part of legs
hole_r = big_stage?15:10; // size of hole in the stage
xy_lever_ratio = big_stage?4.0/7.0:1.0; // mechanical advantage of actuator over stage - can be used to trade speed and precision
z_lever_ratio = big_stage?2.4:2.6; // as above, for Z axis (must be >1)
// The variables below affect the position of the objective mount
z_strut_l = big_stage?20:15; //length of struts supporting Z carriage
objective_clip_y = big_stage?12:6; // y position of clip for optics
objective_clip_w = 10; // width of the dovetail clip for the optics
foot_height = 15; //height of the feet (distance from bottom of body to table)

// These variables set the dimensions of flexures
// You might want to tweak them if your material (or printer)
// is different from the ones I've tested, though ABS/PLA extrusion
// is generally fine with my parameters
stage_flex_w = 4; // width of XY axis flexures
zflex_l = 1.5;    // length of (all) flexible bits
zflex_t = 0.75;   // thickness of (all) flexible bits

// Compile a sensible version string
version_string = str("v",version_numstring, big_stage?str("-LS",sample_z):"", motor_lugs?"-M":"");
echo("Compiling OpenFlexure Microscope ",version_string);

stage_t=5; //thickness of the XY stage (at thickest point, most is 1mm less)
flex_z1 = 0;      // z position of lower flexures for XY axis
flex_z2 = sample_z-stage_t; //height of upper XY flexures
z_strut_t = 6;  // (z) thickness of struts for Z axis
z_flex_w = 4;   // width of struts for Z axis
leg = [4,stage_flex_w,flex_z2+zflex_t]; // size of vertical legs
leg_middle_w = 12; // width of the middle part of each leg

leg_outer_w = leg_middle_w + 2*zflex_l + 2*leg[0]; // overall width of parallelogram legs that support the stagef
actuator = [6,(flex_z2 - flex_z1)*xy_lever_ratio,6]; // dimensions of the core part of the actuating levers for X and Y
actuating_nut_r = (flex_z2 - flex_z1)*xy_lever_ratio; // distance from leg_r to the actuating nut/screw for the XY axes
xy_actuator_travel = actuating_nut_r*0.15; // distance moved by XY axis actuators
z_flexure_x = (leg_r-zflex_l-max(5,leg[2]*0.1))*sqrt(2); // x position of the outside of the Z-axis static anchors (either side of the XY stage, on the X axis)
z_flexure_spacing = min(flex_z2-actuator[2]-z_strut_l*0.22-2, 30); // distance between the two sets of flexures on the Z axis
z_carriage = [(z_flexure_x-zflex_l*2-z_strut_l)+d,4,z_flexure_spacing+zflex_t]; //size of the moving block for the Z carriage
z_nut_y = (z_strut_l+zflex_l)*z_lever_ratio+zflex_l/2; // position of Z actuator
z_actuator_travel = z_nut_y*0.15; // distance moved by the Z actuator
z_carriage_y = z_strut_l+2*zflex_l; // y position of moving pivot on Z axis
z_link_w = 4; // width of linking bar between top Z-axis flexure struts
bridge_dz = 10; // spacing between thin links on legs
base_t=1; // thickness of the flat base of the structure
wall_h=15; // height of the stiffening vertical(ish) walls
wall_t=2; //thickness of the stiffening walls
zawall_h = z_flexure_spacing - 5; //height of wall near Z anchor
zbwall_h = z_actuator_travel+z_strut_t+1+2; //height of bridge over Z lever
illumination_clip_y = (-(leg_r-zflex_l-wall_t/2+leg_outer_w/2)/sqrt(2)
                       -wall_t/2-1); //position of clip for
                      // illumination/back foot.  This is set to
                      // coincide with the wall between the back
                      // two legs.
base_mounting_holes = [[-20,z_nut_y-4,0],[20,z_nut_y-4,0],[-z_flexure_x-4,-8,0],[z_flexure_x+4,-8,0]];