use <utilities.scad>;

$fn=32;

tube_lens_r=5;
tube_lens_edge_h=2;
gripper_t=1;

union(){
    difference(){
        cylinder(r=8,h=6);
        translate([0,0,0.8]) cylinder(r=7,h=999);
    }
    intersection(){
        cylinder(r=7.5,h=999);
        for(a=[0,120,240]) rotate(a){
            translate([-999,tube_lens_r,tube_lens_edge_h+0.75]) reflect([0,0,1]) rotate([20,0,0]) cube([999*2,gripper_t,tube_lens_edge_h]);
        }
    }
}

%cylinder(r=5,h=6);