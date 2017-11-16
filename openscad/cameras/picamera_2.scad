/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Raspberry Pi Camera v2 push-fit mount   *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file provides two parts for the microscope; the bit that   *
* fits onto the camera (picam2_camera_mount) and a cover that     *
* protects the PCB (picam_cover).  The former is part of the      *
* optics module in optics.scad, and the latter is printed         *
* directly.                                                       *
*                                                                 *
* The fit is set by one main function, picam2_push_fit().  It's   *
* designed to be subtracted from a solid block, with the bottom   *
* of the block at z=0.  It grips the plastic camera housing with  *
* four slightly flexible fingers, which ensures the camera pops   *
* in easily but is held relatively firmly.  Two screw holes are   *
* also provided that should self-tap with M2 or similar screws.   *
* I recommend you use these for extra security if the camera is   *
* likely to be handled a lot.                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>;

d=0.05; //small distance!

function picamera_2_camera_mount_height() = 4.5;
bottom = picamera_2_camera_mount_height() * -1;

function picamera_2_camera_sensor_height() = 2; //Height of the sensor above the PCB

module picam2_cutout( beam_length=15){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // It includes cut-outs for the components on the PCB and also a push-fit hole
    // for the camera module.  This uses flexible "fingers" to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.  You may find popping 
    // off the brown ribbon cable and removing the PCB first helps when extracting
    // the camera module again.
    cw = 8.5 + 1.0; //size of camera box sides (NB deliberately loose fitting)
    ch=2.9; //height of camera box (including foam support)
    camera = [cw,cw,ch]; //size of camera box
    hole_r = 4.3; //size of camera aperture
	union(){
        sequential_hull(){
            //cut-out for camera
            translate([0,0,-d]) cube([cw+0.5,cw+0.5,d],center=true); //wider at bottom
            translate([0,0,0.5]) cube([cw,cw,d],center=true);
            translate([0,0,ch/2]) cube([cw,cw,ch],center=true);
            cylinder(r=hole_r, h=2*picamera_2_camera_mount_height(), center=true);
        }
            
        //ribbon cable at top of camera
        fh=1.5;
        mh = picamera_2_camera_mount_height();
        
        dz = mh-fh-0.75;
        rw = cw - 2*dz;
        hull(){
            translate([-cw/2,cw/2-2,-d]) cube([cw,7,fh]); //flex
            translate([-rw/2,cw/2-2,-d]) cube([rw,7,fh+dz]); //flex
        }
        hull(){
            translate([-cw/2-2.5,6.7,-d]) cube([cw+2.5, 5.4, fh]); //connector
            translate([-rw/2-2.5,6.7,-d]) cube([rw+2.5, 5.4-dz, fh+dz]); //connector
        }
        
        //beam clearance
        cylinder(r=hole_r, h=beam_length);
        
        //chamfered screw holes for mounting
        sx = 21/2; //position of screw holes
        reflect([1,0,0]) translate([sx,0,0]) rotate(60){
            //cylinder(r1=3, r2=0,h=4, center=true); //chamfered bottom
            //deformable_hole_trylinder(1.5/2,2.1/2,h=12, center=true);
            cylinder(r1=3.1, r2=1.1, h=5, $fn=3, center=true);
            cylinder(r=1.1, h=20, $fn=3, center=true);
        }
	}
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

module picamera_2_camera_mount(){
    // A mount for the pi camera v2
    // This should finish at z=0+d, with a surface that can be
    // hull-ed onto the lens assembly.
    b = 24;
    w = 25;
    rotate(45) difference(){
        translate([0,2.4,0]) sequential_hull(){
            translate([0,0,bottom]) cube([w,b,d],center=true);
            translate([0,0,-1]) cube([w,b,d],center=true);
            translate([0,0,0]) cube([w-(-1.5-bottom)*2,b,d],center=true);
        }
        translate([0,0,bottom]) picam2_cutout();
    }
}
difference(){
    //picamera_2_camera_mount();
    //rotate([90,0,0]) cylinder(r=999,h=999,$fn=4);
}

/////////// Cover for camera board //////////////
module picam_cover(){
    // A cover for the camera PCB, slips over the bottom of the camera
    // mount.  This version should be compatible with v1 and v2 of the board
    b = 24;
    w = 25;
    h = 3;
    t = 1; //wall thickness
    centre_y=2.4;
    difference(){
        union(){
            //bottom and sides
            difference(){
                translate([-w/2,-b/2+centre_y,0]) cube([w, b, h]);
                // cut out centre to form walls on 3 sides
                translate([-w/2+t,-b/2+centre_y-t,0.75]) cube([w-2*t, b, h]);
                //chamfer the connector edge for ease of access
                translate([-999,-b/2+centre_y,h]) rotate([-135,0,0]) cube([9999,999,999]);
            }
            //mounting screws
            reflect([1,0,0]) translate([21/2, 0, 0]) cylinder(r=3, h=h, $fn=16);
        }
        //counterbore the mounting screws
        reflect([1,0,0]) translate([21/2, 0, h-1]) rotate(90) intersection(){
           cylinder(r=2, h=999, $fn=16, center=true);
            hole_from_bottom(r=1.1, h=999, base_w=999);
        }
    }
} 
picam_cover();
