/*

An illustration for the OpenFlexure Microscope; how to put the nut in

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <../compact_nut_seat.scad>;
use <../utilities.scad>;
use <../actuator_assembly_tools.scad>;
include <../microscope_parameters.scad>;

module column_frame(){
    rotate(135) translate([0,actuating_nut_r+leg_r,0]) children();
}

difference(){
    import("../../builds/body_SS.stl", convexity=99);

    // cut away the outside of the actuator housing to show the column
    column_frame() //difference(){
        translate([-99,999,-99]) cube(999);
        //nut_seat_void(999);
    //}
}
//null() column_frame() translate([0,actuating_nut_r,0]){
//    translate([ss_outer(0)[0]/2-2, 0, -30]) rotate([90,0,-90]) band_tool();
//}