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
lens_holder_tube_r = 13/2; // the tube into which the lens screws
lens_holder_tube_h = 12; // the height of the tube above the PCB
lens_holder_clearance = 0.5; // extra space around the camera to make sure it fits
lens_holder_box_h = 4;
lens_holder_box = [2,2,0] * lens_holder_tube_r + [0,0,1] * lens_holder_box_h; // box at the bottom of the tube
lens_holder_mounting_screw_y = 8; // position of the lugs for mounting screws
lens_holder_mounting_screw_lug_r = 2; // size of above.
camera_component_clearance = 2; // it's easiest to have the PCB slightly below the mount

d=0.05; //small distance!
$fn=32;

module usbcam(){
    translate([0,0,-camera_component_clearance]) union(){
        cylinder(r=lens_holder_tube_r, h=lens_holder_tube_h, $fn=16);
        translate([0,0,lens_holder_box_h/2]) cube(lens_holder_box, center=true);
        hull() reflect([0,1,0]) translate([0,lens_holder_mounting_screw_y,0]) 
            cylinder(r=lens_holder_mounting_screw_lug_r, h=lens_holder_box_h, $fn=12);
    }
}

%usbcam();



module usbcam_push_fit( beam_length=15){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // The PCB should sit slightly below the bottom, and there is a push-fit hole
    // for the camera module.  This uses a distorted cylinder to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.
	translate([0,0,-camera_component_clearance]) union(){
		//cut-out for camera
        minkowski(){
            usbcam();
            cylinder(r=lens_holder_clearance, h=d, center=true, $fn=8);
        }
        rotate(180/16) cylinder(r=hole_r,h=beam_length,center=true,$fn=16); //hole for light
        
        //looser cut-out for camera, with gripping "fingers" on 3 sides
        difference(){
            //cut-out big enough to include gripper
            translate([0,0,lens_holder_box_h + 1]) cylinder(r=lens_holder_tube_r + lens_holder_clearance + 2, h=lens_holder_tube_h-lens_holder_box_h);
            
            //gripper for lens tube
            trylinder_gripper(inner_r=lens_holder_tube_r,
                              h=lens_holder_tube_h - lens_holder_clearance - 1,
                              grip_h=lens_holder_tube_h - lens_holder_clearance - 2,
                              base_r=lens_holder_tube_r + lens_holder_clearance,
                              t=1.2, flare=0, solid=false);
		}
	}
}

difference(){
   translate([-12.5,-12+2.4,0]); cube([25,24,15]);
    usbcam_push_fit();
}

module picam2_pcb_bottom(){
    // This is an approximate model of the pi camera PCB for the purposes of making
    // a slide-on cover.  NB z=0 is the bottom of the PCB, which is nominally 1mm thick.
    pcb = [25+0.5,24+0.5,1+0.3];
    socket = [pcb[0],6.0+0.5,2.7];
    components = [pcb[0]-1*2, pcb[1]-1-socket[1], 2];
    translate([0,2.4,0]) union(){ //NB the camera bit isn't centred!
        translate([0,0,pcb[2]/2]) cube(pcb,center=true); //the PCB
        translate([-components[0]/2,-pcb[1]/2+socket[1],-components[2]+d]) cube(components); //the little components
        //the ribbon cable socket
        translate([-socket[0]/2,-pcb[1]/2,-socket[2]+d]) cube(socket); //the ribbon cable socket
        translate([-components[0]/2,-pcb[1]/2,-0.5]) cube([components[0],socket[1]+0.5,0.5+d]); //pins protrude slightly further
        
        //mounting screws (NB could be extruded in -y so the cover can slide on)
        reflect([1,0,0]) mirror([0,0,1]) translate([21/2,-2.4,-d]){
            cylinder(r=2.5,h=10);
            cylinder(r=1.5,h=15,center=true); //screw might poke through the top...
        }
    }
}
//translate([0,0,-1]) picam_pcb_bottom();
