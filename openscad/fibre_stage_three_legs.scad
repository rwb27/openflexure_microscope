/*

OpenFlexure Fibre Stage

This project aims to be a high-performance flexure stage, with
short (~2mm) travel and very good accuracy and stability.  It
differs from the microscope by having shorter travel and more
mechanical reduction.  It also has all three axes combined on
one moving stage, rather than separating XY and Z.

*/
use <utilities.scad>;
use <compact_nut_seat.scad>;
use <dovetail.scad>;
include <parameters.scad>;


module xy_table(){
    // XY table structure (anchors to Z stage)
    // This includes the legs and flexures for the XYZ stage and the
    // bottom part to which the XY actuators connect.
    reflect([1,0,0]) reflect([0,1,0]){
        // legs
        translate([stage[0], stage[1], 0]/2 + [1,1,0]*zflex[1]) cube([1,1,0]*zflex[0] + [0,0,shelf_z2 + stage[2] - 2]);
        
        for(z=[0,shelf_z1, shelf_z2]){
            // bridges between legs
            translate([stage[0]/2+zflex[1],-d,z]){
                cube([zflex[0], zflex[1]+stage[1]/2+2*d, zflex[2]]);
                cube([zflex[0], stage[1]/2+d, stage[2]]);
            }
            //shelves between bridges
            translate([-d,-d,z+2*dz]) cube(stage/2+[0,0,stage[2]/2-2*dz]);
            translate([-d, stage[1]/2-zflex[0], z+dz]) cube([stage[0]/2+zflex[1]+2*d, zflex[0], zflex[2]]);
        }
        translate([-d,-d,0]) cube(stage/2); //bottom sits on z=0
    }
}

module x_flexure(){
    // A flexure that bends along the Z direction, for motion in X
    roc = (xflex[0]-xflex_t)/2;
    difference(){
        translate([0,0,xflex[2]/2]) cube(xflex + [0,2*d,0], center=true);
        
        reflect([1,0,0]) hull() reflect([0,1,0]) reflect([0,0,1]){
            translate(xflex/2 - [0,roc,0]) cylinder(r=roc+d, h=999,$fn=16);
        }
    }
}
module xz_flexure(){
    // Two flexures to allow XZ motion of a beam extending along the Y axis
    w = pw;
    h = pushstick[2];
    // Start with an X flexure
    translate([0,xflex[1]/2,0]) x_flexure();
    sequential_hull(){
        translate([0,xflex[1]+w/8,h/2]) cube([w,w/4,h],center=true);
        translate([-w/2,xflex[1]+w/2,0]) cube([w,d,zflex[2]]);
        translate([-w/2,xflex[1]+w/2+zflex[1],0]) cube([w,d,zflex[2]]);
    }
}
module pushstick(){
    // A beam with 2-axis flexures at either end, to constrain 
    // position in 1D
    w = pw;
    h = pushstick[2];
    l = pushstick[1];
    flex_l = xflex[1]+w/2+zflex[1];
    difference(){
        union(){
            repeat([0,l-flex_l,0], 2) xz_flexure();
            translate([-w/2,flex_l,0]) cube([w,l-2*flex_l+d,h]);
        }
        
    }
}
module each_pushstick(){
    // Transformation that creates two pushsticks at 45 degrees
    reflect([1,0,0]) rotate(45) translate([0,pw/2,0]) children();
}

module z_base(){
    // Trapezoid that forms the base of the Z stage
    t = xy_bottom_travel;
    w = z_stage_base_w;
    hull(){
        translate([-pw,-pw-t,0]) cube([2*pw,d,d]); // inner edge
        translate([-w/2, -stage[1]/2-t, 0]) cube([w, d, d]);
        translate([-w/2, z_stage_base_y, 0]) cube([w, d, d]);
    }
}

