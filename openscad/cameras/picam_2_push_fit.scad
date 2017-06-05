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
function camera_sensor_height() = 2; //Height of the sensor above the PCB


module picam2_push_fit( beam_length=15){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // It includes cut-outs for the components on the PCB and also a push-fit hole
    // for the camera module.  This uses flexible "fingers" to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.  You may find popping 
    // off the brown ribbon cable and removing the PCB first helps when extracting
    // the camera module again.
    camera = [8.5,8.5,2.8]; //size of camera box (NB it's now propped up on foam)
	cw = camera[0]+1; //side length of camera box at bottom (slightly larger)
	finger_w = 1.5; //width of flexure "fingers"
	flex_l = 1; //width of flexible part
    hole_r = camera[0]/2-0.4;
	union(){
		//cut-out for camera
        hull(){
            translate([0,0,-d]) cube([cw+0.5,cw+0.5,d],center=true); //hole for camera
            translate([0,0,1]) cube([cw-0.5,cw-0.5,d],center=true); //hole for camera
        }
        rotate(180/16) cylinder(r=hole_r,h=beam_length,center=true,$fn=16); //hole for light
        
        //looser cut-out for camera, with gripping "fingers" on 3 sides
        difference(){
            //cut-out big enough to include gripping fingers
            intersection(){
                hull(){
                    translate([0,-(finger_w+flex_l)/2,0.5+d])
                        cube([cw+2*finger_w+2*flex_l, cw+finger_w+flex_l, 2*d],center=true);
                    translate([0,0,0.5+3*(finger_w+flex_l)]) cube([cw, cw, d],center=true);
                }
                //fill in the corners of the void first, to give an endstop for the camera
                union(){
                    cube([999,999,(camera[2]+0.5)*2],center=true);
                    rotate(45) cube([1,1,999]*(cw+2*finger_w+2*flex_l)/sqrt(2), center=true);
                }
                //build up the roof gradually so we get a nice hole
                rotate(90) translate([0,0,camera[2]+1.0]) 
                    hole_from_bottom(r=hole_r,h=beam_length - camera[2]-1.5);
            }
                
            //gripping "fingers" (NB we subtract these from the cut-out)
            for(a=[90:90:270]) rotate(a) hull(){
                translate([-cw/2+0.5,cw/2,0]) cube([cw-1,finger_w,d]);
                translate([-cw/2+1,camera[0]/2-0.1,camera[2]]) cube([cw-2,finger_w,d]);
            }
            //there's no finger on the top, so add a dimple on the fourth side
            hull(){
                translate([-cw/2+1,cw/2,4.3/2]) cube([cw-2,d,camera[2]-1.5]);
                translate([-cw/2+2,camera[1]/2,camera[2]-0.5]) cube([cw-4,d,0.5]);
                translate([-21/2,cw/2,camera[2]-1.5]) cube([21,d,camera[2]-1.5]);
                translate([-21/2,camera[1]/2,camera[2]-0.5]) cube([21,d,0.5]);
            }
		}
        
		//ribbon cable at top of camera
        sequential_hull(){
            translate([0,0,0]) cube([cw-1,d,4.3],center=true);
            translate([0,cw/2+1,0]) cube([cw-1,d,5],center=true);
            translate([0,9.4-(4.4/1)/2,0]) cube([cw-1,1,5],center=true);
        }
        //flex connector
        translate([-1.25,9.4,0]) cube([cw-1+2.5, 4.4+1, 5],center=true);
        
		//screw holes for safety (M2 "threaded")
		reflect([1,0,0]) translate([21/2,0,0]){
            cylinder(r1=2.5, r2=1, h=2, center=true, $fn=8);
            cylinder(r=1, h=7, $fn=8);
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

function camera_mount_height() = 4.5;
bottom = camera_mount_height() * -1;

module camera_mount(){
    // A mount for the pi camera v2
    // This should finish at z=0+d, with a surface that can be
    // hull-ed onto the lens assembly.
    h = 24;
    w = 25;
    rotate(45) difference(){
        translate([0,2.4,0]) sequential_hull(){
            translate([0,0,bottom]) cube([w,h,d],center=true);
            translate([0,0,bottom+1.5]) cube([w,h,d],center=true);
            translate([0,0,0]) cube([w-(-1.5-bottom)*2,h,d],center=true);
        }
        translate([0,0,bottom]) picam2_push_fit();
    }
}
camera_mount();

/////////// Cover for camera board //////////////
module picam_cover(){
    // A cover for the camera PCB, slips over the bottom of the camera
    // mount.  This version should be compatible with v1 and v2 of the board
    start_y=-12+2.4;//-3.25;
    l=-start_y+12+2.4; //we start just after the socket and finish at 
    //the end of the board - this is that distance!
    difference(){
        union(){
            //base
            translate([-15,start_y,-4.3]) cube([25+5,l,4.3+d]);
            //grippers
            reflect([1,0,0]) translate([-15,start_y,0]){
                cube([2,l,4.5-d]);
                hull(){
                    translate([0,0,1.5]) cube([2,l,3]);
                    translate([0,0,4]) cube([2+2.5,l,0.5]);
                }
            }
        }
        translate([0,0,-1]) picam2_pcb_bottom();
        //chamfer the connector edge for ease of access
        translate([-999,start_y,0]) rotate([-135,0,0]) cube([9999,999,999]);
    }
} 

