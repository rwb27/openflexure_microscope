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
// MAKE SURE THESE MATCH THE VARIABLES IN main_body.scad
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
clip_w = 12; //external width of clip for dovetail
//clip_y is no longer correct - need to take the value from main_body.scad
//clip_y and sample_z are defined below
clip_h = 12; //height of dovetail clip
bottom = -15; //the foot extends below the bottom of the dovetail

//the dovetail should sit at ([0,-leg_r-2,sample_z+5])
//the LED should sit at ([0,0,sample_z+30])
led_z = 12;
dt_h = 13;
below_led = 6;
led_r = 3/2*1.1; //change to 5/2*1.1 if you want a bigger LED
led_angle = 20;
working_distance = clip_h; //wd should be >= clip_h so it fits on nicely...

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


module back_foot_and_illumination(clip_y=-35,stage_clearance=6,sample_z=40){
    // Arm that clips on to the microscope, providing the back foot
    // and illumination mount
    w = clip_w; //width (size in x direction)
    b = 8; //breadth (size of main pillar in y direction)
    back = clip_y-b-stage_clearance; //y coordinate of back of pillar
    wd = working_distance; //distance from bottom of "condenser" to sample
    arm_h = b; //height of the horizontal arm (cross-sectional size in z)
    arm_w = b; //width of the arm (cross-sectional size in x)
    t = 1; //thickness of shell
    clip_t = 2; //thickness of arms for the dovetail clip
    hole_h = max(stage_clearance, b); //height of cut-out above clip
    dt_taper = 2; //size of sloping part at top/bottom of dovetail
    difference(){
        $fn=32;
        union(){
            sequential_hull(){
                translate([0,back,bottom+clip_t]) rotate([-90,0,0])cylinder(r=clip_t,h=2); //foot
                translate([-w/2,back,-dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+hole_h]) cube([w,b,d]); //start of main shaft
                translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w,b*sqrt(2),d],center=true);//top of main shaft
                translate([-arm_w/2,-6-4,sample_z+wd+4]) cube([arm_w,d,arm_h]);
                translate([0,0,sample_z+wd]) cylinder(r=6,h=arm_h+4,$fn=32);
            }
            translate([0,clip_y,0]) rotate([-90,180,0]) dovetail_clip_y([clip_w,clip_h,2+d],t=clip_t,taper=dt_taper,endstop=true);
        }
        
        // make the structure hollow, for faster printing and 
        // cable management
        hw = w - 2*clip_t; // width of hole near dovetail clip
        sequential_hull(){
            //translate([0,back,bottom+clip_t
            translate([-hw/2,back+t,-dt_taper]) cube([hw,b+stage_clearance-2-t+d,d]); //dovetail mounts here
            translate([-hw/2,back+t,clip_h+dt_taper]) cube([hw,b+stage_clearance-2-t+d,d]); //dovetail mounts here
            translate([-hw/2,back+t,clip_h+hole_h]) cube([hw,b-t+d,d]);//top of hole
            translate([-hw/2,back+t,clip_h+hole_h]) cube([hw,b-2*t,d]);//start of bridge over the main shaft
            translate([-w/2+t,back+t,clip_h+hole_h+clip_t-t]) cube([w-2*t,b-2*t,d]);//main shaft starts here
            //translate([0,back+t,clip_h]) rotate([-90,0,0]) cylinder(d=w-2*t,h=b-2*t);
            translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w-2*t,(b-2*t)*sqrt(2),2*d],center=true);//main shaft (top)
            translate([-3,-8,sample_z+wd+4+4]) cube([6,d,3]); //this hole doesn't use thickness - it's set to fit a 2-way header.
            translate([-3,-8,sample_z+wd+4+4]) cube([6,8,10]);
            translate([0,0,sample_z+wd+4+4]) cylinder(r=3,h=999);
        }
        // exit holes for cable (option to leave from front or back)
        difference(){
            hull(){
                translate([0,back+t,-dt_taper]) cube([hw,999,2*d],center=true); //bottom of dovetail mount
                translate([0,back+t,bottom+clip_t]) rotate([-90,0,0]) cylinder(r=d,h=d); //foot
            }
            translate([0,0,bottom*2/3]) mirror([0,0,1]) cylinder(r=999,h=999,$fn=8);
        }
        
        // Holes for LED and beam
        translate([0,0,sample_z+10+8.5]){
            cylinder(r=3*1.1/2,h=999,center=true,$fn=24);
            cylinder(r=4*1.2/2,h=999,$fn=24);
        }
        translate([0,0,sample_z]) cylinder(h=wd+4,r1=(wd+4)*tan(led_angle/2)+3/2,r2=3/2);
    }
}


difference(){
    // standard size
    //rotate([90,0,0]) 
    back_foot_and_illumination(clip_y=-26.0416, sample_z=40);
    // large stage version
    //rotate([90,0,0]) back_foot_and_illumination(clip_y=-36.5772, sample_z=65);
    //rotate([0,90,0]) cylinder(r=999,h=999,$fn=8);
}