module z_stage(){
    // This is the part that moves in Z only, connected to the middle
    // "shelf" of the XY table
    // The triangular base of this part must fit between the 
    // pushsticks for the XY motion, which constrains the tip position
    // and also means we must bring the sides out at 45 degrees.
    difference(){
        sequential_hull(){
            z_base();
            translate([0,0,stage[2]]) z_base();
            translate([0,0,shelf_z1 + stage[2]/2]) cube(stage,center=true);
        }
        
        // clearance for Z pushstick (see below)
        translate([-pw/2-1.5, -99, z_pushstick_z - 2 - z_travel]){
            cube([pw+3, 999, pushstick[2]+2.5+2*z_travel]);
        }
    }
    // Join the stage to the anchor with some flexures at the bottom
    reflect([1,0,0]) translate([-z_stage_base_w/2,z_anchor_bottom_y-d,0])
        cube([zflex[0], z_lever + zflex[1]+2*d, zflex[2]]);
    translate([-z_stage_base_w/2,z_anchor_bottom_y+zflex[1],0])
        cube([z_stage_base_w, z_lever - zflex[1], pushstick[2]]);
    // And more flexures at the top
    reflect([1,0,0]) translate([-stage[0]/2,-stage[1]/2,shelf_z1]) mirror([0,1,0]){
        translate([0,-d,0]) cube([zflex[0], z_lever + zflex[1]+2*d, zflex[2]]);
        translate([0,zflex[1],dz]) cube([stage[0]/2+d,z_lever - zflex[1], stage[2]-dz]);
    }
    // The actuating "pushstick" attaches to this lever
    hull(){
        translate([-pw/2, z_stage_base_y - z_lever, 0]) cube([pw, z_lever - zflex[1], stage[3]]);
        translate([-pw/2, z_stage_base_y - pw - zflex[1], 0]) cube([pw, pw, shelf_z1 - 3]);
    }
    // This is the actuating "pushstick"
    translate([-pw/2, z_stage_base_y, z_pushstick_z]){
        l = z_actuator_pivot_y - z_stage_base_y;
        cube([pw, l, pushstick[2]]);
        translate([0,-zflex[1]-d,0]) cube([pw, l + 2*zflex[1] + d, zflex[2]]);
    }
}

module mechanism_void(){
    difference(){
        sequential_hull(){
            union(){
                cube(stage + [2,2,0]*(xy_bottom_travel + zflex[1] + zflex[0] + 0.5), center=true);
                translate([0,z_stage_base_y-zflex[1]-z_lever+d,0]) 
                        cube([stage[0],2*d,stage[2]*2], center=true);
            }
            translate([0,0,shelf_z1]) union(){
                cube(stage + [2,2,0]*(zflex[1] + zflex[0] + 1.0), center=true); 
                translate([0,-stage[1]/2-zflex[1]-z_lever+d,0]) 
                        cube([stage[0],2*d,d], center=true);
            }
            translate([0,0,shelf_z2]) 
                    cube(stage + [2,2,0]*(zflex[1] + zflex[0] + 1.0 + xy_travel)
                         + [0,0,stage[2]], center=true); 
        }
        // take a chunk out to make the Z axis actuator work...
//        translate([0,z_actuator_pivot_y - wall_t,0]) hull(){
//            translate([-z_actuator_pivot_w/2,0,stage[2]]) 
//                    cube([z_actuator_pivot_w,999,shelf_z2]);
//            translate([-pw/2,-flex_a*z_pushstick_z+zflex[1],0]) cube([pw,d,pushstick[2]]);
//        }
//      These lines are redundant: the wall slopes back enough anyway, because it's the same
//      maximum flex angle for the XY legs as for the Z lever...
        
        // take a chunk out to allow for Z actuator reinforcement
        translate([0,z_actuator_pivot_y, 0]) mirror([0,1,0]) hull(){
            w = z_actuator_pivot_w;
            translate([-w/2,0,-99]) cube([w, wall_t, 999]);
            translate([-w/2 + 6,0,-99]) cube([w-6*2, wall_t + 6, 999]);
        }
    }
}

