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

sep = 26;
$fn=24;

difference(){
    hull(){
        reflect([1,0,0]) translate([sep/2,0,0]) cylinder(r=4,h=6);
    }
    reflect([1,0,0]) translate([sep/2,0,1]){
       cylinder(r=3/2*1.15,999,center=true);
       cylinder(r=3*1.15,h=999);
    }
} 
    