/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope baseplate                    *
*                                                                 *
* This part fits undern     *
*                                                                 *
* (c) Richard Bowman, December 2016                               *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;
use <./nut_seat_with_flex.scad>;
use <./logo.scad>;               
use <./dovetail.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.
h = 35; //height of microscope above bottom
wall_height = h - foot_height; //height of wall

module leg_frame(angle){
    // Transform into the frame of one of the legs of the stage
	rotate(angle) translate([0,leg_r,]) children();
}

module add_hull_base(h=1){
    // Take the convex hull of some objects, and add it in as a
    // thin layer at the bottom
    union(){
        intersection(){
            hull() children();
            cylinder(r=9999,$fn=8,h=h); //make the base thin
        }
        children();
    }
}

module screw_seat_cup(h=20){
	ss=ss_outer(999);
    t=3;
	difference(){
        hull(){
            resize([ss[0],ss[1],d]) cylinder(r=ss[1], h=1, $fn=32); //body
            translate([0,0,h]) resize([ss[0]+3,ss[1]+3,2]) cylinder(r=ss[1], h=1, $fn=32); //body
        }
        
        //hole for the foot
        translate([0,0,h]) resize(ss) cylinder(r=ss[1], h=1, $fn=32); 
        translate([0,0,0.5]) resize(ss-[3,3,0]) cylinder(r=ss[1], h=1, $fn=32);
    }
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){
	//Actuator housings (screw seats and motor mounts)
	reflect([1,0,0]) leg_frame(45) translate([0,actuating_nut_r,0]){
        screw_seat_cup(h=h-foot_height);
    }
    add_hull_base(1){
        //wall between the cups
        hull() reflect([1,0,0]) leg_frame(45) translate([0,actuating_nut_r,0]){
            ss = ss_outer(0);
            translate([ss[0]/2-1,0,0]) cylinder(d=2, h=wall_height,$fn=8);
        }
        
        //cups to plate
        reflect([1,0,0]) hull(){
            translate([-8,illumination_clip_y+3,0])
            cylinder(d=2, h=wall_height,$fn=8);
        
            leg_frame(45) translate([0,actuating_nut_r,0]){
                ss = ss_outer(0);
                translate([-ss[0]/2-1,0,0]) cylinder(d=2, h= wall_height,$fn=8);
            }
        }
    }
//    hull()
//    {
//        translate([-8,illumination_clip_y+3,0])
//        cylinder(d=2, h=wall_height,$fn=8);
//        
//        translate([-ss[0]/2-1,0,0]) cylinder(d=2, h=2*wall_height,$fn=8);
//    }
    
//	translate([0,z_nut_y,0]){
//        screw_seat(travel=z_actuator_travel, motor_lugs=motor_lugs);
//    }
	////////////// clip for illumination/back foot ///////////////////
	//translate([0,illumination_clip_y,0]) mirror([0,1,0]) dovetail_m([12,2,12]);
    difference(){
        translate([-8,illumination_clip_y-16,0]) cube([16,22,wall_height+2]);
        translate([0,0,wall_height+3]) rotate([90,0,0]) cylinder(r=3,h=999,center=true);
    }
}

//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