module casing_outline(cubic=true){
    // Once the mechanism void is subtracted, this makes a minimal wall around the structure.
    // NB you need to chop off the top and bottom too.
    if(cubic){
        s = xy_bottom_travel + zflex[1] + zflex[0] + 0.5 + wall_t;
        difference(){
            translate([-stage[0]/2-s, z_anchor_bottom_y-wall_t, 0])
                cube(stage + [2*s,s + (-z_anchor_bottom_y-stage[1]/2) + wall_t,shelf_z2]);
            // cut out for Z actuator //TODO: make this bigger...
            a = zflex[1] / (flex_a * z_pushstick_z);
            translate([0,z_actuator_pivot_y,0]) hull(){
                w = z_actuator_pivot_w*(1-a) + a*pw;
                translate([-w/2,0,a*z_pushstick_z]) cube([w,999,d]);
                translate([-pw/2,-z_pushstick_z*flex_a,z_pushstick_z-3]) cube([pw,d,pushstick[2]+5]);
                translate([-w/2,0,z_pushstick_z+pushstick[2]+2+z_pushstick_z*flex_a]) cube([w,999,d]);
            }
        }
    }else{
        minkowski(){
            hull() mechanism_void();
            cylinder(r=wall_t, h=d, center=true, $fn=8);
        }
    }
}


// Overall structure
module main_body(){
    difference(){
        union(){
            xy_table();
        }
        
        // cutouts for pushsticks
        each_pushstick() hull() {
            h=stage[2]*2+z_travel*2;
            translate([0,2*d,0]) cube([pw, d, h], center=true);
            translate([0,0.5,0]) cube([pw+1.5, d, h], center=true);
            translate([0, pushstick[1], 0]) cube([pw+1+2*xy_bottom_travel*sqrt(2), d, h], center=true);
            translate([0, pushstick[1], 0]) cube([d, d, h + pw+1+2*xy_bottom_travel*sqrt(2)], center=true);
            translate([99, 98, 0]) cube([d, d, h + pw+1+2*xy_bottom_travel*sqrt(2)], center=true); //cut out between the pushsticks
        }
        
        // cutout for Z stage
        hull(){
            h=stage[2]*2+z_travel*2;
            w = stage[0] - 2*zflex[1];
            translate([0, -pw, 0]) cube([2*pw,d,h],center=true);
            translate([0, -stage[1]/2, 0]) cube([w,2*d,h],center=true);
        }
        
        // mounting holes on top
        repeat([10,0,0],4,center=true)
            repeat([0,10,0],2,center=true)
            translate([0,0,shelf_z2 + 1]) cylinder(d=3*0.95,h=999);
    }
    // XY pushsticks and actuators
    each_pushstick(){
        pushstick();
        translate([0,pushstick[1] - zflex[1],0]) tilted_actuator(shelf_z1, xy_actuator_pivot_w, xy_lever * xy_reduction, base_w = pw);
    }
    
    // Z stage (the part that moves only in Z) and actuator
    z_stage();
    translate([0,z_actuator_pivot_y,0]){
        untilted_actuator(z_pushstick_z, z_actuator_pivot_w, z_lever * z_reduction);
    }
    //reinforcement through the void in the centre
    reflect([1,0,0]) translate([0,0,pushstick[2] + 4 + z_travel]) hull(){
        translate([pw/2+3, z_actuator_pivot_y - wall_t, 0]) cube([4,d,4]);
        translate([stage[0]/2 + zflex[0] + zflex[1] + xy_bottom_travel, -stage[1]/2,0]) cube([0.5,4,4]);
    }
    
