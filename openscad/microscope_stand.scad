// A quick and dirty stand for the microscope to let me play with
// longer optics modules

use <utilities.scad>;
include <microscope_parameters.scad>;
use <compact_nut_seat.scad>;
use <main_body_transforms.scad>;
use <main_body.scad>;
use <feet.scad>;

motor_board = false;

t = 1.5;

raspi_z = motor_board?1:5;
raspi_board = [85, 58, 19]; //this is wrong, should be 85, 56, 19

h = raspi_z + raspi_board[2] + 5;

module foot_footprint(tilt=0){
    // the footprint of one foot/actuator column
    projection(cut=true) translate([0,0,-1]) screw_seat_shell(tilt=tilt);
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
        translate([raspi_board[0]/2,-1,motor_board?5:1]) cube(raspi_board + [2,2,-1]);
        // micro-USB power
        translate([10.6-10/2, -99, motor_board?0:-2]) cube([10,100,8]);
        // HDMI
        translate([32-25/2, -99, motor_board?0:-2]) cube([25,100,18]);
        // micro-SD card
        if(!motor_board) translate([0,raspi_board[1]/2+6,0]) cube([80,12,8], center=true);
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

module hull_from(){
    // take the convex hull betwen one object and all subsequent objects
    for(i=[1:$children-1]) hull(){
        children(0);
        children(i);
    }
}

module microscope_bottom(enlarge_legs=1.5, illumination_clip_void=true, lugs=true, feet=true, legs=true){
    hull(){
        projection(cut=true) translate([0,0,-d]) wall_inside_xy_stage();
        if(illumination_clip_void){
            translate([0, illumination_clip_y-14]) square([12, d], center=true);
        }
    }
    hull() reflect([1,0,0]) projection(cut=true) translate([0,0,-d]){
        wall_outside_xy_actuators();
        wall_between_actuators();
    }
    if(feet){
        each_actuator() translate([0, actuating_nut_r]) foot_footprint();
        translate([0, z_nut_y]) foot_footprint(tilt=z_actuator_tilt);
    }
    
    if(lugs) projection(cut=true) translate([0,0,-d]) mounting_hole_lugs();
    
    if(legs) offset(enlarge_legs) microscope_legs();
}

module microscope_legs(){
    difference(){
        each_leg() projection(cut=true) translate([0,0,-d]) leg();
        translate([-999,0]) square(999*2);
    }
}

module feet_in_place(grow_r=1, grow_h=2){
    each_actuator() translate([0,actuating_nut_r,0]) minkowski(){
        hull() outer_foot(lie_flat=false);
        cylinder(r=grow_r, h=grow_h, center=true);
    }
    translate([0,z_nut_y,0]) minkowski(){
        hull() middle_foot(lie_flat=false);
        cylinder(r=grow_r, h=grow_h, center=true);
    }
}

module footprint(){
    hull(){
        translate([-2, illumination_clip_y-14]) square(4);
        each_actuator() translate([0, actuating_nut_r]) foot_footprint();
        translate([0, z_nut_y]) foot_footprint(tilt=z_actuator_tilt);
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
module top_casing_shell(os=0, legs=true, lugs=true){
    // The "bucket" baseplate before holes and supports
    bottom = os<0?1:0;
    top_h = os<0?d:2*t;
    union(){
        translate([0,0,bottom]) linear_extrude(h+d-bottom) offset(os) footprint();
        hull_from(){
            translate([0,0,h]) linear_extrude(2*d) offset(os) footprint(); //top of the box
            
            for(a=[0,180]) translate([0,0,h+foot_height]) linear_extrude(top_h) difference(){
                offset(os*2+t) microscope_bottom(lugs=lugs, feet=false, legs=legs);
                rotate(a) translate([-999,0]) square(999*2);
            }
            //if(legs) translate([0,0,h+foot_height-t]) linear_extrude(t+top_h) offset(os+1.5+t) microscope_legs();
        }
        translate([0,0,h+foot_height]) linear_extrude(2*t-2*os) offset(os+t) microscope_bottom(lugs=true);
    }
}

module top_shell(){
    difference(){
        top_casing_shell(os=0, legs=true);
        top_casing_shell(os=-t, legs=false, lugs=false);
        
        // cut-outs so the feet and legs can protrude downwards
        translate([0,0,h+foot_height+t]) feet_in_place(grow_r=2*t, grow_h=t*4);
        translate([0,0,h+foot_height-t]) linear_extrude(999) offset(1.5) microscope_legs();
        for(p=base_mounting_holes) translate(p+[0,0,h+foot_height]){ 
             cylinder(r=3/2*1.1,h=20,center=true); 
        }
    }
}

union(){
    difference(){
        top_shell();
        
        // space for pi connectors
        translate([0,0,raspi_z]) pi_connectors();
        
        // indent the top
        //translate([0,0,h]) linear_extrude(999) footprint();
        
        // side access
        //translate([10,-999+30, 10]) cube(999);
        
        // motor cables
        if(motor_board) translate([0,z_nut_y,h]) cube([20,50,15],center=true);
        
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


//top_shell();
//feet_in_place();
//footprint();