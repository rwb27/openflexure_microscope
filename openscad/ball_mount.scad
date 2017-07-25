// simple adapter to mount ball-on-a-stick to the stage
use <./utilities.scad>;
use <./main_body.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.


h=7; //height of adapter
stick_l=10+17.5/2; //distance from bottom of stick to centre
stick_d=5; //diameter of the mounting post (NB should be slightly over-sized)
stick_z=h-stick_d/2+1;

difference(){
    hull(){
        each_actuator() reflect([1,0,0]) translate([-leg_middle_w/2,-zflex_l-4,0]) cylinder(r=2.5,h=h); //mounting bolts
        translate([-5,stick_l,0]) cube([10,2.4,h]);
    }
    
    //the stick
    translate([0,0,h]) rotate([0,45,0]){
        cube([stick_d, 2*stick_l, stick_d], center=true);
        cube([stick_d-1, 999, stick_d-1], center=true); //clearance for stud
    }
    //holes for clamping bolts
    reflect([1,0,0]) translate([stick_d/sqrt(2)+3,hole_r+3,-1]) cylinder(r=3/2*0.95,h=999);
    
    //the central hole
    cylinder(r=hole_r, h=999, center=true);
    //mounting holes
    each_actuator() reflect([1,0,0]) translate([-leg_middle_w/2,-zflex_l-4,4]){
        cylinder(r=3.3,h=999); //mounting bolts
        cylinder(r=3/2*1.2,h=999,center=true); //mounting bolts
    }
}

//the clamp
difference(){
    hull() reflect([1,0,0]) translate([stick_d/sqrt(2)+3,0,0]) cylinder(r=2.5, h=3);
    
    reflect([1,0,0]) translate([stick_d/sqrt(2)+3,0,-1]) cylinder(r=3/2*1.2, h=999);
}