    // Casing (also provides a lot of the structural integrity)
    difference(){
        union(){
            //minimal wall around the mechanism (will be hollowed out later)
            casing_outline();
            
            //mounts for XY actuators
            each_pushstick() hull(){
                translate([0, pushstick[1]-zflex[1], shelf_z1])
                        cube([xy_actuator_pivot_w + 4, d, 2], center=true);
                translate([-13/2, 0, shelf_z1-1-pushstick[1]])
                        cube([13, d, pushstick[1]+3]);
            }
            //covers and screw seats for the XY actuators
            each_pushstick() translate([0,pushstick[1]-zflex[1],0]) actuator_shroud(shelf_z1, pw, xy_actuator_pivot_w, xy_lever*xy_reduction, tilted=true, extend_back=pushstick[1]);
            //cover and screw seat for the Z actuator
            translate([0,z_actuator_pivot_y,0]) actuator_shroud(z_pushstick_z+pushstick[2], z_actuator_pivot_w, pw, z_lever*z_reduction, tilted=false, extend_back=wall_t/2);
        }
        // limit the wall in Z
        translate([0,0,shelf_z2 + stage[2] - z_travel]) cylinder(r=999,h=999,$fn=8);
        translate([0,0,-99]) cylinder(r=999,h=99,$fn=8);
        // make it a wall not a block - clearance for the mechanism
        mechanism_void();
        // clearance for the XY pushsticks
        each_pushstick() translate([-(pw+3)/2,0,-d]) cube(pushstick + [3,0,xy_travel+3]);
        // clearance for the Z pushstick
        translate([-(pw+3)/2, 0, z_pushstick_z-3]) cube([pw+3,z_actuator_pivot_y + z_pushstick_z*flex_a,pushstick[2]+5]);
    }
        
    
}//*/


//main_body();

//static platform;
standoff = 10;
module extrude_then_roof(extrude, roof_extrude){
    union(){
        linear_extrude(extrude+d) children();
        translate([0,0,extrude]) linear_extrude(roof_extrude) hull() children();
    }
}
/*
rotate([-90,0,0])rotate(-45)
difference(){
    union(){
        translate([0,0,-3]) intersection(){
            extrude_then_roof(3,4) projection() translate([0,0,-shelf_z2 - stage[2] + d]) difference(){
                casing_outline();
                mechanism_void();
            }
            translate([50,-50,0]) rotate(-45) cube([2*50*sqrt(2)-standoff*2,999,999],center=true);
        }
        
        translate([1,-1,0]*(25/2+standoff)/sqrt(2) + [0,0,2]) rotate(45) cube([16,25,4],center=true);
        
         translate([1,-1,0]/sqrt(2)*(standoff)+[0,0,4-d+10]) rotate([-90,0,-135])dovetail_clip([14,10,25],solid_bottom=0.5,slope_front=1.5);
    }
}*/
sep = sqrt(2)*10;
/*difference(){
    hull(){
        cube([sep+8, 8, 17]);
    }
    translate([4,4,2]) repeat([sep,0,0],2){
        cylinder(r=3/2*1.1, h=999,center=true);
        cylinder(r=3,h=999);
    }
}*/

module outline(mech_void=true){
    projection(cut=true) translate([0,0,-d]) difference(){
            union(){
            //minimal wall around the mechanism (will be hollowed out later)
            casing_outline();
            
            //covers and screw seats for the XY actuators
            each_pushstick() translate([0,pushstick[1]-zflex[1],0]) actuator_shroud(shelf_z1, pw, xy_actuator_pivot_w, xy_lever*xy_reduction, tilted=true, extend_back=pushstick[1]);
            //cover and screw seat for the Z actuator
            translate([0,z_actuator_pivot_y,0]) actuator_shroud(z_pushstick_z+pushstick[2], z_actuator_pivot_w, pw, z_lever*z_reduction, tilted=false, extend_back=wall_t/2);
        }
        // make it a wall not a block - clearance for the mechanism
        if(mech_void) mechanism_void();
        // clearance for the XY pushsticks
        each_pushstick() translate([-(pw+3)/2,0,-d]) cube(pushstick + [3,0,xy_travel+3]);
    }
}
//translate([0,0,6.5]) mirror([0,0,1]) extrude_then_roof(6,0.5)
//outline();
linear_extrude(6) outline();
linear_extrude(0.5) outline(false);