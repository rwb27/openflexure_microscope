/*

An adapter to fit the OpenFlexure Microscope optics module on the
fibre alignment stage

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
use <dovetail.scad>;
include <parameters.scad>;

beam_height = platform_z + 3 + 10 + 6;

module optics_to_platform(){
    h=25;
    keel = [3-0.3,1,h];
    translate([0,10+3,0]) mirror([0,1,0]) dovetail_clip([14,10,h],solid_bottom=0.5,slope_front=3);
    translate([-16,0,0]) cube([32,3+d,h]);
    translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
}

module slide_holder(){
    h = beam_height - shelf_z2 - stage[2] + 5;
    w = 20;
    so = fixed_platform_standoff;
    difference(){
        union(){
            translate([-w/2,-so+2,0]) cube([w,4,h]);
            translate([-w/2,-so+2,0]) cube([w,so-2 + 2 + 4,4]);
        }
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(d=3.5,h=20,$fn=16, center=true);
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(r=3.2,h=10,$fn=16);
        translate([0,0,beam_height - shelf_z2 - stage[2]]) rotate([90,0,0]) cylinder(d=3.2,h=999,center=true,$fn=16);
    }
}
slide_holder();