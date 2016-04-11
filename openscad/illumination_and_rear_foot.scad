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
clip_w = 16; //external width of clip for dovetail
//clip_y is no longer correct - need to take the value from main_body.scad
//clip_y and sample_z are defined below
clip_h = 12; //height of dovetail clip
bottom = -15; //the foot extends below the bottom of the dovetail

//the dovetail should sit at ([0,-leg_r-2,sample_z+5])
//the LED should sit at ([0,0,sample_z+30])
led_z = 12;
dt_h = 13;
below_led = 6;
led_r = 3/2*1.1;
led_angle = 20;
working_distance = clip_h;

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

module back_foot_and_illumination(clip_y=-35,sample_z=40){
    // Arm that clips on to the microscope, providing the back foot
    // and illumination mount
    w = clip_w; //width (size in x direction)
    b = 8; //breadth (size of main pillar in y direction)
    back = clip_y-b-1; //y coordinate of back of pillar
    wd = working_distance;
    arm_h = b;
    arm_w = b;
    difference(){
        union(){
            sequential_hull(){
                translate([0,back,bottom+1]) rotate([-90,0,0])cylinder(r=1,h=2); //foot
                //translate([-w/2,back,-1]) cube([w,b+4,1]); //height stop
                translate([-w/2,back,-1]) cube([w,b,d]); //dovetail mounts here
                translate([-w/2,back,clip_h]) cube([w,b,d]);//dovetail
                translate([-w/2,back,clip_h]) cube([w,b+2.5,1]);//height stop
                translate([-w/2,back,clip_h]) cube([w,b,2]);//main shaft
                translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w,b*sqrt(2),d],center=true);//main shaft (top)
                translate([-arm_w/2,-6-4,sample_z+wd+4]) cube([arm_w,d,arm_h]);
                translate([0,0,sample_z+wd]) cylinder(r=6,h=arm_h+4,$fn=32);
            }
            translate([0,clip_y,clip_h]) mirror([0,0,1]) dovetail_m([clip_w,3,clip_h],r=0.1,top_taper=2);
        }
        
        // make the structure hollow, for faster printing and 
        // cable management
        sequential_hull(){
            translate([0,back+1,bottom+1]) rotate([-90,0,0]) cylinder(r=d,h=d); //foot
            //translate([-w/2+1,back+1,-1]) cube([w-2,b+2-0.5,d]); //height stop
            translate([-w/2+1,back+1,-1]) cube([w-2,b-2,d]); //dovetail mounts here
            translate([-w/2+1,back+1,clip_h]) cube([w-2,b-2,2]);//main shaft
            translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w-2,(b-2)*sqrt(2),2*d],center=true);//main shaft (top)
            translate([-3,-8,sample_z+wd+4+4]) cube([6,d,3]);
            translate([-3,-8,sample_z+wd+4+4]) cube([6,8,10]);
            translate([0,0,sample_z+wd+4+4]) cylinder(r=3,h=999);
        }
        // exit holes for cable (option to leave from front or back)
        hull(){
            b=bottom+2; // -height of the triangular void inside the foot
            translate([0,0,-1]) cube([w-2,999,d],center=true);
            translate([0,0,-1+b/2])cube([(w-2)/2,999,d],center=true);
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
    //rotate([90,0,0]) back_foot_and_illumination(clip_y=-33.0416, sample_z=40);
    // large stage version
    rotate([90,0,0]) back_foot_and_illumination(clip_y=-36.5772, sample_z=65);
    //rotate([0,90,0]) cylinder(r=999,h=999,$fn=8);
}