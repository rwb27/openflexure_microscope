/*

An attempt at an alternative to my ageing "nut_seat_with_flex" design...

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
include <parameters.scad>;

d = 0.05;
nut_size = 3;
nut_slot = [nut_size*2*sin(60)*1.15, (nut_size*1.15+0.5)*2, nut_size+0.7];
shaft_r = nut_size/2 * 1.2; //radius of hole to cut for screw
actuator_column_h = 26; //default height of actuator columns
column_base_r = shaft_r + 2;
//column_clearance_w = nut_slot[0] + 2*1.5 + 2*7;
column_core = nut_slot + 2*[1.5+7+1, 1.5+1.5, -nut_slot[2]/2];// NB leave z=0 here //[column_clearance_w, nut_slot[1]+3+3, 0];
shroud_t = [1,1,0.75];

function column_core_size() = column_core;

module nut_trap_and_slot(r, slot, squeeze=0.9, trap_h=-1){
    // A cut-out that will hold a nut.  The nut slots in horizontally
    // along the +y axis, and is pulled up and into the tight part of the
    // nut seat when a screw is inserted.
    hole_r = r*1.2/2;
    trap_h = trap_h<0 ? r : trap_h;
    w = slot[0];
    l = slot[1];
    h = slot[2];
    r1 = w/2/cos(30); //bottom of nut trap is large
    r2 = r*squeeze; //top of nut trap is very tight
    sequential_hull(){
        translate([-w/2,999,0]) cube(slot);
        translate([-w/2,-l/2,0]) cube(slot);
        translate([-w/2,-w/2/cos(30),0]) cube([w,w/cos(30),h]);
        translate([-w/2,-w/2/cos(30),0]) cube([w,w/cos(30),h+0.5]);
        a = 1/trap_h;
        rotate(30) cylinder(r=r1*(1-a) + r2*a, h=h+1, $fn=6);
        rotate(30) cylinder(r=r2, h=h+trap_h, $fn=6);
    }
    // ensure the hole in the top can be made nicely
    intersection(){
        translate([-999, -hole_r,0]) cube([9999, 2*hole_r, h + trap_h + 0.5]);
        rotate(30) cylinder(r=r2, h=999, $fn=6);
    }
        
}
//nut_trap_and_slot(3, nut_slot);

module nut_and_band_tool(nut_slot=nut_slot){
    //This tool assists with inserting both the nuts and elastic bands.
    //At some point I'll make one for springs, if needed...?
    w = nut_slot[0]-0.5;
    l = 2*actuator_column_h;
    h = nut_slot[2]-0.7;
    n = nut_size;
    nut_y = nut_slot[1]/2-0.2;
    difference(){
        translate([-w/2, 0,0]) cube([w,l,h]);
        
        // hold the nut here
        translate([0,nut_y,0.5]) rotate(30) cylinder(r=n*1.15, h=999, $fn=6);
        // slot for the screw shaft
        hull() reflect([0,1,0]) translate([0,nut_y,0]) cylinder(r=n*1.05/2, h=999, center=true, $fn=16);
        // slope the front for ease of insertion
        translate([-99,-2*nut_y,0]) rotate([atan(h/(3*nut_y)),0,0]) cube(999);
        // slot at the other end for band insertion
        translate([0,l,0]) cube([2.5,14,999],center=true);
        // V shaped end to grip elastic bands
        translate([-99,l-1.5,0])hull(){
            translate([0,0,0.75]) cube([999,999,0.5]);
            translate([0,1.5,0.5]) cube([999,999,h-1]);
        }
    }
}
        
//nut_and_band_tool();

module actuator_column(h, tilt=0, lever_tip=3, flip_nut_slot=false){
    r1 = column_base_r; //size of the bottom part
    top = nut_slot + [3,3,nut_size + 1.5]; //size of the top part
    r2 = sqrt(top[0]*top[0]+top[1]*top[1])/2; //outer radius of top
    slot_angle = flip_nut_slot ? 180 : 0; //enter from -y if needed
    $fn=16;
    difference(){
        rotate([tilt,0,0]) union(){
            sequential_hull(){
                // main body, starting at bottom of shaft
                translate([0,0,-99]) cylinder(r=r1, h=d);
                translate([0,0,h-top[2] - 2*(r2-r1)]) cylinder(r=r1, h=d);
                translate([0,0,h-top[2]/2]) cube(top, center=true);
            }
            // hooks for elastic bands/springs
            reflect([1,0,0]) translate([top[0]/2,0,h]) difference(){
                mirror([0,0,1]) sequential_hull(){
                    translate([-d,-top[1]/2,0]) cube([d,top[1],6.5]);
                    translate([0,-1,0]) cube([2.5,2,4]);
                    translate([0,-1,0]) cube([6,2,0.5]);
                } 
                translate([3, 0, 0]) rotate([0,45,0]) cube([2,99,2],center=true);
            }
        }
        
        // nut trap
        rotate([tilt,0,0]) rotate(slot_angle) translate([0,0,h-top[2]]) nut_trap_and_slot(nut_size, nut_slot);
        
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

//actuator_column(25, 0);

module nut_seat_void(h=1, tilt=0, center=true){
    // Inside of the actuator column housing (should be subtracted
    // h is the height of the top (excluding nut hole)
    // center=true will cause it to punch through the bottom.
    rotate([tilt,0,0]) intersection(){
        resize(column_core + [0,0,999]) cylinder(d=column_core[0], h=999, center=center);
        translate([0,0,h]) hole_from_bottom(nut_size*1.1/2, h=999, base_w=999);
    }
}
//color("red")nut_seat_void(10,tilt=-10);

module screw_seat_shell(h=1, tilt=0){
    // Outside of the actuator column housing
    t = wall_t;
    difference(){
        rotate([tilt,0,0]) resize(column_core + [t*2,t*2,(h+2)*2]) hull(){
            cylinder(d=column_core[0], h=(h+0.5)*2, center=true);
            cylinder(d=column_core[0] - 6, h=(h+2)*2, center=true);
        }
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //ground
        // hole through which we can insert the nut
        //rotate([tilt,0,0]) translate([-99,column_core[1]/3, h-16]) cube(999);
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
    translate([0, nut_y, 0]) actuator_column(column_h, -asin(pivot_z/lever), flip_nut_slot=true);
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

module flexure_anchor_cutout(h=999,w=999){
    // A flexure anchor that is 999 wide and deep (for subtraction)
    intersection(){
        mirror([0,1,0]) hull() reflect([1,0,0]){
            translate([0,0,zflex[2]]) rotate([-asin(flex_a)-2,0,0]) cube(999);
            mirror([0,0,1]) cube(999);
        }
        
        cube([999,w,h],center=true);
    }
}

module actuator_shroud_shell(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_column_h){
    // A cover for an actuator as defined above.
    ns_h = ac_h + lever * flex_a + 1.5; //internal height of nut seat
    nut_y = zflex[1] + (tilted ? sqrt(lever*lever - h*h) : lever);
    tilt = tilted?-asin(h/lever):0;

    difference(){
        union(){
            minkowski(){
                actuator_void(h, w1, w2, lever, tilted, extend_back);
                //sphere(r=wall_t,$fn=8);
                cylinder(r=wall_t,$fn=16,h=0.8);
            }
            translate([0,nut_y,0]) screw_seat_shell(ns_h, tilt);
        }
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //don't extend below ground
        translate([0,-extend_back,0]) rotate([90,0,0]) cylinder(r=999,h=999,$fn=8); //cut off at the end, so we don't go past the back and close it off
    }
}
module actuator_shroud_core(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_column_h, anchor=true, pushstick_h=pushstick[2]+3){
    // The inside of a cover for an actuator as defined above.
    // It's split like this for ease of combining them together.
    ns_h = ac_h + lever * flex_a + 1.5; //internal height of nut seat
    nut_y = zflex[1] + (tilted ? sqrt(lever*lever - h*h) : lever);
    tilt = tilted?-asin(h/lever):0;
    
    difference(){
        actuator_void(h, w1, w2, lever, tilted, extend_back); //cut out so it's hollow
        if(tilted){ //make the void smaller so we get an anchor
            translate([0,0,h+zflex[2]]) mirror([0,0,1]) flexure_anchor_cutout(h=2*(h-pushstick_h));
        }else{
            flexure_anchor_cutout(h=2*(h-pushstick_h));
        }
    }
                
    translate([0,nut_y,0]) nut_seat_void(ns_h, tilt); //cut out the nut seat
    // hole through which we can insert the nut
    translate([0,nut_y]) rotate([tilt,0,0]) 
            rotate(tilted ? 180 : 0) 
            translate([-nut_slot[0]/2-0.5,0,ac_h-nut_slot[2]-nut_size-1.5]) 
            cube(nut_slot + [1,999,1]);
}
module actuator_shroud(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_column_h, anchor=true){
    difference(){
        actuator_shroud_shell(h, w1, w2, lever, tilted=tilted, extend_back=extend_back, ac_h=ac_h);
        actuator_shroud_core(h, w1, w2, lever, tilted=tilted, extend_back=extend_back, ac_h=ac_h, anchor=anchor);
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
    actuator_shroud(25, 10, 25, 50, tilted=true, extend_back=20);
    tilted_actuator(25,25,50, base_w=6);
}