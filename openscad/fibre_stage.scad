/*

OpenFlexure Fibre Stage

This project aims to be a high-performance flexure stage, with
short (~2mm) travel and very good accuracy and stability.  It
differs from the microscope by having shorter travel and more
mechanical reduction.  It also has all three axes combined on
one moving stage, rather than separating XY and Z.

*/
use <utilities.scad>;

stage = [37,20,5]; //dimensions of stage part
zflex = [6, 1.5, 0.75]; //dimensions of flexure
xflex = [5,5.5,5]; //default bounding box of x flexure
xflex_t = 1; //thickness of bendy bit in x
flex_a = 0.1; //angle through which flexures are bent, radians
dz = 0.5; //thickness before a bridge is printable-on
xy_stage_reduction = 3;
xy_lever = 10;
xy_travel = xy_lever * flex_a;
xy_bottom_travel = xy_travel * xy_stage_reduction;
xy_column_l = 20; //final part of XY actuators - to allow nut to stay straight
pushstick = [5,35,5]; //cross-section of XY "push stick"
z_lever = 10;
z_travel = z_lever * flex_a;
z_reduction = 5; //mechanical reduction for Z
d=0.05;

shelf_z1 = xy_lever * xy_stage_reduction;
shelf_z2 = shelf_z1 + xy_lever;

pushstick_cross_y = (pushstick[0]+pushstick[1])*sqrt(2); //if the pushsticks were infinitely long, they'd cross here.
pushstick_anchor_w = 2*(pushstick[1]+pushstick[0] - xy_lever*xy_stage_reduction - xflex[1]/2); //side length of the square anchor point for the XY pushsticks
z_stage_tip_y = pushstick[0]/sqrt(2) + xy_bottom_travel * sqrt(2); //position of the pointy end of the Z stage
z_triangle_d = 10; // size of the base of the Z stage
z_anchor_bottom_y = z_stage_tip_y + z_triangle_d + z_lever + zflex[1]; // lower Z stage end of the fixed base

z_pushstick_z = shelf_z1 - pushstick[0] - 1.5; //height of the Z pushstick
z_pushstick_l = pushstick_cross_y - z_anchor_bottom_y + zflex[1];// - pushstick[0] - zflex[1]; //length of z pushstick
z_actuator_x = pushstick_anchor_w/sqrt(2) + 1.5; //x position of the base of the Z actuator

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
    w = pushstick[0];
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
    w = pushstick[0];
    h = pushstick[2];
    l = pushstick[1];
    flex_l = xflex[1]+w/2+zflex[1];
    difference(){
        union(){
            translate([0,l/2,0]) reflect([0,1,0]){
                translate([0,-l/2,0]) xz_flexure();
            }
            translate([-w/2,flex_l,0]) cube([w,l-2*flex_l,h]);
        }
        
    }
}
module xy_actuator(l=50){
    // A beam with a fitting for the actuating nut in the end
    // The origin is the middle of the anchor for the initial X
    // flexure.
    w = pushstick[0];
    h = pushstick[2];
    union(){
        translate([0,xflex[1]/2,0]) x_flexure();
        translate([-w/2,xflex[1],0]) cube([w,l-xflex[1]/2+xflex[0]/2,h]);
        translate([w/2,xflex[1]/2+l,0]) rotate(-90){
            translate([0,xflex[1]/2,0]) x_flexure();
            translate([-w/2,xflex[1],0]) cube([w,xy_column_l,h]);
            translate([-5,xflex[1]+xy_column_l-10,0]) cube([10,10,h]);
        }
    }
    
}
module each_pushstick(){
    // Transformation that creates two pushsticks at 45 degrees
    reflect([1,0,0]) rotate(45) translate([0,pushstick[0]/2,0]) children();
}

module z_triangle(){
    // Triangle that forms the base of the Z stage
    l = z_triangle_d; //size of the triangle
    hull(){
        translate([0,z_stage_tip_y,0]) cylinder(r=d, h=d, $fn=8);
        reflect([1,0,0]){
            translate([l,z_stage_tip_y+l,0]) cylinder(r=d, h=d, $fn=8);
        }
    }
}

