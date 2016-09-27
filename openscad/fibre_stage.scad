/*

OpenFlexure Fibre Stage

This project aims to be a high-performance flexure stage, with
short (~2mm) travel and very good accuracy and stability.  It
differs from the microscope by having shorter travel and more
mechanical reduction.  It also has all three axes combined on
one moving stage, rather than separating XY and Z.

*/
use <utilities.scad>;
use <nut_seat_with_flex.scad>;

stage = [37,20,5]; //dimensions of stage part
zflex = [6, 1.5, 0.75]; //dimensions of flexure
xflex = [5,5.5,5]; //default bounding box of x flexure
xflex_t = 1; //thickness of bendy bit in x
flex_a = 0.1; //angle through which flexures are bent, radians
dz = 0.5; //thickness before a bridge is printable-on
xy_stage_reduction = 3; //ratio of sample motion to lower shelf motion
xy_reduction = 5; //mechanical reduction from screw to sample
xy_lever = 10;
xy_travel = xy_lever * flex_a;
xy_bottom_travel = xy_travel * xy_stage_reduction;
xy_column_l = 22; //final part of XY actuators - to allow nut to stay straight
pushstick = [5,35,5]; //cross-section of XY "push stick"
pw = pushstick[0]; //because this is used in a lot of places...
z_lever = 10;
z_travel = z_lever * flex_a;
z_reduction = 5; //mechanical reduction for Z
wall_t = 1.6;
owall_h = pushstick[2] + 1.5 + 1;
d=0.05;

shelf_z1 = xy_lever * xy_stage_reduction;
shelf_z2 = shelf_z1 + xy_lever;

actuator_cross_y = (pw+pushstick[1])*sqrt(2); //if the pushsticks were infinitely long, they'd cross here.
pushstick_anchor_w = 2*(pushstick[1]+pw - xy_lever*xy_stage_reduction - xflex[1]/2); //side length of the square anchor point for the XY pushsticks
z_stage_tip_y = pw/sqrt(2) + xy_bottom_travel * sqrt(2); //position of the pointy end of the Z stage
z_triangle_d = 10; // size of the base of the Z stage
z_anchor_bottom_y = z_stage_tip_y + z_triangle_d + z_lever + zflex[1]; // lower Z stage end of the fixed base

z_pushstick_z = shelf_z1 - pw - 1.5; // height of the Z pushstick
z_pushstick_l = actuator_cross_y - z_anchor_bottom_y + zflex[1];// - pw - zflex[1]; //length of z pushstick, incl. flexures
za_pivot = [pushstick_anchor_w/sqrt(2) + 1.5, z_anchor_bottom_y + z_pushstick_l - zflex[1], 0]; // position of the fixed end of the Z actuator (after, so +y of, the flexure)
z_nut_y = za_pivot[1] + z_lever * z_reduction; // y position of the acutating nut for the Z axis.

