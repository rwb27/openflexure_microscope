/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope baseplate                    *
*                                                                 *
* This part fits underneath the microscope - the idea is to       *
* provide a tray to store electronics, etc.                       *
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

module each_actuator(){
    // Repeat this for both of the actuated legs (the ones with levers)
	reflect([1,0,0]) leg_frame(45) children();
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0]){
        screw_seat_cup(h=h-foot_height);
    }
    
    //wall between the cups
    hull() each_actuator() translate([0,actuating_nut_r,0]){
        ss = ss_outer(0);
        translate([ss[0]/2-1,0,0]) cylinder(d=2, h=wall_height,$fn=8);
    }
    
//	translate([0,z_nut_y,0]){
//        screw_seat(travel=z_actuator_travel, motor_lugs=motor_lugs);
//    }
	////////////// clip for illumination/back foot ///////////////////
	//translate([0,illumination_clip_y,0]) mirror([0,1,0]) dovetail_m([12,2,12]);
    difference(){
        translate([-8,illumination_clip_y,0]) cube([16,6,h]);
        translate([0,0,h-5]) rotate([90,0,0]) cylinder(r=2,h=999,center=true);
    }
}

//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
