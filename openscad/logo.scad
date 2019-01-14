/******************************************************************
*                                                                 *
* OpenFlexure Microscope: WaterScope logo                         *
*                                                                 *
* This file draws the WaterScope logo.                            *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* WaterScope is a company that uses the microscope, and will      *
* hopefully sell it quite soon.                                   *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;

$fn=64;

module waterscope_logo(){
    difference(){
        //eye shape
        intersection(){
            translate([0,13,0]) cylinder(r=30,h=1);
            translate([0,-13,0]) cylinder(r=30,h=1);
        }
        
        //tear-drop shaped pupil
        difference(){
            translate([0,-((12-1)*sqrt(2)+1 - 12)/2,0]) hull(){
                cylinder(r=12,h=999,center=true);
                translate([0,(12-1)*sqrt(2),0])cylinder(r=1,h=999,center=true);
            }
            
            //tick
            translate([2,-11,0]) sequential_hull(){
                translate([-3,3,0]) cylinder(r=1,h=1);
                translate([0,0,0]) cylinder(r=1,h=1);
                translate([6,6,0]) cylinder(r=1,h=1);
            }
        }
    }
}

module oshw_logo(){
    linear_extrude(1) translate([-17.5,-16]) resize([35,0],auto=true) import("oshw_gear.dxf");
}

module openflexure_emblem(h=1, resize=[0,0]){
    linear_extrude(h) import("openflexure_emblem.dxf");
}
module openflexure_logo(h=1, resize=[0,0]){
    // The full logo, including text
    // This is 47 mm tall in Inkscape, and exported using base units=mm
    // We resize it to be about the right size for the microscope
    // The origin is set to x=38 to centre the emblem on x=0
    // I don't understand the Y origin value...
    linear_extrude(h) scale(0.85) import("openflexure_logo.dxf", origin=[38,3]);
}

module oshw_logo_and_text(text=""){
    union(){
        oshw_logo();
        
        translate([100,-7,0]) mirror([1,0,0]) linear_extrude(1){
            text(text, size=14, font="Calibri", halign="left");
        }
    }
}
//openflexure_logo();
//logo_and_name("v5.15.2-LS-M");
//translate([0,-40,0]) oshw_logo();
oshw_logo_and_text("4ah75s");