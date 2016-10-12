/*

An attempt at an alternative to my ageing "nut_seat_with_flex" design...

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
include <parameters.scad>;

d = 0.05;
nut_size = 3;
nut_vr = nut_size*1.15; //nominal radius of nut for an easy fit
nut_sr = nut_size*1.0; //radius of nut for a very tight fit
nut_h = 3; //height of nut insertion slot
nut_sh = 6; //height of nut trap; this should make the nut disappear.
shaft_r = nut_size/2 * 1.2; //radius of hole to cut for screw
actuator_column_h = 26; //default height of actuator columns
column_base_r = shaft_r + 2;
column_clearance_w = 2*nut_vr + 2*1.5 + 2*7;
column_core = [column_clearance_w, 2*(nut_vr + 1.5)+3, 0];

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
    r1 = column_base_r;
    nut_bottom = h - nut_sh - 1.5;
    r2 = nut_vr + 1.5;
    $fn=16;
    difference(){
        rotate([tilt,0,0]) union(){
            sequential_hull(){
                // main body, starting at bottom of shaft
                translate([0,0,-99]) cylinder(r=r1, h=d);
                translate([0,0,nut_bottom - (r2-r1)]) cylinder(r=r1, h=d);
                translate([0,0,nut_bottom]) union(){
                    rotate(30) cylinder(r=r2, h=h-nut_bottom, $fn=6);
                    translate([-r2*cos(30),0,0]) cube([r2*cos(30)*2,r2,h-nut_bottom]);
                }
            }
            // hooks for elastic bands/springs
            reflect([1,0,0]) translate([r2*cos(30),0,h]) difference(){
                mirror([0,0,1]) sequential_hull(){
                    translate([-d,-r2/2,0]) cube([d,r2,6.5]);
                    translate([0,-1,0]) cube([2.5,2,4]);
                    translate([0,-1,0]) cube([6,2,0.5]);
                } 
                translate([3, 0, 0]) rotate([0,45,0]) cube([2,99,2],center=true);
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

module nut_seat_void(h=1, tilt=0, center=true){
    // Inside of the actuator column housing (should be subtracted
    // h is the height of the top (excluding nut hole)
    // center=true will cause it to punch through the bottom.
    rotate([tilt,0,0]) intersection(){
        resize(column_core + [0,0,999]) cylinder(d=column_clearance_w, h=999, center=center);
        translate([0,0,h]) hole_from_bottom(nut_size*1.1/2, h=999, base_w=999);
    }
}
module screw_seat_shell(h=1, tilt=0){
    // Outside of the actuator column housing
    t = wall_t;
    difference(){
        rotate([tilt,0,0]) resize(column_core + [t,t,(h+2)*2]) hull(){
            cylinder(d=column_clearance_w, h=(h+0.5)*2, center=true);
            cylinder(d=column_clearance_w - 6, h=(h+2)*2, center=true);
        }
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //ground
        // hole through which we can insert the nut
        rotate([tilt,0,0]) translate([-99,column_core[1]/3, h-16]) cube(999);
    }
}

module tilted_actuator(pivot_z, pivot_w, lever, column_h=actuator_column_h, base_w = column_base_r*2){
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
                union(){
                    translate([-base_w/2, zflex[1], 0]) cube([base_w, d, 5]);
                    translate([-column_base_r, nut_y-12, 0]) cube([2*column_base_r, d, 5]);
                }
                translate([0, nut_y, 0]) cylinder(r=column_base_r, h=5);
            }
        }
        // cut-out to form the flexure for the column
        translate([-99, nut_y - zflex[1]/2, zflex[2]]) cube([1,1,1]*999);
        hull() repeat([0,-5,5],2) {
            translate([-99, nut_y - zflex[1]/2, tip_h]) cube([1,1,1]*999);
        }
    }
    translate([0, nut_y, 0]) actuator_column(column_h, -asin(pivot_z/lever));
}

module untilted_actuator(pushstick_z, pivot_w, lever, column_h=actuator_column_h, pushstick_w=6){
    // A lever with its pivot at the bottom, actuated by a column at the end.
    pw = pivot_w;
    pz = pushstick_z;
    nut_y = zflex[1] + lever;
    tip_h = 3;
    base_w = 2*column_base_r;
    difference(){
        reflect([1,0,0]){
            // pivot flexures
            translate([-pw/2, -d, 0]) cube(zflex + [0,2*d,0]);
            // arms linking flexures to actuator column
            sequential_hull(){
                union(){
                    translate([-pushstick_w/2, zflex[1], pz]) cube(zflex);
                    translate([-pw/2, zflex[1], 0]) cube(zflex);
                }
                translate([-base_w/2, nut_y - 20, 0]) cube([base_w, 8, 5]);
                translate([0, nut_y, 0]) cylinder(r=column_base_r, h=5);
            }
        }
        // cut-out to form the flexure for the column
        translate([-99, nut_y - zflex[1]/2, zflex[2]]) cube([1,1,1]*999);
        hull() repeat([0,-5,5],2) {
            translate([-99, nut_y - zflex[1]/2, tip_h]) cube([1,1,1]*999);
        }
    }
    translate([0, nut_y, 0]) actuator_column(column_h, 0);
}

module actuator_void(h, w1, w2, lever, tilted=false, extend_back=d){
    // A solid object that's big enough to give clearance for an actuator
    c = d; //additional clearance (makes it angular)
    w_n = 2*column_base_r + 2*c; // width of neck
    nut_y = tilted ? sqrt(lever*lever - h*h) : lever;
    tilt = tilted?-asin(h/lever):0;
    top_dy = tilted ? 0 : h*flex_a+1;
    minkowski(){
        hull(){
            translate([-min(w1,w2)/2-c, -extend_back, -d]) cube([min(w1,w2)+2*c,d,h]);
            //translate([-w2/2-c, -extend_back, h]) cube([w2+2*c,d,c]);
            translate([-w1/2-c, 0, -d]) cube([w1+2*c,d,c]);
            translate([-w2/2-c, top_dy, h]) cube([w2+2*c,d,c]);
            translate([-w_n/2, nut_y, -d]) rotate([tilt,0,0]) cube([w_n, 2, 5 + lever*flex_a+c+1.5]);
            
        }
        scale([1,1,1.5]) sphere(r=1.5, $fn=8);
    }
}

module actuator_shroud(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_column_h, anchor=true){
    // A cover for an actuator as defined above.
    ns_h = ac_h + lever * flex_a + 1.5; //internal height of nut seat
    nut_y = zflex[1] + (tilted ? sqrt(lever*lever - h*h) : lever);
    tilt = tilted?-asin(h/lever):0;
    
    difference(){
        union(){
            minkowski(){
                actuator_void(h, w1, w2, lever, tilted, extend_back);
                sphere(r=wall_t,$fn=8);
            }
            translate([0,nut_y,0]) screw_seat_shell(ns_h, tilt);
        }
        actuator_void(h, w1, w2, lever, tilted, extend_back); //cut out so it's hollow
        translate([0,nut_y,0]) nut_seat_void(ns_h, tilt); //cut out the nut seat
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //don't extend below ground
        translate([0,-extend_back,0]) rotate([90,0,0]) cylinder(r=999,h=999,$fn=8); //cut off at the end, so we don't go past the back and close it off
    }
}
    

//translate([0,20,0]) untilted_actuator(25, 25, 50);
//reflect([1,0,0]) rotate(45) translate([0,20,0]) tilted_actuator(25, 25, 50);
//intersection(){
//    tilted_actuator(30, 25, 50);
//    translate([0,50,0]) cube([20,30,999],center=true);
//}
//difference(){
//    screw_seat_shell(25, tilt=-40);
//    nut_seat_void(25, tilt=-40);
//}
actuator_shroud(30, 25, pw, 50, extend_back=20);
untilted_actuator(30,25,50);

translate([40,0,0]){
    actuator_shroud(25, 10, 25, 50, tilted=true);
    tilted_actuator(25,25,50, base_w=6);
}