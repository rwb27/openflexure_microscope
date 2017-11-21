/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Riser to mount sample slightly higher   *
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
include <microscope_parameters.scad>;

sep = 26;
$fn=24;

slide = [75.8,25.8,1.0];
h = 10;
size = slide + [1,1,0]*8*2 + [0,0,h+1];
clip_pivot = [20,size[1]/2+1,0];

module slide_riser(){
    difference(){
        union(){
            translate([-size[0],-size[1],0]/2) cube(size);
            hull(){
                translate(clip_pivot) cylinder(r=5,h=h);
                translate([clip_pivot[0],0,0]) cylinder(r=5,h=h);
            }
        }
        
        //cut-out for slide
        hull() translate([-999/2,-slide[1]/2,h]){
            translate(-[1,1,0]*slide[2]/2) cube([999,999,d]);
            translate([1,1,2]*999+[0,0,slide[2]]) cube([999,999,d]);
        }
        
        //cut-out for middle of slide (immersion oil, etc.)
        translate([-999/2,-slide[1]/2+2, h-2]) cube([999,slide[1]-4,999]);
        
        //mounting holes
        reflect([1,0,0]) reflect([0,1,0]) rotate(-45) translate([leg_middle_w/2,leg_r-zflex_l-4,2]){
            cylinder(r=3/2*1.15,h=999,center=true); //mounting holes
            cylinder(r=3*1.15,h=999); //mounting holes
        }
        
        //central hole
        cylinder(r=hole_r,h=999,center=true, $fn=32);
        
        //mounting for clip
        translate(clip_pivot + [0,0,h-2]) cylinder(r=4,h=999);
        translate(clip_pivot + [0,0,0.5]) cylinder(d=3*0.95,h=999);
        //hole for spring
        translate(clip_pivot + [10,-4,h-5]) rotate([-75,0,0]) cylinder(d=4.5,h=999);
        
        //mounting holes at the side
        //translate([size[0]/2,0,h/2]) repeat([0,8,0], floor(size[1]/8-1), center=true){
        //   rotate([0,90,0]) cylinder(r=3/2*0.95, h=16,center=true);
        //}
        
    } 
       
}

module slide_clip(){
    travel = 3;
    difference(){
        union(){
            //this part contacts the slide
            translate([0,slide[1]/2+1,h]) cylinder(r1=3,r2=5,h=2);
            //this is the arm, incl. spring seat
            translate([0,0,h]) add_hull_base(2){
                translate([0,slide[1]/2+1,0]) cylinder(r=2,h=2);
                translate(clip_pivot + [0,0,0]) cylinder(r=3.7,h=2);
                translate(clip_pivot + [10-1,travel+1.5,0]) cylinder(r=1.5,h=2);
                translate(clip_pivot + [5+1,travel,-8]) cube([8,3,8+2]);
                
                //this stops it rotating too far
                translate(clip_pivot) rotate(15){
                    translate([-5-3,size[1]/2 - clip_pivot[1],-2]) cube([3,3,4]);
                }
            }
            //this is the pivot
            translate(clip_pivot + [0,0,h-2]) cylinder(r=3.7,h=4);
        }
        //hole for pivot screw
        translate(clip_pivot) cylinder(d=3*1.1,h=999,center=true);
        //screw seat
        translate(clip_pivot + [10,travel,h-4]) rotate([75,0,0]) cylinder(d=4.5,h=3,center=true);
    }
}
use <main_body.scad>;

module simple_riser(h=10){
    // Make the stage thicker by height h, to raise up the slide
    // NB you'll need to raise the illumination too!
    difference(){
		hull() each_leg() translate([0,-zflex_l-d,h/2]) cube([leg_middle_w+2*zflex_l,2*d,h],center=true); //hole in the stage
        cylinder(r=hole_r,h=999,center=true);
		each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-zflex_l-4,3.5]){
            cylinder(r=3/2*1.2,h=999, center=true); //mounting holes
            cylinder(r=3*1.2,h=999); //mounting holes
        }
        each_leg() translate([0,-zflex_l-4,0]) cylinder(r=3/2*0.95, h=999, center=true);
	}
}
//simple_riser();
slide_riser();
translate([-25,10,h+2]) translate(clip_pivot) rotate([180,0,22]) translate(-clip_pivot) slide_clip();
//rotate([180,0,0]) 
//slide_clip();