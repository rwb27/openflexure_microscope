/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Optics unit                             *
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

t=3;
roc=5;
sample=[

//rotate([0,90,0]) 
difference(){
	union(){
		//anchor to stage
		translate([0,0,2]) cube([6,7,4],center=true);
		translate([0,0,roc+t]) rotate([0,90,0]) difference(){
			cylinder(r=roc+t,h=6,center=true);
			cylinder(r=roc,h=999,center=true);
			translate([0,0,-99]) rotate([0,0,0]) cube([999,999,999]);
			translate([0,0,-99]) rotate([0,0,30]) cube([999,999,999]);
		}
		sequential_hull(){
			translate([0,0,roc+t]+[0,cos(30),sin(30)]*(roc+t/2)) rotate([0,90,0]) cylinder(r=t/2,h=6,center=true);
			translate([0,roc*2.5,t/2]) rotate([0,90,0]) cylinder(r=t/2,h=6,center=true);
			translate([0,roc*2.5+t,t]) rotate([0,90,0]) cylinder(r=t/2,h=6,center=true);
		}
		
	}
	cylinder(r=3/2*1.2,h=999,center=true,$fn=16);
}