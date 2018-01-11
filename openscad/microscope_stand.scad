// A quick and dirty stand for the microscope to let me play with
// longer optics modules

use <utilities.scad>;
include <microscope_parameters.scad>;
use <compact_nut_seat.scad>;
use <main_body.scad>;

h = 20;
t = 1.5;

module foot_footprint(){
    // the footprint of one foot/actuator column
    projection(cut=true) translate([0,0,-1]) screw_seat_shell();
}

module footprint(){
    hull(){
        translate([-2, illumination_clip_y-14]) square(4);
        each_actuator() translate([0, actuating_nut_r]) foot_footprint();
        translate([0, z_nut_y]) foot_footprint();
    }
}

difference(){
    sequential_hull(){
        translate([0,0,0]) linear_extrude(d) offset(0) footprint();
        translate([0,0,h-6]) linear_extrude(d) offset(0) footprint();
        translate([0,0,h-d]) linear_extrude(2*t) offset(t) footprint();
    }
    
    // hollow out the inside
    sequential_hull(){
        translate([0,0,1]) linear_extrude(d) offset(-t) footprint();
        translate([0,0,h-10]) linear_extrude(d) offset(-t) footprint();
        translate([0,0,h-d]) linear_extrude(d) offset(-6) footprint();
    }
    
    // indent the top
    translate([0,0,h]) linear_extrude(999) footprint();
    
    // side access
    translate([10,-999+30, 10]) cube(999);
    
    // breadboard mounting
    for(p=[[0,0,0], [25,25,0], [-25,25,0], [0,50,0], [0,-25,0]]) translate(p) cylinder(d=6.6,h=999,center=true);
        
    // board mounting
    each_actuator() translate([0, actuating_nut_r]) cylinder(d=4.4, h=999,center=true);
}
