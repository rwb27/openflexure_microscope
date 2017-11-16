/*

An attempt at an alternative to my ageing "nut_seat_with_flex" design...

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
include <microscope_parameters.scad>;

d = 0.05;
nut_size = 3;
nut_w = 6.3*1.1; //nominal width of the nut (vertex-to-vertex, bigger than flat-flat distance - 6.3 is theoretical value and the 1.03 is determined by experiment)
nut_h = 2.6;
nut_slot = [nut_w*sin(60), nut_w, nut_h+0.4];
shaft_r = nut_size/2 * 1.15; //radius of hole to cut for screw
column_base_r = shaft_r + 2; //radius of the bottom of the actuator column
//column_clearance_w = nut_slot[0] + 2*1.5 + 2*7;
column_core = zeroz(nut_slot) + 2*[1.5+7+1, 1.5+1.5, 0];// NB leave z=0 here 
wall_t = 1.6; //thickness of the wall around the column for the screw seat

function nut_size() = nut_size;
function column_base_radius() = column_base_r;
function column_core_size() = column_core;
function nut_slot_size() = nut_slot;
function ss_outer(h=-2) = column_core + [wall_t*2,wall_t*2,(h+2)*2];

module nut_trap_and_slot(r, slot, squeeze=0.9, trap_h=-1){
    // A cut-out that will hold a nut.  The nut slots in horizontally
    // along the +y axis, and is pulled up and into the tight part of the
    // nut seat when a screw is inserted.
    hole_r = r*1.15/2;
    trap_h = trap_h<0 ? r : trap_h;
    w = slot[0]; //width of the nut entry slot (should be slightly larger than the nut)
    l = slot[1]; //length/depth of the slot (now ignored)
    h = slot[2]; //height of the slot
    r1 = w/2/cos(30); //bottom of nut trap is large
    r2 = r*squeeze; //top of nut trap is very tight
    sequential_hull(){
        translate([-w/2,999,0]) cube([w,d,h]);
        union(){
            translate([-w/2,l/2-d,0]) cube([w,d,h]);
            rotate(30) cylinder(d=w/sin(60), h=h, $fn=6);
        }
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

module actuator_column(h, tilt=0, lever_tip=3, flip_nut_slot=false, join_to_casing=false, no_voids=false){
    // An "actuator column", a nearly-vertical tower, with a nut trap and hooks
    // for elastic bands at the top, usually attached to a flexure at the bottom.
    // There's often one of these inside the casing under an adjustment screw/gear
    //h: height of the column
    //tilt: the column is rotated about the x axis
    //lever_tip: height of the actuating lever at its end (can taper up at 45 degrees)
    //flip_nut_slot: if set to true, the nut is inserted from -y
    //join_to_casing: if set to true, the column is joined to the casing by thin threads
    //no_voids: don't leave a void for the nut or screw, used for the drilling jig.
    r1 = column_base_r; //size of the bottom part
    top = nut_slot + [3,3,nut_size + 1.5]; //size of the top part
    r2 = sqrt(top[0]*top[0]+top[1]*top[1])/2; //outer radius of top
    slot_angle = flip_nut_slot ? 180 : 0; //enter from -y if needed
    $fn=16;
    difference(){
        rotate([tilt,0,0]) union(){
            sequential_hull(){
                // main body, starting at bottom of shaft
                translate([0,0,-99]) resize([2*r1, top[1],d]) cylinder(r=r1, h=d);
                translate([0,0,h-top[2] - 2*(r2-r1)]) resize([2*r1, top[1],d]) cylinder(r=r1, h=d);
                translate([0,0,h-top[2]/2]) cube(top, center=true);
            }
            // hooks for elastic bands/springs
            reflect([1,0,0]) translate([top[0]/2,0,h]) difference(){
                mirror([0,0,1]) sequential_hull(){
                    translate([-d,-top[1]/2,0]) cube([d,top[1],top[2]]);
                    translate([0,0,0.5]) scale([0.5,1,1]) cylinder(d=4.5, h=top[2]-2);
                    translate([1.5,0,0.5]) resize([3,4,3.5]) cylinder(d1=1, d2=4, h=4);
                    translate([3.5,0,0.5]) resize([2.5,3.0,1.5]) cylinder(d1=1,d2=3.5);
                    union(){
                        reflect([0,1,0]) translate([4.5,0.5,0]) cylinder(d=1,h=1);
                        translate([4,0,0]) cylinder(d=1,h=1);
                    }
                } 
            }
            // join the column to the casing, for strength during printing...
            if(join_to_casing) translate([0,0,lever_tip+zflex[2]+3]){
                cube([ss_outer()[0]-wall_t, 1, 0.5], center=true);
                //translate([-1/2,0,-0.25]) cube([1, ss_outer()[1]/2-wall_t/2, 0.5]); //this was too short...
            }
        }
        
        // nut trap
        if(!no_voids) rotate([tilt,0,0]) rotate(slot_angle) 
            translate([0,0,h-top[2]]) nut_trap_and_slot(nut_size, nut_slot);
        
        // shaft for the screw
        // NB this is raised up from the bottom so it stays within the shaft - this may need to change depending on the length of screw we use...
        if(!no_voids) rotate([tilt,0,0]) translate([0,0,lever_tip]){
            cylinder(r=shaft_r, h=999);
            translate([0,0,-lever_tip+1]) cylinder(r1=0, r=shaft_r, h=lever_tip-1); //pointy bottom (stronger)
        }
        
        // space for lever and flexure
        translate([-99, -zflex[1]/2, zflex[2]]) sequential_hull(){
            cube([999,zflex[1],lever_tip]);
            translate([0,-999,999]) cube([999,zflex[1],lever_tip]);
        }
        
        // tiny holes, to increase the perimeter of the bottom bit and make it
        // stronger
        translate([-d,0,zflex[2]]) cube([2*d, 10, 4]);
        // cut off at the bottom
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=4);
    }
}
//actuator_column(25);

module actuator_end_cutout(lever_tip=3-0.5 ){
    // This shape cuts off the end of an actuator, leaving a thin strip to
    // connect to the actuator column (the flexure).
    sequential_hull(){
        translate([-999,-zflex[1]/2,zflex[2]]) cube([2,2,2]*999);
        translate([-999,-zflex[1]/2,zflex[2]+lever_tip]) cube([2,2,2]*999);
        translate([-999,-zflex[1]/2-999,zflex[2]+999]) cube([2,2,2]*999);
    }
}

module nut_seat_silhouette(r=ss_outer()[1]/2, dx=ss_outer()[0]-ss_outer()[1], offset=0){
    // a (2D) shape made from the convex hull of two circles
    //    hull() reflect([1,0]) translate([x,0]) circle(r=r);
    // we don't actually build it like that though, as the hull is a slow operation...
    union(){
        reflect([1,0]) translate([dx/2,0]) circle(r=r+offset);
        square([dx,2*(r+offset)], center=true);
    }
}

module nut_seat_void(h=1, tilt=0, center=true){
    // Inside of the actuator column housing (should be subtracted
    // h is the height of the top (excluding nut hole)
    // center=true will cause it to punch through the bottom.
    // This ensures enough clearance to let the actuator column move.
    r = column_core[1]/2;
    x = column_core[0]/2 - r;
    rotate([tilt,0,0]) intersection(){
        linear_extrude(999,center=center) nut_seat_silhouette(offset=-wall_t);
        translate([0,0,h]) rotate(90) hole_from_bottom(nut_size*1.1/2, h=999, base_w=999);
    }
}
//color("red")nut_seat_void(10,tilt=-10);

module screw_seat_shell(h=1, tilt=0){
    // Outside of the actuator column housing - this is the structure that
    // the gear sits on top of.  It needs to be hollowed out before use
    // (see screw_seat)
    r = ss_outer(h)[1]/2;
    x = ss_outer(h)[0]/2 - r;
    double_h = ss_outer(h)[2];
    difference(){
        rotate([tilt,0,0]) hull(){
            linear_extrude(double_h-3, center=true) nut_seat_silhouette();
            linear_extrude(double_h, center=true) nut_seat_silhouette(offset=-2);
        }
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //ground
        // hole through which we can insert the nut
        //rotate([tilt,0,0]) translate([-99,column_core[1]/3, h-16]) cube(999); //this gets added later
    }
}

module motor_lugs(h=20, tilt=0, angle=0){
    // lugs to mount a micro geared stepper motor on a screw_seat.
    motor_shaft_pos=[0,-20,h+2]; //see height of screw_seat_shell above
    motor_screw_pos=[35/2,motor_shaft_pos[1]+7.8,motor_shaft_pos[2]+10];
    screw_r = sqrt(pow(motor_screw_pos[0],2)+pow(motor_screw_pos[1],2));
    rotate([tilt,0,0]) rotate(angle) reflect([1,0,0]) difference(){
        union(){
            hull(){
                translate(motor_screw_pos-[0,0,8]) cylinder(r=4,h=8);
                translate([0,0,motor_screw_pos[2]-screw_r-8]) cylinder(r=5,h=screw_r-5);
            }
        }
        //space for gears
        translate([0,0,h]) cylinder(r1=8,r2=17,h=2+d);
        translate([0,0,h+2]) cylinder(h=999,r=17);
        //hollow inside of the structure
        rotate(-angle) nut_seat_void(h=h, tilt=tilt);
        //mounting screws
        translate(motor_screw_pos) cylinder(r=1.9,h=20,center=true);
    }
}

module screw_seat(h=25, travel=5, entry_w=2*column_base_r+3, extra_entry_h=7, motor_lugs=false, lug_angle=0){
    // This forms a hollow column, usually built around an actuator_column to
    // support the screw (see screw_seat_shell)
    tilt = 0; //currently, only vertical ones are supported.
    entry_h = extra_entry_h + travel; //ensure the actuator can move
    difference(){
        union(){
            screw_seat_shell(h=h + travel);
            if(motor_lugs) rotate(180) motor_lugs(h=h + travel, angle=lug_angle);
        }
        nut_seat_void(h=h + travel); //hollow out the inside
        
        edge_y = ss_outer(h)[1]/2; //allow the actuator to poke in
        translate([0,-edge_y,0]) cube([entry_w, edge_y, entry_h*2], center=true);
        
        //entrance slot for nut
        rotate([tilt,0,0]) translate([0,0,h-nut_size-1.5-nut_slot[2]]) nut_trap_and_slot(nut_size, nut_slot + [0,0,0.3]);
    }
}

module screw_seat_outline(h=999,adjustment=0,center=false){
    // The bottom of a screw seat
    //w = ss_outer()[0];
    //l = ss_outer()[1];
    //a = adjustment;
	//resize([w+a, l+a, h]) cylinder(r=20, h=h, center=center);
    linear_extrude(h,center=center) nut_seat_silhouette(offset=adjustment); //offset(adjustment) projection(cut=true) translate([0,0,-1]) screw_seat_shell();
}


module tilted_actuator(pivot_z, pivot_w, lever, column_h=actuator_h, base_w = column_base_r*2){
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

module untilted_actuator(pushstick_z, pivot_w, lever, column_h=actuator_h, pushstick_w=6){
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

module flexure_anchor_cutout(h=999,w=999, extend_back=999){
    // A flexure anchor that is 999 wide and deep (for subtraction)
    // If we subtract this from an actuator_void, it leaves a good
    // solid chunk inside the actuator shroud for the actuator to
    // pivot around.
    intersection(){
        mirror([0,1,0]) hull() reflect([1,0,0]){
            translate([0,extend_back,h/2]) cube([999,d,d]);
            translate([0,0,zflex[2]]) mirror([0,0,1]) cube(999);
        }
        
        cube([999,w,h],center=true);
    }
}

module actuator_shroud_shell(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_h, motor_lugs=motor_lugs){
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
            translate([0,nut_y,0]) motor_lugs(ns_h, tilt);
            
        }
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //don't extend below ground
        translate([0,-extend_back,0]) rotate([90,0,0]) cylinder(r=999,h=999,$fn=8); //cut off at the end, so we don't go past the back and close it off
    }
}
module actuator_shroud_core(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_h, anchor=true, pushstick_h=pushstick[2]+3){
    // The inside of a cover for an actuator as defined above.
    // It's split like this for ease of combining them together.
    ns_h = ac_h + lever * flex_a + 1.5; //internal height of nut seat
    nut_y = zflex[1] + (tilted ? sqrt(lever*lever - h*h) : lever);
    tilt = tilted?-asin(h/lever):0;
    
    difference(){
        actuator_void(h, w1, w2, lever, tilted, extend_back); //cut out so it's hollow
        if(tilted){ //make the void smaller so we get an anchor
            translate([0,0,h+zflex[2]]) mirror([0,0,1]) flexure_anchor_cutout(h=2*(h-pushstick_h), extend_back=extend_back);
        }else{
            flexure_anchor_cutout(h=2*(h-pushstick_h), extend_back=extend_back);
        }
    }
                
    translate([0,nut_y,0]) nut_seat_void(ns_h, tilt); //cut out the nut seat
    // hole through which we can insert the nut
    translate([0,nut_y]) rotate([tilt,0,0]) 
            rotate(tilted ? 180 : 0) 
            translate([-nut_slot[0]/2-0.5,0,ac_h-nut_slot[2]-nut_size-1.5]) 
            cube(nut_slot + [1,999,1]);
}
module actuator_shroud(h, w1, w2, lever, tilted=false, extend_back=d, ac_h=actuator_h, anchor=true){
    difference(){
        actuator_shroud_shell(h, w1, w2, lever, tilted=tilted, extend_back=extend_back, ac_h=ac_h);
        actuator_shroud_core(h, w1, w2, lever, tilted=tilted, extend_back=extend_back, ac_h=ac_h, anchor=anchor);
    }
}
    
//actuator_shroud(30, 25, pw, 50, extend_back=20);
//untilted_actuator(30,25,50);

translate([40,0,0]){
//    actuator_shroud(25, 10, 25, 50, tilted=true, extend_back=20);
//    tilted_actuator(25,25,50, base_w=6);
}
//echo(nut_slot);
/*/
difference(){
    union(){
        screw_seat(25, motor_lugs=true);

        difference(){ //an example actuator rod
            translate([-3,-40,0]) cube([6,40,5]);
            actuator_end_cutout();
        }
        actuator_column(25, 0);
        translate([0,0,1+20.5]) cube([6,14,2],center=true);
    }
    translate([0,0,2.5]) rotate([180,0,0]) cylinder(r=999,h=999,$fn=4);
}//*/
nut_seat_void(99, tilt=30, center=true); // space inside the column

