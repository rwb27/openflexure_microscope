/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Logitech C270 screw-on-from-bottm mount *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines one useful function, C270().  It is           *
* designed to be subtracted from a solid block, with the bottom   *
* of the block at z=0.  The screws that are normally used to fix  *
* the lens on to the PCB are used to mount the PCB onto the part. *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <utilities.scad>;



$fn=48;
d=0.05;

module C270(beam_r=5, beam_h=6){
    //cut-out to fit logitech C270 webcam
    //optical axis at (0,0)
    //top of PCB at (0,0,0)
    mounting_hole_x = 8.25;
    mirror([0,0,1]){
        //beam clearance
        hull(){
            cube([8,8,6],center=true);
            translate([0,0,-beam_h])cylinder(r=beam_r,h=2*d,center=true);
        }

        //mounting holes
        reflect([1,0,0]) translate([mounting_hole_x,0,-5]) cylinder(r=0.8*1.2,h=999,$fn=12); 
        
        //clearance for PCB
        translate([0,0,0]){
            hull(){
                translate([-10/2,-13.5,0]) cube([10,d,8]);
                translate([-21.5/2,-4,0]) cube([21.5,41,8]);
                translate([-10/2,45,0]) cube([10,d,8]);
            }
            reflect([0,1,0]) hull(){
                translate([-4.5,6,-1.5]) cube([9,7.5,8]);
                translate([-5.5,6,-1.5]) cube([11,6.5,8]);
            }
            difference(){
                hull(){
                    translate([0,22.5,0+4]) cube([20.5,28,15],center=true);
                    translate([0,34,0+4]) cube([10,9.5*2,15],center=true);
                }
                translate([-4,33.5,-999]) mirror([1,0,0]) cube([999,999,999]);
            }
            translate([-6,41.8,-5]) cylinder(r=0.8*1.2,h=999,$fn=12);
        }
        
        //exit for cable
        translate([4,20,0]) rotate([-90,0,0]) cylinder(r=3,h=99);
    }
}

C270();