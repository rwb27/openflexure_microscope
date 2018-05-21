/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination                            *
*                                                                 *
* The illumination module includes the condenser lens mounts and  *
* the arm that holds them.                                        *
*                                                                 *
* (c) Richard Bowman, April 2018                                  *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;
include <./microscope_parameters.scad>;
use <./dovetail.scad>;


module each_illumination_arm_screw(){
    // A transform to repeat objects at each mounting point
    for(p=illumination_arm_screws) translate(p) children();
}

module cyl_slot(r=1, h=1, dy=2, center=false){
    hull() repeat([0,dy,0],2,center=true) cylinder(r=r, h=h, center=center);
}

module illumination_arm(){
    // The arm on which we mount the illumination
    front_dovetail_y = 35; // position of the main dovetail
    front_dovetail_w = 30; // width of the main dovetail
    bottom_z = illumination_arm_screws[0][2]; // z position where we mount it
    h = 80;
    
    translate([0,front_dovetail_y,bottom_z]) mirror([0,1,0]) dovetail_m([front_dovetail_w, 10, h]);
    
    difference(){
        hull(){
            translate([-front_dovetail_w/2,front_dovetail_y+2,bottom_z]) cube([front_dovetail_w, 10-2, h]);
            each_illumination_arm_screw() cyl_slot(r=4, h=3, dy=3);
        }
        each_illumination_arm_screw() cyl_slot(r=3/2*1.33, h=999, dy=3, center=true);
        each_illumination_arm_screw() translate([0,0,3]) cyl_slot(r=6, h=999, dy=3);
    }
}

illumination_arm();