/*/ TEST PIECE: different sized nut slots, 3% different in size
difference(){
    scales=[0.94, 0.97, 1.0, 1.03, 1.06, 1.09];
    n = len(scales);
    nominal_w = 6.3;
    translate([1,1,0]*(-2-nominal_w/2)) cube([n*(nominal_w+4), nominal_w+4, nut_h+6]);
    
    for(i=[0:(n-1)])translate([i*(nominal_w+4),0,2]) {
        w=nominal_w*scales[i];
        nut_trap_and_slot(nominal_w/2, [w*sin(60),w,nut_h+0.2]);
        translate([0,0,d]) cylinder(r=shaft_r,h=999);
        translate([0,-(2+nominal_w/2), 0]) rotate([90,0,0]) linear_extrude(0.6,center=true) text(str((scales[i]-1)*100), size=nut_h+3, halign="center");
    }
    translate([-(2+nominal_w/2), 0, 2]) rotate([90,0,-90]) linear_extrude(0.6,center=true) text(str(nominal_w), size=(nut_h+3)/2, halign="center");
    translate([(2+nominal_w/2)*(n*2-1), 0, 2]) rotate([90,0,90]) linear_extrude(0.6,center=true) text("+/-%", size=(nut_h+3)/2, halign="center");
}
//*/
