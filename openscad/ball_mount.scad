// simple adapter to mount ball-on-a-stick to the stage
use <./utilities.scad>;
use <./main_body.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.


h=10; //height of adapter
stick_l=10+17.5/2; //distance from bottom of stick to centre
stick_r=5;
stick_z=h-stick_r+1;

difference(){
    hull(){
        each_actuator() reflect([1,0,0]) translate([-leg_middle_w/2,-zflex_l-4,0]) cylinder(r=2.5,h=h); //mounting bolts
        translate([-5,stick_l,0]) cube([10,2.4,h]);
    }
    
    //the stick
    translate([0,stick_l,stick_z]) rotate([90,0,0]){
        cylinder(r=stick_r, h=999);
        cylinder(r=4/2*1.2, h=999, center=true);
    }
    //the central hole
    cylinder(r=hole_r, h=999, center=true);
    //mounting holes
    each_actuator() reflect([1,0,0]) translate([-leg_middle_w/2,-zflex_l-4,4]){
        cylinder(r=2.7,h=999); //mounting bolts
        cylinder(r=3/2*1.2,h=999,center=true); //mounting bolts
    }
}