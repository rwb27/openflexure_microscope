/*

An attempt at an alternative to my ageing "nut_seat_with_flex" design...

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
include <parameters.scad>;

d = 0.05;
nut_size = 3;
nut_vr = nut_size*1.2; //nominal radius of nut for an easy fit
nut_sr = nut_size*1.05; //radius of nut for a very tight fit
nut_h = 3; //height of nut insertion slot
nut_sh = 6; //height of nut trap; this should make the nut disappear.
shaft_r = nut_size/2 * 1.2; //radius of hole to cut for screw

module nut_void_with_side_entry_and_jamming_top(r, h, squeeze_r, squeeze_h, hole_d=-1){
    // A cut-out that will hold a nut.  The nut slots in horizontally
    // along the +y axis, and is pulled up and into the tight part of the
    // nut seat when a screw is inserted.
    hole_r = hole_d>0 ? hole_d/2 : squeeze_r/2*1.1;
    w = 2*r*cos(30);
    sequential_hull(){
        translate([-w/2,999,0]) cube([w,d,h]);
        union(){
            rotate(30) cylinder(r=r, h=h, $fn=6);
            translate([-w/2,0,0]) cube([w,r,h]);
        }
        a = r/2 / (squeeze_h - h);
        rotate(30) cylinder(r=r*(1-a) + squeeze_r*a, h=h+r/2, $fn=6);
        rotate(30) cylinder(r=squeeze_r, h=squeeze_h, $fn=6);
    }
    // ensure the hole in the top can be made nicely
    intersection(){
        translate([-999, -hole_r,0]) cube([9999, 2*hole_r, squeeze_h + 0.5]);
        rotate(30) cylinder(r=squeeze_r, h=999, $fn=6);
    }
        
}

//nut_void_with_side_entry_and_jamming_top(3.5,3, 2.95, 6.5);

module actuator_column(h, tilt=0, lever_tip = 3){
    r1 = shaft_r+2;
    nut_bottom = h - nut_sh - 1.5;
    r2 = nut_vr + 1.5;
    max_r2 = r2*sqrt(1 + cos(30)*cos(30));
    $fn=16;
    difference(){
        union(){
            rotate([tilt,0,0]) sequential_hull(){
                translate([0,0,-99]) cylinder(r=r1, h=d);
                translate([0,0,nut_bottom - (max_r2-r1)]) cylinder(r=r1, h=d);
                translate([0,0,nut_bottom]) union(){
                    rotate(30) cylinder(r=r2, h=h-nut_bottom, $fn=6);
                    translate([-r2*cos(30),0,0]) cube([r2*cos(30)*2,r2,h-nut_bottom]);
                }
            }
        }
        
        // nut trap
        rotate([tilt,0,0]) translate([0,0,nut_bottom]) nut_void_with_side_entry_and_jamming_top(nut_vr, nut_h, nut_sr, nut_sh, shaft_r);
        
        // shaft for the screw
        // NB this is raised up from the bottom so it stays within the shaft - this may need to change depending on the length of screw we use...
        rotate([tilt,0,0]) translate([0,0,lever_tip + shaft_r]) cylinder(r=shaft_r, h=999);
        
        // space for lever and flexure
        translate([-99, -99, -999]) sequential_hull(){
            cube([999,999,999]);
            cube([999,99+zflex[1]/2,999]);
            cube([999,99+zflex[1]/2,999+lever_tip]);
            cube([999,99+zflex[1]/2-99,999+lever_tip+99]);
        }
    }
}

//actuator_column(25, -10);

module tilted_actuator(pivot_z, pivot_w, lever, base_w = 10){
    // A lever with its pivot wide and high, actuated by the above actuator
    pw = pivot_w;
    pz = pivot_z;
    nut_y = zflex[1] + sqrt(lever*lever - pivot_z*pivot_z);
    tip_h = 3;
    difference(){
        reflect([1,0,0]){
            // pivot flexures
            translate([-pw/2, -d, pz]) cube(zflex + [0,2*d,0]);
            // arms linking flexures to actuator column
            sequential_hull(){
                translate([-pw/2, zflex[1], pz]) cube(zflex);
                translate([-base_w/2, zflex[1], 0]) cube([base_w, nut_y - 12, 5]);
                translate([0, nut_y, 0]) cylinder(r=shaft_r+2, h=5);
            }
        }
        // cut-out to form the flexure for the column
        translate([-99, nut_y - zflex[1]/2, zflex[2]]) cube([1,1,1]*999);
        hull() repeat([0,-5,5],2) {
            translate([-99, nut_y - zflex[1]/2, tip_h]) cube([1,1,1]*999);
        }
    }
}

tilted_actuator(30, 25, 50);