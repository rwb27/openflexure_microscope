use <utilities.scad>;

$fn=32;
d=0.05;

tube_lens_r=5+0.1;
tube_lens_edge_h=2;
tube_lens_centre_h=4;
gripper_t=1;

union(){
    difference(){
        hull(){
            cylinder(r=8,h=6);
            translate([-8,-8,0]) cube([16,8,6]);
        }
        intersection(){
            hull(){
                translate([0,0,1.25]) cylinder(r=7,h=999);
                translate([-7,-9,1.25]) cube([14,7,999]);
            }
        }
        //indent and hole for lens
        translate([0,0,0.5]) cylinder(r1=tube_lens_r,r2=tube_lens_r+0.5,h=1);
        translate([0,0,-d]) cylinder(r=tube_lens_r-0.5,h=1);
        
        //relief so it can slide in without scratches
        translate([-tube_lens_r+1,-6,1]) cube([tube_lens_r*2-2,6,0.5]); 
        
    }
    
    //gripper
    reflect([1,0,0]){
        top_r=7-tube_lens_r+1;
        translate([-7,-tube_lens_r+1,1.25-d]) difference(){
            intersection(){
                cylinder(r1=top_r-tube_lens_edge_h/2,
                         r2=top_r, h=tube_lens_edge_h+1);
                rotate(-90) cube(999);
            }
            translate([0,0,-d]) cylinder(r1=top_r-tube_lens_edge_h/2-0.5,
                     r2=top_r-0.5, h=tube_lens_edge_h+1+2*d);
        }
        intersection(){
            cylinder(r=7.5,h=999);
            hull(){
                translate([-7+top_r-0.5,-tube_lens_r+1-d,1.25+tube_lens_edge_h+1-d]) cube([0.5,999,d]);
                translate([-7+top_r-0.5-tube_lens_edge_h/2,-tube_lens_r+1-d,1.25-d]) cube([0.5,999,d]);
            }
        }
    }
}

%cylinder(r=5,h=6);