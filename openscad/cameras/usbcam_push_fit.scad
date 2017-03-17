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

module usbcam_lens_mount(){
    union(){
        cylinder(r=lens_holder_tube_r, h=lens_holder_tube_h, $fn=16);
        translate([0,0,lens_holder_box_h/2]) cube(lens_holder_box, center=true);
        hull() reflect([0,1,0]) translate([0,lens_holder_mounting_screw_y,0]) 
            cylinder(r=lens_holder_mounting_screw_lug_r, h=lens_holder_box_h, $fn=12);
    }
}

//%usbcam();



module usbcam_push_fit( beam_length=5){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // The PCB should sit slightly below the bottom, and there is a push-fit hole
    // for the camera module.  This uses a distorted cylinder to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.
	translate([0,0,-camera_component_clearance]) union(){
		// cut-out for camera
        minkowski(){
            usbcam_lens_mount();
            cylinder(r=lens_holder_clearance, h=d, center=true, $fn=8);
        }
        minkowski(){ //flare out the bottom to avoid getting a lip
            intersection(){
                translate([0,0,camera_component_clearance]) cube([999,999,d],center=true);
                usbcam_lens_mount();
            }
            cylinder(r1=lens_holder_clearance+0.5, r2=lens_holder_clearance, h=0.5, center=false, $fn=8);
        }
        // make sure the corners don't sag too much
        translate([0,0,lens_holder_box_h]) 
            hole_from_bottom(r=lens_holder_tube_r+lens_holder_clearance-0.1, h=2, big_bottom=false);
        
        //looser cut-out for camera, with gripping "fingers" on 3 sides
        difference(){
            //cut-out big enough to include gripper
            intersection(){
                translate([0,0,lens_holder_box_h + 1]) 
                    cylinder(r=lens_holder_tube_r + lens_holder_clearance + 2, h=999);
                translate([0,0,lens_holder_tube_h + 1]) hole_from_bottom(r=12/2, h=beam_length, 
                                                                       base_w=999, big_bottom=true);
            }
            
            //gripper for lens tube
            trylinder_gripper(inner_r=lens_holder_tube_r,
                              h=lens_holder_tube_h - lens_holder_clearance - 1,
                              grip_h=lens_holder_tube_h - lens_holder_clearance - 2,
                              base_r=lens_holder_tube_r + lens_holder_clearance + 1.2,
                              t=1.2, flare=0, solid=false);
		}
	}
}

//difference(){
//   translate([-12.5,-12+2.4,0]); cube([25,24,15]);
//    usbcam_push_fit();
//}

function camera_mount_height()=4;

module camera_mount(){
    h = camera_mount_height();
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
