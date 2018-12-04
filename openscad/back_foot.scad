/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Back foot (in case you are not using    *
* the microscope stand).                                          *
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
bottom = -foot_height; //the foot extends below the bottom of the dovetail
  //currently this is also defined in nut_seat_with_flex.scad, should
  //move them both to microscope_parameters really!

led_d = 5; // LED diameter in mm if you want a bigger LED
led_angle = 22; //cone angle for LED beam
working_distance = clip_h + 0; //wd should be >= clip_h so it fits on nicely...
                //working_distance is the distance from condenser to stage
condenser=false;

stage_clearance=6;
shift=[0,0,0];
w = clip_w; //width (size in x direction)
b = 8; //breadth (size of main pillar in y direction)
back = illumination_clip_y-b-stage_clearance; //y coordinate of back of pillar
wd = working_distance; //distance from bottom of "condenser" to sample
arm_h = b; //height of the horizontal arm (cross-sectional size in z)
arm_w = b; //width of the arm (cross-sectional size in x)
t = 1; //thickness of shell
clip_t = 2; //thickness of arms for the dovetail clip
hole_h = max(stage_clearance, b); //height of cut-out above clip
dt_taper = 2; //size of sloping part at top/bottom of dovetail

module back_foot(clip_y=illumination_clip_y,stage_clearance=6,sample_z=sample_z){
    // Arm that clips on to the microscope, providing the back foot
    // and illumination mount
    w = clip_w; //width (size in x direction)
    difference(){
        $fn=32;
        union(){
            sequential_hull(){
                translate([0,back,bottom+clip_t]) rotate([-90,0,0])cylinder(r=clip_t,h=2); //foot
                union(){ //platform for mounting screw
                    translate([-w/2,back,-dt_taper]) cube([w,b,dt_taper]);
                    //translate([0,illumination_clip_y+3,-dt_taper]) cylinder(d=w, h=dt_taper);
                }
                translate([-w/2,back,-dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+hole_h]) cube([w,b,d]); //start of main shaft
            }
            translate([0,illumination_clip_y,0]) rotate([-90,180,0]) dovetail_clip_y([clip_w,clip_h,2+d],t=clip_t,taper=dt_taper,endstop=true);
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
        }
        // entry hole for an M3 screw to mount it to a box
        translate([0,back+t+3/2,clip_h/2]) rotate([90,0,0]) cylinder(d=3.5,h=999, center=true);
    }
    // nut trap for mounting to box (see entry hole above)
    translate([0,back+t+3/2,clip_h/2]) difference(){
        union(){ //thicken the back to hold the nut trap
            cube([w,4,6],center=true);
            translate([0,-1,3]) cube([w,2,8],center=true);
        }
        //cut-out for the nut:
        hull() repeat([0,0,10],2) rotate([90,30,0]) cylinder(r=3*1.3,h=3,center=true, $fn=6);
        cube([2*3*1.3*cos(30),999,3.5],center=true); //screw clearance
    }
}

module print_ready_parts(){
    // make a nice, compact assembly of all the parts, sitting on z=0
    translate([0,0,-back]) rotate([90,0,0]) back_foot();
}

module parts_in_situ(){
    // generate all the parts as they would appear in the microscope.
    back_foot();
}

print_ready_parts();
//parts_in_situ();