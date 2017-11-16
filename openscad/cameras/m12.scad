/******************************************************************
*                                                                 *
* OpenFlexure Microscope: USB camera push-fit mount               *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines one useful function, usbcam_push_fit().  It's *
* designed to be subtracted from a solid block, with the bottom   *
* of the block at z=0.  It grips the plastic camera housing with  *
* a "trylinder" gripper, holding it in securely.  It might be     *
* that you need a cover or something to secure the camera fully.  *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>;

// Camera geometry (mostly of the bottom of the lens mount)
lens_holder_tube_r = 13.5/2; // the tube into which the lens screws
lens_holder_tube_h = 12.6; // the height of the tube above the PCB
lens_holder_clearance = 0.35; // extra space around the camera to make sure it fits
lens_holder_box_h = 3.6;
lens_holder_box = [2,2,0] * lens_holder_tube_r + [0,0,1] * lens_holder_box_h; // box at the bottom of the tube
lens_holder_mounting_screw_y = 9; // position of the lugs for mounting screws
lens_holder_mounting_screw_lug_r = 2.2; // size of above.
camera_component_clearance = 1; // it's easiest to have the PCB slightly below the mount

d=0.05; //small distance!
$fn=32;

function m12_camera_sensor_height() = 0.5; //Height of the sensor above the PCB


module usbcam_lens_mount(){
    union(){
        cylinder(r=lens_holder_tube_r, h=lens_holder_tube_h, $fn=16);
        translate([0,0,lens_holder_box_h/2]) cube(lens_holder_box, center=true);
        hull() reflect([0,1,0]) translate([0,lens_holder_mounting_screw_y,0]) 
            cylinder(r=lens_holder_mounting_screw_lug_r, h=lens_holder_box_h, $fn=12);
    }
}


function m12_camera_mount_height()=4;

module m12_camera_mount(){
    h = m12_camera_mount_height();
    sy = lens_holder_mounting_screw_y;
    sr = lens_holder_mounting_screw_lug_r+0.5;
    box_w = 13.2 + 1; //make it slightly fatter so it grips the bed more
    sensor_w = 10 + 0.8; //reasonably tight fit around sensor
    solder_w = (box_w-1.2*2); //the solder terminals need some give
    translate([0,0,-h]) difference(){
        linear_extrude(h+d) difference(){
            union(){
                square(box_w, center=true);
                hull() reflect([0,1]) translate([0,sy]) circle(r=sr, $fn=16);
            }
            //screws
            reflect([0,1]) translate([0,sy]) circle(d=1.5, $fn=16);
            //sensor
            //square(sensor_w, center=true);
        }
        //chamfer the screw holes
        reflect([0,1,0]) translate([0,sy,0]){
            cylinder(r1=3, r2=0,h=4, center=true);
            deformable_hole_trylinder(1.5/2,2.1/2,h=12, center=true);
        }
        // enlarge the cut out for the sensor
        // NB the solder terminals will distort the thin bottom, this
        // is intentional, to help with bed adhesion
        cube([sensor_w, sensor_w, 2],center=true);
        sequential_hull(){
            translate([0,0,0.7]) cube([solder_w,solder_w,d],center=true);
            translate([0,0,0.7+(solder_w-sensor_w)/2]) cube([sensor_w, sensor_w, d],center=true);
            translate([0,0,2]) cube([sensor_w, sensor_w, d],center=true);
            translate([0,0,h+d]) cylinder(r=5,h=d);
        }
    }
}
camera_mount();

//translate([0,0,-1]) picam_pcb_bottom();
