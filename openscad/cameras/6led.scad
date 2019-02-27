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
use <./m12.scad>;

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

function 6led_camera_sensor_height() = m12_camera_sensor_height(); //Height of the sensor above the PCB


module 6led_lens_mount(){
    m12_lens_mount();
}


function 6led_camera_mount_height()=m12_camera_mount_height();

module 6led_camera_mount(){ //this is the same as the M12 mount
    m12_camera_mount();
}

    
module 6led_bottom_mounting_posts(height=-1, radius=-1, outers=true, cutouts=true){
    //holes are (28-2.25*2)=23.5mm apart in Y and (33-4.45*2)=24.1mm apart in X
    r = radius > 0 ? radius : 2;
    h = height > 0 ? height : 4;
    rotate(45)
    reflect([1,0,0]) reflect([0,1,0]) translate([24.1/2, 23.5/2, 0]) difference(){
        if(outers) cylinder(r=r, h=h, $fn=12);
        if(cutouts) intersection(){
            translate([0,0,-2]) rotate(75) trylinder_selftap(2, h=h+3);
        }
    }
}

//translate([0,0,-1]) picam_pcb_bottom();
