/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Lens spacer                             *
*                                                                 *
* This is an alternative optics module (optics.scad) that is to   *
* be used together with the camera platform, to make a cheap      *
* optics module that uses the webcam lens.  New in this version   *
* is compatibility with the taller stage (because the sensor is   *
* no longer required to sit below the microscope body).           *
*                                                                 *
* (c) Richard Bowman, November 2018                               *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
use <z_axis.scad>;
include <microscope_parameters.scad>; // NB this defines "camera" and "optics"

use <cameras/camera.scad>; // this will define the 2 functions and 1 module for the camera mount, using the camera defined in the "camera" parameter.

$fn=24;

camera_mount_top = 0;

module optical_path(lens_aperture_r, lens_z, bottom_z=camera_mount_top){
    // The cut-out part of a camera mount, consisting of
    // a feathered cylindrical beam path.  Camera mount is now cut out
    // of the camera mount body already.
    union(){
        translate([0,0,bottom_z-d]) lighttrap_cylinder(r1=5, r2=lens_aperture_r, h=lens_z-bottom_z+2*d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_aperture_r,h=2*d); //lens
    }
}
    
module lens_gripper(lens_r=10,h=6,lens_h=3.5,base_r=-1,t=0.65,solid=false, flare=0.4){
    // This creates a tapering, distorted hollow cylinder suitable for
    // gripping a small cylindrical (or spherical) object
    // The gripping occurs lens_h above the base, and it flares out
    // again both above and below this.
    trylinder_gripper(inner_r=lens_r, h=h, grip_h=lens_h, base_r=base_r, t=t, solid=solid, flare=flare);
}

  
module camera_mount_top(){
    // A thin slice of the top of the camera mount
    linear_extrude(d) projection(cut=true) camera_mount();
}

module lens_extension(
        bottom_z=37, //z position of board
        lens_r = 3,
        parfocal_distance = 6,
        lens = 2.5
    ){
    // Mount a lens some distance from the camera
    // NB currently this only works for the pi camera
    cmh = camera_mount_height();
        
    // This optics module grips a single lens at the top.
    lens_aperture = lens_r - 1.5; // clear aperture of the lens
    pedestal_h = 4; // extra height on the gripper, to allow it to flex
    lens_z = sample_z - parfocal_distance; //axial position of lens
        
    // having calculated where the lens should go, now make the mount:
    lens_assembly_z = lens_z - pedestal_h; //height of lens assembly
    lens_assembly_base_r = lens_r+1; //outer size of the lens grippers
    lens_assembly_h = lens_h + pedestal_h; //the
                                            //lens sits parfocal_distance below the sample
    difference(){
        union(){
            // This is the main body of the mount
            sequential_hull(){
                translate([0,0,bottom_z + cmh]) camera_mount_top();
                translate([0,0,bottom_z + cmh+5]) cylinder(r=6,h=d);
                translate([0,0,lens_assembly_z]) 
                    cylinder(r=lens_assembly_base_r, h=d);
            }
            // A lens gripper to hold the objective
            translate([0,0,lens_assembly_z]){
                // gripper
                trylinder_gripper(inner_r=lens_r, grip_h=lens_assembly_h-1.5,h=lens_assembly_h, base_r=lens_assembly_base_r, flare=0.4, squeeze=lens_r*0.15);
                // pedestal to raise the tube lens up within the gripper
                difference(){
                    cylinder(r=lens_aperture + 1.0,h=pedestal_h);
                    cylinder(r=lens_aperture,h=999,center=true);
                }
            }
                
                
            // add the camera mount
            translate([0,0,bottom_z + cmh]) camera_mount(counterbore=true);
        
        }
        // cut out the optical path
        optical_path(lens_aperture, lens_assembly_z, bottom_z);
    }
}



//optics="beamsplitter_led_mount";
//optics="rms_f50d13";
//camera="picamera2";
difference(){
    if(optics=="pilens"){
        // Optics module for picamera v2 lens, using trylinder
        lens_extension(
            lens_r = 3, 
            parfocal_distance = 6,
            lens_h = 2.5,
            bottom_z = z_flexures_z2 + 4 + 1
        );
    }else if(optics=="c270_lens"){
        // Optics module for logitech C270 lens
        lens_extension(
            lens_r = 6,
            parfocal_distance = 6, //NB with 6 here the PCB is a bit low
            lens_h = 2
        );
    }else if(optics=="rms_f40d16"){
        echo("Warning: RMS objectives won't fit when using the lens spacer/camera platform");
    }else if(optics=="m12_lens"){
        // Optics module for USB camera's M12 lens
        lens_extension(
            lens_r = 14/2,
            parfocal_distance = 21, //22 for high-res lens
            lens_h = 5.5
        );
    }
    
}