module z_stage(){
    // This is the part that moves in Z only, connected to the middle
    // "shelf" of the XY table
    // The triangular base of this part must fit between the 
    // pushsticks for the XY motion, which constrains the tip position
    // and also means we must bring the sides out at 45 degrees.
    sequential_hull(){
        z_triangle();
        translate([0,0,5]) z_triangle();
        translate([0,0,shelf_z1]) cube([stage[0], stage[1], d],center=true);
        translate([0,0,shelf_z1 + stage[2]/2]) cube(stage,center=true);
    }
    // Join the block to the anchor with some flexures at the bottom
    reflect([1,0,0]) translate([-z_triangle_d,z_stage_tip_y+z_triangle_d,0]){
        translate([0,-d,0]) cube([zflex[0], z_lever + zflex[1]+2*d, zflex[2]]);
        translate([0,zflex[1],0]) cube([z_triangle_d+d,z_lever - zflex[1], pushstick[2]]);
    }
    // And more flexures at the top
    reflect([1,0,0]) translate([-stage[0]/2,stage[1]/2,shelf_z1]){
        translate([0,-d,0]) cube([zflex[0], z_lever + zflex[1]+2*d, zflex[2]]);
        translate([0,zflex[1],dz]) cube([stage[0]/2+d,z_lever - zflex[1], stage[2]-dz]);
    }
    // The actuating "pushstick" attaches to this lever
    translate([-pushstick[0]/2, z_stage_tip_y + z_triangle_d + zflex[1], 0]) cube([pushstick[0], z_lever - zflex[1], shelf_z1 - 3]);
    // This is the actuating "pushstick"
    translate([-pushstick[0]/2, z_anchor_bottom_y, z_pushstick_z]){
        cube([pushstick[0], z_pushstick_l - 2*zflex[1], pushstick[2]]);
        translate([0,-zflex[1],0]) cube([pushstick[0], z_pushstick_l + d, zflex[2]]);
    }
    // The actuating lever pushes/pulls on the above pushstick
    reflect([1,0,0]) translate([0, pushstick_cross_y - zflex[1], 0]) sequential_hull(){
        bx = z_actuator_x;
        w = pushstick[0];
        translate([bx, -w, 0]) cube([w, w+zflex[1]+d, zflex[2]]);
        translate([bx, -w, 0]) cube([w, w, d]);
        translate([bx, -w, 14]) cube([w, w, d]);
        translate([bx, -w, z_pushstick_z - pushstick[2]/2]) cube([w, w*2 + zflex[1], pushstick[2]]);
        translate([-w/2, -w, z_lever * z_reduction]) cube([w,w,d]);
        translate([-w/2, -w, z_lever * z_reduction]) cube([w,w,pushstick[2]]);
    }
    translate([0, pushstick_cross_y+pushstick[0]/2, z_pushstick_z]) cube([z_actuator_x * 2 + 2*d, pushstick[0], pushstick[2]], center=true);
        
}

module extrude_then_roof(extrude, roof_extrude){
    union(){
        linear_extrude(extrude+d) children();
        translate([0,0,extrude]) linear_extrude(roof_extrude) hull() children();
    }
}

// Overall structure
union(){
    difference(){
        union(){
            xy_table();
        }
        
        // cutouts for pushsticks
        hull() each_pushstick(){
            h=stage[2]*2+z_travel*2;
            w = pushstick[0];
            cube([w, d, h], center=true);
            translate([0,1,0]) cube([w+1, d, h], center=true);
            translate([0, pushstick[1], 0]) cube([w+1+2*xy_bottom_travel*sqrt(2), d, h], center=true);
            translate([0, pushstick[1], 0]) cube([d, d, h + w+1+2*xy_bottom_travel*sqrt(2)], center=true);
        }
    }
    // anchor for pushsticks and pushsticks
    translate([0,0,pushstick[2]/2]) rotate(45) cube([pushstick[0],pushstick[0], pushstick[2]],center=true);
    each_pushstick() pushstick();
    // XY actuating levers
    each_pushstick() translate([xy_lever*xy_stage_reduction + xflex[1]/2, pushstick[0]/2 + pushstick[1], 0]) rotate(90) xy_actuator();
    
    // Z stage (the part that moves only in Z)
    z_stage();
    
    extrude_then_roof(8,6){
        // Anchor for the bottom of the Z stage
        hull(){ // anchor for the bottom part
            bottom_y = z_anchor_bottom_y;
            bottom_tip_y = (pushstick[0]+pushstick[1]*2)/sqrt(2) - xy_bottom_travel; // Y coordinate of where inside edges of actuators meet
            translate([-z_triangle_d, bottom_y]) square([2*z_triangle_d, bottom_tip_y - bottom_y - z_triangle_d]);
            translate([0,bottom_tip_y]) circle(r=d, $fn=8);
        }
        // Anchor for the pushsticks/actuators
        translate([0,pushstick_cross_y]) rotate(45) square(pushstick_anchor_w, center=true);
    }
    
    // Anchor for the top of the Z stage
    difference(){
        hull(){ // anchor
            translate([-stage[0]/2,stage[1]/2 + z_lever + zflex[1],shelf_z1]) cube([stage[0], 8, stage[2]]);
            translate([-z_triangle_d, z_anchor_bottom_y, 8]) cube([2*z_triangle_d, 20, d]);
        }
        // clearance for actuating lever
        translate([-pushstick[0]/2-1.5, z_anchor_bottom_y,0]){
            w = pushstick[0]+3;
            rotate([-asin(flex_a) + 90,0,0]) cube([w, shelf_z1, 999]);
            translate([0,0,shelf_z1 - pushstick[2] - 3]) cube([w, 999, pushstick[2]+3]);
        }
    }
}//*/
    