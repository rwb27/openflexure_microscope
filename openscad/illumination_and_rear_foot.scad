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
include <microscope_parameters.scad>;

// geometry is now defined by microscope_parameters.scad

clip_w = 12; //external width of clip for dovetail
clip_h = 12; //height of dovetail clip
bottom = -15; //the foot extends below the bottom of the dovetail
  //currently this is also defined in nut_seat_with_flex.scad, should
  //move them both to microscope_parameters really!

led_r = 3/2*1.1; //change to 5/2*1.1 if you want a bigger LED
led_angle = 20; //cone angle for LED beam
working_distance = clip_h; //wd should be >= clip_h so it fits on nicely...
                //working_distance is the distance from condenser to stage

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
            translate([-3,-12,sample_z+wd+4+4]) cube([6,d,3]); //this hole doesn't use thickness - it's set to fit a 2-way header.  This is the end of the channel, at the opening where the LED sits.
            translate([-3,-12,sample_z+wd+4+4]) cube([6,12,10]);
            translate([0,0,sample_z+wd+4+4]) cylinder(r=2.5,h=999);
        }
        // enlarge the channel a bit next to the LED to allow it to be put in LED-first
        sequential_hull(){
            translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w-2*t,(b-2*t)*sqrt(2),2*d],center=true);//main shaft (top) //NB this line should match the similar line above
            translate([0,-12,sample_z+wd+4+4])  rotate([90,0,0]) cylinder(r=2.5, h=d);
            translate([-3,-4,sample_z+wd+4+4]) cube([6,d,10]);
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
    rotate([90,0,0]) 
    back_foot_and_illumination(clip_y=illumination_clip_y, sample_z=sample_z);
    // large stage version
    //rotate([90,0,0]) back_foot_and_illumination(clip_y=-36.5772, sample_z=65);
    //rotate([0,90,0]) cylinder(r=999,h=999,$fn=8);
}