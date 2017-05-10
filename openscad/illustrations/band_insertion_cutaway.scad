/*

An illustration for the OpenFlexure Microscope; how to put the nut in

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <../compact_nut_seat.scad>;
use <../utilities.scad>;
use <../actuator_assembly_tools.scad>;
include <../microscope_parameters.scad>;

difference(){
    screw_seat(25, motor_lugs=false);

    difference(){ //an example actuator rod
        translate([-3,-10,0]) cube([6,10,5]);
        actuator_end_cutout();
    }
    rotate([0,90,0]) cylinder(r=999,h=999,$fn=4); //cutaway one side
}
actuator_column(25, 0, join_to_casing=false);

translate([ss_outer(0)[0]/2-2, 0, -30]) rotate([90,0,-90]) band_tool();