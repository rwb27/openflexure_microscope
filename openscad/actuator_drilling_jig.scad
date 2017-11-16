/******************************************************************
*                                                                 *
* OpenFlexure Microscope: actuator column drilling jig            *
*                                                                 *
* If you need to drill out the hole for the M3 screw, it's not    *
* hard to snap the flexure at the bottom of the actuator column.  *
* This tool is inserted from the bottom of the microscope to stop *
* the column rotating, and hopefully avoid snapping the flexure.  *
* To use it, slide it in from the bottom.  Then, when you drill   *
* out the hole, hold the tool and *not* the body of the           *
* microscope, so no torque goes through the microscope body.      *
* An M4 screw can be used to mount the tool to a workbench.       *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;
use <./compact_nut_seat.scad>;
use <./logo.scad>;
use <./dovetail.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.

outer_clearance = 0.5;
cr = column_base_radius() + outer_clearance;

difference(){
    translate([0,0,-7]) linear_extrude(actuator_h+5) offset(-outer_clearance) projection(cut=true) nut_seat_void();
    
    //void for the actuator column
    minkowski(){
        actuator_column(h=actuator_h+1, no_voids=true, flip_nut_slot=true);
        cylinder(r=0.5, h=d, $fn=8);
    }
    //clearance for the lever
    translate([-cr,0,0]) mirror([0,1,0]) cube([cr*2,999,999]);
    //clearance for the column core
    cylinder(r=cr, $fn=16, h=999);
    //mounting bolt
    translate([0,0,-4])cylinder(r=4,h=6);
    cylinder(r=2.6,h=999,center=true);
}