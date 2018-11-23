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

module middle_illumination_arm_screw(){
    for(p=illumination_arm_screws) if(p[0]==0) translate(p) children();
}

module cyl_slot(r=1, h=1, dy=2, center=false){
    hull() repeat([0,dy,0],2,center=true) cylinder(r=r, h=h, center=center);
}

// The mount is shifted WRT the optics module mount, this is the shift:
front_screw_y = illumination_arm_screws[2][1];
illum_dt_dy = front_screw_y - objective_mount_y - 4; // distance to shift the mount in y vs the objective mount

module illumination_arm(){
    // The arm on which we mount the illumination
    bottom_z = illumination_arm_screws[0][2]; // z position where we mount it
    h = 50;
    smooth_h = 15;
    dt_z = sample_z + 12; // z position and height of the dovetail
    dt_h = h + bottom_z - dt_z;
    front_screw_y = illumination_arm_screws[2][1];
    dt_dy = illum_dt_dy;
    overlap=6; // size of contact patch between dovetail and arm
    
    difference(){
        sequential_hull(){
            middle_illumination_arm_screw() scale([1,0.5,1]) cylinder(r=4, h=d);
            hull(){
                each_illumination_arm_screw(middle=false) cyl_slot(r=4, h=4, dy=3);
                translate([0,0,dt_z-bottom_z-4]) middle_illumination_arm_screw() scale([1,0.5,1]) cylinder(r=4, h=d);
            }
            translate([0,dt_dy,dt_z]) optics_mount_base(h=dt_h, overlap=overlap);
        }
        
        // slots for the mounting screws (to allow adjustment of position)
        each_illumination_arm_screw(middle=false) cyl_slot(r=3/2*1.33, h=999, dy=3, center=true);
        each_illumination_arm_screw(middle=false) translate([0,0,3]) cyl_slot(r=6, h=999, dy=3);
        
        // clearance for the motor
        translate([0,-2,0]) z_motor_clearance();
                    
        // cut out the fitting for the condenser arm
        translate([0,dt_dy,0]) objective_fitting_wedge(h=999,nose_shift=-0.25,center=true);
        
        // keyhole slot for mounting
        translate([0,0,dt_z + dt_h - 6]) mirror([0,0,1]){
            keyhole_slot_y(slot=dt_h-12);
            translate([0,objective_mount_back_y+dt_dy,0])  keyhole_slot_y(d1=6.5, d2=6.5, slot=dt_h-12);
        }
    }
    translate([0,dt_dy,dt_z]) optics_mount_rounded_edges(h=dt_h, overlap=overlap);
}
illumination_arm();


module tall_condenser(){
    // parameters of the lens
    pedestal_h = 5.5;
    lens_r = 13/2; // for flanged plastic condenser
    //lens_r = 16/2; // for 16mm plastic condenser
    aperture_r = lens_r-1.1;
    lens_t = 1;
    base_r = lens_r+2;
    // geometry of the condenser
    lens_assembly_z = sample_z + 15;
    led_to_lens = 30;
    
    led_z = lens_assembly_z + led_to_lens;
    dt_dy = illum_dt_dy; // see illumination arm
    
    difference(){
        union(){

            
            // base of the module
            hull(){
                translate([0,0,led_z - 6]) cylinder(r=base_r, h=6+base_r); //mount for LED
                translate([0,0,lens_assembly_z - d]) cylinder(r=base_r, h=d); //mount for lens 
                
                translate([0,dt_dy,lens_assembly_z]) objective_fitting_wedge(h=led_to_lens, nose_shift=0.5);
            }
            
            // holder for the condenser (NB upside down!)
            translate([0,0,lens_assembly_z]) mirror([0,0,1]){
                // the lens holder
                trylinder_gripper(inner_r=lens_r, grip_h=pedestal_h + lens_t/3,h=pedestal_h+lens_t+1.5, base_r=base_r, flare=0.5);
                // pedestal to raise the lens up within the gripper
                cylinder(r=aperture_r+0.8,h=pedestal_h);
            }
        }
        
        // hole for the beam passing through the lens
        translate([0,0,led_z+d]) mirror([0,0,1]) lighttrap_cylinder(r1=led_r+1.5, r2=aperture_r,h=led_to_lens+d);
        translate([0,0,lens_assembly_z+d]) mirror([0,0,1]) cylinder(r=aperture_r,h=999);
        
        // hole for the LED
        //LED
        translate([0,0,led_z]){
            deformable_hole_trylinder(led_r,led_r+0.7,h=20, center=true);
            cylinder(r=led_r+1.0,h=2,center=true);
        }
    }
}

tall_condenser();