xy_column_pivot = [0,actuator_cross_y,0] + [1, -1, 0]*(xy_lever * xy_reduction + pushstick_anchor_w/2 + xflex[1]/2)/sqrt(2); //where the XY "columns" join the actuator
wall_near_xy_column_pivot = xy_column_pivot + [0, (pw/2 + 1.5 + wall_t/2)*sqrt(2), 0] + [1,1,0]*xy_travel*xy_reduction/sqrt(2) + [-1,1,0] * (10-pw)/2/sqrt(2);


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
            translate([0,l/2,0]) reflect([0,1,0]){
                translate([0,-l/2,0]) xz_flexure();
            }
            translate([-w/2,flex_l,0]) cube([w,l-2*flex_l,h]);
        }
        
    }
}
module xy_actuator(l=xy_lever * xy_reduction){
    // A beam with a fitting for the actuating nut in the end
    // The origin is the middle of the anchor for the initial X
    // flexure.
    w = pw;
    h = pushstick[2];
    difference(){
        union(){
            translate([0,xflex[1]/2,0]) x_flexure();
            translate([-w/2,xflex[1],0]) cube([w,l-xflex[1]/2+xflex[0]/2,h]);
            translate([w/2,xflex[1]/2+l,0]) rotate(-90){
                translate([0,xflex[1]/2,0]) x_flexure();
                translate([-w/2,xflex[1],0]) cube([w,xy_column_l,h]);
                translate([-5,xflex[1]+xy_column_l-10,0]) cube([10,10,h]);
            }
        }
        translate([w/2 + xflex[1]+xy_column_l-7,xflex[1]/2+l,h/2]){
            rotate([0,180,-90]) nut_y(3, top_access=true); 
            rotate([0,0,-90]) translate([0,-xy_column_l + 7 + 0.5, 0]) cylinder_with_45deg_top(r=3/2*1.1, h=2*(xy_column_l - 8), $fn=16, extra_height=0.1);
        }
    }
}
module each_pushstick(){
    // Transformation that creates two pushsticks at 45 degrees
    reflect([1,0,0]) rotate(45) translate([0,pw/2,0]) children();
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
    // Join the stage to the anchor with some flexures at the bottom
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
    translate([-pw/2, z_stage_tip_y + z_triangle_d + zflex[1], 0]) cube([pw, z_lever - zflex[1], shelf_z1 - 3]);
    // This is the actuating "pushstick"
    translate([-pw/2, z_anchor_bottom_y, z_pushstick_z]){
        cube([pw, z_pushstick_l - 2*zflex[1], pushstick[2]]);
        translate([0,-zflex[1],0]) cube([pw, z_pushstick_l + d, zflex[2]]);
    }
    // The actuating lever pushes/pulls on the above pushstick via
    // the bridge structure below
    reflect([1,0,0]) translate([0, za_pivot[1], 0]) sequential_hull(){
        bx = za_pivot[0];
        w = pw;
        top = z_pushstick_z - pushstick[2]/2; //highest bit
        translate([bx, -zflex[1]-d, 0]) cube([w, w+zflex[1]+d, zflex[2]]);
        translate([bx, 0, 0]) cube([w, w, d]);
        translate([bx, 0, 14+1]) cube([w, w, w/2]);
        translate([bx - (top - 14-1), 0, top]) cube([w, w, w/2]);
        translate([-w/2, 0, top]) cube([w, w, pushstick[2]]);
    }
    // This is the actuating lever itself.
    reflect([1,0,0]) translate([0, za_pivot[1], 0]) sequential_hull(){
        bx = za_pivot[0];
        w = pw;
        h = pushstick[2];
        translate([bx, 0, 0]) cube([w, w, h]);
        translate([bx, w-d, 0]) cube([w, d, 15]);
        translate([-w/2+d, 35, 0]) cube([w, d, h]);
        translate([-w/2+d, z_lever * z_reduction - 5, 0]) cube([w, d, h]);
    }
    // And the column at the end of the actuator...
    translate([0, za_pivot[1] + z_lever * z_reduction, 0]) nut_seat_with_flex();
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
            w = pw;
            cube([w, d, h], center=true);
            translate([0,1,0]) cube([w+1, d, h], center=true);
            translate([0, pushstick[1], 0]) cube([w+1+2*xy_bottom_travel*sqrt(2), d, h], center=true);
            translate([0, pushstick[1], 0]) cube([d, d, h + w+1+2*xy_bottom_travel*sqrt(2)], center=true);
        }
        
        // mounting holes on top
        repeat([10,0,0],4,center=true)
            repeat([0,10,0],2,center=true)
            translate([0,0,shelf_z2 + 1]) cylinder(d=3*0.95,h=999);
    }
    // anchor for pushsticks and pushsticks
    translate([0,0,pushstick[2]/2]) rotate(45) cube([pw,pw, pushstick[2]],center=true);
    each_pushstick() pushstick();
    // XY actuating levers
    each_pushstick() translate([xy_lever*xy_stage_reduction + xflex[1]/2, pw/2 + pushstick[1], 0]) rotate(90) xy_actuator();
    // XY screw seats
    reflect([1,0,0]) translate(xy_column_pivot) rotate(-45){
        l = xy_column_l + xflex[1]; //length of column incl. flexure
        yface = l + pw/2; //end of column
        yint = yface + xy_travel * xy_reduction;
        iw = 10 + 3; //internal width of structure
        ow = iw + 2*wall_t; //external width
        difference(){
            extrude_then_roof(owall_h - 1, 1){
                translate([-ow/2, yint]) square([ow, 2]);
                hull(){
                    translate([-iw/2 - 8, yint - l + 1.5]) square([8,d]);
                    translate([-ow/2, yint - l + 1.5]) square([wall_t,l]);
                }
            }
            translate([0,0,pushstick[2]/2]) cylinder_with_45deg_top(r=3/2*1.1, h=999,center=true, extra_height=0.1, $fn=16);
        }
                
    }
    
    // Z stage (the part that moves only in Z)
    z_stage();
    
    extrude_then_roof(owall_h-1,14-owall_h+1){
        // Anchor for the bottom of the Z stage
        hull(){
            bottom_y = z_anchor_bottom_y;
            bottom_tip_y = (pw+pushstick[1]*2)/sqrt(2) - xy_bottom_travel; // Y coordinate of where inside edges of actuators meet
            translate([-z_triangle_d, bottom_y]) square([2*z_triangle_d, bottom_tip_y - bottom_y - z_triangle_d]);
            translate([0,bottom_tip_y]) circle(r=d, $fn=8);
        }
        // Anchor for the XY actuators
        translate([0,actuator_cross_y]) rotate(45) square(pushstick_anchor_w, center=true);
    }
    
    // Anchor for the top of the Z stage
    difference(){
        hull(){ // anchor
            translate([-stage[0]/2,stage[1]/2 + z_lever + zflex[1],shelf_z1]) cube([stage[0], 8, stage[2]]);
            translate([-z_triangle_d, z_anchor_bottom_y, 8]) cube([2*z_triangle_d, 20, d]);
        }
        // clearance for Z actuating lever
        translate([-pw/2-1.5, z_anchor_bottom_y,0]){
            w = pw+3;
            rotate([-asin(flex_a) + 90,0,0]) cube([w, shelf_z1, 999]);
            translate([0,0,shelf_z1 - pushstick[2] - 3]) cube([w, 999, pushstick[2]+3]);
        }
        // mounting holes on top
        translate([0,stage[1]/2 + z_lever + zflex[1]+4,shelf_z1+1]) repeat([10,0,0],4,center=true) cylinder(d=3*0.95,h=999);
    }
    
    // Anchor for Z actuator
    translate([0, za_pivot[1] - zflex[1],0]) sequential_hull(){
        w = 2*(pw + za_pivot[0] + 1.5 + wall_t);
        translate([0,-1,d])cube([w, 2, 2*d], center=true);
        translate([0,-1,8])cube([w, 2, 2*d], center=true);
        translate([0,-4,8+6-d])cube([w, 6, 2*d], center=true);
    }
    translate([-pushstick_anchor_w/sqrt(2),actuator_cross_y,0]) mirror([0,1,0]) cube([pushstick_anchor_w*sqrt(2), actuator_cross_y - za_pivot[1] + zflex[1] + d, 10]);
    
    // Place for the Z screw to sit
    translate([0, z_nut_y, 0]) screw_seat();
    
    // Cover/base structure that holds it all together
    difference(){
        union(){
            //from Z nut seat to XY nut seat
            reflect([1,0,0]) sequential_hull(){
                translate([4.5, z_nut_y, 0]) cube([wall_t,d,12]);
                translate(za_pivot + [pw + 1.5, 15, 0]) cube([wall_t,d,14]);
                translate(za_pivot + [pw + 1.5, -7, 0]) cube([wall_t, 15, 14]);
                //translate(za_pivot + [pw + 1.5 + wall_t/2, -7+wall_t/2, 0]) cylinder(d=wall_t, h=14);
                translate(wall_near_xy_column_pivot) cylinder(d=wall_t, h=owall_h);
            }
            //roof over the Z actuator
            hull() reflect([1,0,0]){
                translate([4.5, z_nut_y, 11]) cube([wall_t,d,1]);
                translate(za_pivot + [pw + 1.5, 15, 14-d]) cube([wall_t,d,1]);
            }
            //from arm near XY actuators to top of Z axis
            reflect([1,0,0]) hull(){
                translate([stage[0]/2-wall_t,stage[1]/2 + z_lever + zflex[1],shelf_z1]) cube([wall_t, 8, 1]);
                translate(wall_near_xy_column_pivot + [0,0,owall_h-1]) cylinder(d=wall_t, h=1);
                translate(za_pivot + [pw + 1.5, -7, 14-1]) cube([wall_t, wall_t, 1]);
            }
            //from arm near XY actuators to bottom of Z axis
            reflect([1,0,0]) hull(){
                translate([z_triangle_d-wall_t,z_anchor_bottom_y,owall_h-1]) cube([wall_t, 8, 1]);
                translate(wall_near_xy_column_pivot + [0,0,owall_h-1]) cylinder(d=wall_t, h=1);
                translate(za_pivot + [pw + 1.5, -7, owall_h-1]) cube([wall_t, wall_t, 1]);
            }
            
        }
        // make sure we clear the Z column
        translate([0,z_nut_y,0]) resize(ss_inner(999)) cylinder(r=10,h=999,$fn=32,center=true);
    }
}//*/
    