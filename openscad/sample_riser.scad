/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Riser to mount sample slightly higher   *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <utilities.scad>;
use <main_body.scad>;
use <main_body_transforms.scad>;
include <microscope_parameters.scad>;

$fn=24;

h = 10;


module simple_riser(h=10){
    // Make the stage thicker by height h, to raise up the slide
    // NB you'll need to raise the illumination too!
    difference(){
		hull() each_leg() translate([0,-zflex_l-d,h/2]) cube([leg_middle_w+2*zflex_l,2*d,h],center=true); //hole in the stage
        cylinder(r=hole_r,h=999,center=true);
		each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-zflex_l-4,3.5]){
            cylinder(r=3/2*1.2,h=999, center=true); //mounting holes
            cylinder(r=3*1.2,h=999); //mounting holes
        }
        each_leg() translate([0,-zflex_l-4,0]) cylinder(r=3/2*0.95, h=999, center=true);
	}
}
simple_riser(h=h);