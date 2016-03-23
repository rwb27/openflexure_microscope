/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination arm                        *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
use <dovetail.scad>;
$fn=16;
d=0.05;

big_stage = true;

sample_z = big_stage?60:40; //height of the top of the stage
leg_r = big_stage?30:25;
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
clip_w = 16; //external width of clip for dovetail
clip_y = -leg_r-8; //position of clip relative to optical axis
clip_h = 12; //height of dovetail clip
bottom = -15; //the foot extends below the bottom of the dovetail

//the dovetail should sit at ([0,-leg_r-2,sample_z+5])
//the LED should sit at ([0,0,sample_z+30])
led_z = 12;
dt_h = 13;
below_led = 6;
led_r = 3/2*1.1;
led_angle = 20;

/*
intersection(){
	cylinder(r=999,h=999,$fn=8);
//rotate([atan(25/(leg_r+3)),0,0])
	translate([0,0,-led_z+below_led]) //rotate([atan((25+3-14)/(leg_r)),180,0])
    rotate(atan((led_z-below_led-5)/(leg_r+2)),[1,0,0])
    difference(){
		union(){
			translate([0,leg_r+2,5]) dovetail_m([clip_w,2,dt_h]);
			hull(){
				translate([-clip_w/2,leg_r+d,5]) cube([clip_w,d,dt_h]);
				translate([0,0,led_z-below_led]) cylinder(r=4,h=below_led+1);
			}
		}
		#translate([0,0,led_z-4]) cylinder(r=led_r,h=5);
		translate([0,0,led_z]) cylinder(r=led_r+1,h=999);
		translate([0,0,led_z-30-2]) cylinder(r1=led_r+30*tan(led_angle),r2=led_r,h=30);
	}
}*/

module back_foot_and_illumination(){
    // Arm that clips on to the microscope, providing the back foot
    // and illumination mount
    w = clip_w;
    b = 8; //breadth (size of main pillar in y direction)
    back = clip_y-b;
    difference(){
            union(){
            sequential_hull(){
                translate([0,back,bottom+1]) cylinder(r=1,h=1); //foot
                translate([-w/2,back,-1]) cube([w,b+4,1]); //height stop
                translate([-w/2,back,0]) cube([w,b-1,d]); //dovetail mounts here
                translate([-w/2,back,clip_h]) cube([w,b-1,d]);
                translate([-w/2,back,clip_h+1]) cube([w,b,d]); //main shaft
                translate([-8/2,back,sample_z+3]) cube([8,b,
            }
        }
    }
}

back_foot_and_illumination();