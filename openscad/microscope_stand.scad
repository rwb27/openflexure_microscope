// A quick and dirty stand for the microscope to let me play with
// longer optics modules

use <utilities.scad>;
include <microscope_parameters.scad>;
use <compact_nut_seat.scad>;
use <main_body.scad>;

t = 1.5;

raspi_z = 5;
raspi_board = [85, 58, 19];

h = raspi_z + raspi_board[2] + 5;

module foot_footprint(){
    // the footprint of one foot/actuator column
    projection(cut=true) translate([0,0,-1]) screw_seat_shell();
}

module pi_frame(){
    // coordinate system relative to the corner of the pi.
    translate([0,15]) rotate(-45) translate([-raspi_board[0]/2, -raspi_board[1]/2]) children();
}

module pi_footprint(){
    // basic space for the Pi (in 2D)
    pi_frame() translate([-1,-1]) square([raspi_board[0]+2,raspi_board[1]+2]);
}

module pi_connectors(){
    pi_frame(){
        // USB/network ports
        translate([raspi_board[0]/2,-1,+1]) cube(raspi_board + [2,2,-1]);
        // micro-USB power
        translate([10.6-10/2, -99, -2]) cube([10,100,8]);
        // HDMI
        translate([32-25/2, -99, -4]) cube([25,100,14]);
    }
}

module pi_hole_frame(){
    // This transform repeats objects at each hole in the pi PCB
    pi_frame() translate([3.5,3.5]) repeat([58,0,0],2) repeat([0,49,0], 2) children();
}

module pi_support_frame(){
    // position supports for each of the pi's mounting screws
    pi_frame() translate([3.5,3.5]) repeat([58,0,0],2) repeat([0,49,0], 2) children();
}
module pi_supports(){
    // pillars into which the pi can be screwed
    difference(){
        pi_support_frame() cylinder(h=raspi_z, d=7);
        pi_support_frame() cylinder(h=999, d=2.9, center=true);
    }
}

module footprint(){
    hull(){
        translate([-2, illumination_clip_y-14]) square(4);
        each_actuator() translate([0, actuating_nut_r]) foot_footprint();
        translate([0, z_nut_y]) foot_footprint();
        offset(t) pi_footprint();
    }
}

module basic_shell(){
    // The "bucket" baseplate before holes and supports
    difference(){
        union(){
            sequential_hull(){
                translate([0,0,0]) linear_extrude(d) offset(0) footprint();
                translate([0,0,h-6]) linear_extrude(d) offset(0) footprint();
                translate([0,0,h-d]) linear_extrude(2*t) offset(t) footprint();
            }
            
        }
        
        // hollow out the inside
        sequential_hull(){
            translate([0,0,1]) linear_extrude(d) offset(-t) footprint();
            translate([0,0,h-10]) linear_extrude(d) offset(-t) footprint();
            translate([0,0,h-d]) linear_extrude(d) difference(){
                offset(-2*t) footprint();
                translate([-99, illumination_clip_y-14+10-999]) square(999);
                each_actuator() translate([-99, actuating_nut_r-5]) square(999);
            }
        }
    }
}

union(){
    difference(){
        basic_shell();
        
        // space for pi connectors
        translate([0,0,raspi_z]) pi_connectors();
        
        // indent the top
        translate([0,0,h]) linear_extrude(999) footprint();
        
        // side access
        //translate([10,-999+30, 10]) cube(999);
        
        // holes for the pi go all the way through
        pi_support_frame() cylinder(h=999, d=2.9, center=true);
        
        // breadboard mounting
        for(p=[[0,0,0], [25,25,0], [-25,25,0], [0,50,0], [0,-25,0]]) translate(p) cylinder(d=6.6,h=999,center=true);
            
        // holes at 3 corners to allow mounting to something underneath/stacking
        each_actuator() translate([0, actuating_nut_r]){
            cylinder(d=4.4, h=20, center=true);
            cylinder(d=2.9, h=999, center=true);
        }
        translate([0, illumination_clip_y-14+7]){
            cylinder(d=4.4, h=20, center=true);
            cylinder(d=2.9, h=999, center=true);
        }
    }
    
    // supports for the pi circuit board
    pi_supports();
}
