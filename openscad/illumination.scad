/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination                            *
*                                                                 *
* The illumination module includes the condenser lens mounts and  *
* the arm that holds them.                                        *
*                                                                 *
* (c) Richard Bowman, April 2018                                  *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;
include <./microscope_parameters.scad>;
use <./dovetail.scad>;
use <./z_axis.scad>;
front_dovetail_y = 35; // position of the main dovetail
front_dovetail_w = 30; // width of the main dovetail


module each_illumination_arm_screw(middle=true){
    // A transform to repeat objects at each mounting point
    for(p=illumination_arm_screws) if(p[0]!=0 || middle) translate(p) children();
}
module right_illumination_arm_screw(){
    // A transform to position objects at the x>0 mounting point
    for(p=illumination_arm_screws) if(p[0]>0) translate(p) children();
}

module middle_illumination_arm_screw(){
    for(p=illumination_arm_screws) if(p[0]==0) translate(p) children();
}

module cyl_slot(r=1, h=1, dy=2, center=false){
    hull() repeat([0,dy,0],2,center=true) cylinder(r=r, h=h, center=center);
}

module illumination_arm(){
    // The arm on which we mount the illumination
    bottom_z = illumination_arm_screws[0][2]; // z position where we mount it
    h = 50;
    smooth_h = 15;
    dt_z = sample_z + 12; // z position and height of the dovetail
    dt_h = h + bottom_z - dt_z;
    
    translate([0,front_dovetail_y,dt_z]) mirror([0,1,0]) dovetail_m([front_dovetail_w, 10, h-smooth_h]);
    
    difference(){
        sequential_hull(){
            translate([-front_dovetail_w/2,front_dovetail_y-2,dt_z]) cube([front_dovetail_w, 15+2, 1]);
            hull(){
                each_illumination_arm_screw(middle=false) cyl_slot(r=4, h=3+d, dy=3);
                middle_illumination_arm_screw() scale([1,0.5,1]) cylinder(r=4, h=d);
            }
            //translate([0,0,dt_z-bottom_z-4]) hull(){
            //    each_illumination_arm_screw(middle=false) cyl_slot(r=4, h=d, dy=3);
            //    middle_illumination_arm_screw() scale([1,0.5,1]) cylinder(r=4, h=d);
            //}
            translate([-front_dovetail_w/2,front_dovetail_y+2,dt_z]) cube([front_dovetail_w, 10-2, dt_h]);
        }
        
        // slots for the mounting screws (to allow adjustment of position)
        each_illumination_arm_screw(middle=false) cyl_slot(r=3/2*1.33, h=999, dy=3, center=true);
        each_illumination_arm_screw(middle=false) translate([0,0,3]) cyl_slot(r=6, h=999, dy=3);
        
        // clearance for the motor
        translate([0,-2,0]) z_motor_clearance();
    }
}
illumination_arm();

// parameters of the lens
pedestal_h = 5.5;
lens_r = 13/2; // for flanged plastic condenser
//lens_r = 16/2; // for 16mm plastic condenser
aperture_r = lens_r-1.1;
lens_t = 1;
base_r = lens_r+2;

lens_assembly_z = 30;
dt_clip = [front_dovetail_w, 16, lens_assembly_z]; //size of the dovetail clip
arm_end_y = front_dovetail_y-dt_clip[1]-4;

module tall_condenser(){
    difference(){
        union(){

            
            // add a bottom
            hull() reflect([1,0,0]){
                translate([0,0,-10]) cylinder(r=base_r, h=lens_assembly_z+d+10);
                translate([-dt_clip[0]/2, arm_end_y,0]) cube([dt_clip[0], 2, lens_assembly_z]);
            }
            
            // mount for the dovetail clip
            translate([-dt_clip[0]/2,arm_end_y,0]) cube([dt_clip[0], 4, dt_clip[2]]);
            
            // the dovetail clip
            translate([0,front_dovetail_y, 0]) mirror([0,1,0]) dovetail_clip(dt_clip, slope_front=2, solid_bottom=0.2);
            
            
            translate([0,0,lens_assembly_z]){
                // the lens holder
                trylinder_gripper(inner_r=lens_r, grip_h=pedestal_h + lens_t/3,h=pedestal_h+lens_t+1.5, base_r=base_r, flare=0.5);
                // pedestal to raise the lens up within the gripper
                cylinder(r=aperture_r+0.8,h=pedestal_h);
            }
        }
        
        // hole for the beam passing through the lens
        translate([0,0,9]) lighttrap_cylinder(r1=led_r+1.5, r2=aperture_r,h=lens_assembly_z-9+d);
        translate([0,0,lens_assembly_z]) cylinder(r=aperture_r,h=999);
        
        // hole for the LED
        //LED
        deformable_hole_trylinder(led_r,led_r+0.7,h=20, center=true);
        cylinder(r=led_r+1.0,h=2,center=true);
        translate([0,0,2-d]) cylinder(r1=led_r+1.0, r2=led_r,h=2,center=true);
    }
}

//tall_condenser();