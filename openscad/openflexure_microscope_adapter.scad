/*

An adapter to fit the OpenFlexure Microscope optics module on the
fibre alignment stage

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
use <dovetail.scad>;
include <parameters.scad>;

//beam_height = platform_z + 3 + 10 + 6; //for picamera lens optics
beam_height = platform_z + 12.7; //for compatibility with standard stuff

module optics_to_platform(){
    h=25;
    keel = [3-0.3,1,h];
    translate([0,10+3,0]) mirror([0,1,0]) dovetail_clip([14,10,h],solid_bottom=0.5,slope_front=3);
    translate([-16,0,0]) cube([32,3+d,h]);
    translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
}

module disc_to_platform(){
    h=12;
    id=25.4;
    bh=12.7;//beam height
    ot=4;//optic thickness
    keel = [3-0.3,1,h];
    difference(){
        union(){
            translate([-16,0,0]) cube([32,3+d,h]);
            translate([-keel[0]/2,-keel[1],0]) cube(keel+[0,d,0]);
            difference(){
                hull(){
                    translate([0,bh,0]) cylinder(d=id+3,h=h,$fn=64);
                    translate([-5,bh+id/2,0]) cube([10,10,h]);
                }
                //ground
                translate([0,-999,0]) cube(999*2, center=true);
                
            }
        }
        
        //optic
        difference(){
            translate([0,bh,1]) cylinder(d=id, h=999, $fn=64);
            translate([-999,bh-id/2,1+ot]) rotate([75,0,0]) cube(999*2);
        }
        translate([0,bh,-1]) cylinder(d=id-2, h=ot+1, $fn=64);
        
        //bolt
        translate([0,bh+id/2+5,h/2]) rotate(90) pinch_y(4,t=2, nut_l=999,screw_l=10,extra_height=0,gap=[30,4,999]);
    }
}
//disc_to_platform();

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
//slide_holder();

module inch_disc_holder(){
    h = beam_height - shelf_z2 - stage[2] + 5;
    w = 20;
    so = fixed_platform_standoff;
    id=25.4;
    difference(){
        union(){
            translate([0,-so+2,beam_height - shelf_z2 - stage[2]]) hull(){
                rotate([-90,0,0]) cylinder(d=id+3,h=4,$fn=32);
            }
            translate([-w/2,-so+2,0]) cube([w,4,h]);
            translate([-w/2,-so+2,0]) cube([w,so-2 + 2 + 4,4]);
        }
        reflect([1,0,0]) hull() reflect([0,1,0]) translate([5*sqrt(2),2,1]) cylinder(d=3.5,h=20,$fn=16, center=true);
        translate([0,-so+3,beam_height - shelf_z2 - stage[2]]) rotate([-90,0,0]) cylinder(d=id,h=999,$fn=64);
        translate([0,-so+3,beam_height - shelf_z2 - stage[2]]) rotate([-90,0,0]) cylinder(d=id-2,h=999,center=true,$fn=64);
    }
}
inch_disc_holder();
//difference(){
//    cylinder(d=23,h=8);
//    cylinder(d=10,h=999,center=true);
//}

