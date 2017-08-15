/*

This file should render the optics of the microscope...

(c) 2017 Richard Bowman, released under CERN Open Hardware License

*/
use <"../compact_nut_seat.scad">;
include <microscope_parameters.scad>;

difference(){
    import("../../builds/body_SS.stl");

    // cut away the outside of the actuator housing to show the column
    leg_frame(135) translate([0,actuating_nut_r,0]) difference(){
        translate([-99,0,-99]) cube(999);
        nut_seat_void(999);
    }
}