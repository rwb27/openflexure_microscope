use <utilities.scad>;

$fn=32;
d=0.05;

tube_lens_r=5+0.1;
tube_lens_edge_h=2;
tube_lens_centre_h=3.4;
gripper_t=1;


        body_r=8;
        inner_r=body_r-1;
        cutout_h=tube_lens_centre_h+1;
        roof_r = inner_r-cutout_h+tube_lens_edge_h;
        
module body(){
    union(){
        difference(){
            //body
            hull(){
                cylinder(r=body_r,h=body_r);
                translate([-body_r,-body_r,0]) cube([2*body_r,body_r,body_r]);
            }
            
            //cutout for lens and holder
            intersection(){
                translate([0,0,1.25]) union(){
                    hull(){
                        cylinder(r=inner_r,h=cutout_h);
                        translate([-inner_r,-body_r-d,0]) cube([inner_r*2,inner_r,cutout_h]);
                    }
                    translate([-roof_r,-tube_lens_r+0.5,0]) cube([roof_r*2,2*tube_lens_r-2*0.5,cutout_h+0.5]);
                }
                rotate([0,45,0]) cube([1,999,1]*(inner_r+tube_lens_edge_h)*sqrt(2),center=true);
            }
            //indent and hole for lens
            translate([0,0,0.5]) cylinder(r1=tube_lens_r,r2=tube_lens_r+0.5,h=1);
            translate([0,0,-d]) cylinder(r=tube_lens_r-0.5,h=9);
            
            //relief so it can slide in without scratches
            //translate([-tube_lens_r+1,-6,1]) cube([tube_lens_r*2-2,6,0.5]); 
            
        }
        
    }
}

module gripper1(){
    reflect([1,0,0]){
        difference(){
            union(){
                translate([0,-inner_r,0]) cube([lens_r,inner_r+sqrt(pow(inner_r,2) - pow(lens_r,2))-0.5,d]);
                translate([0,-inner_r,0]) cube([lens_r+0.5,inner_r+sqrt(pow(inner_r,2) - pow(lens_r,2))-0.5,d]);
            }
        }
    }
}

module gripper(){
    difference(){
        intersection(){
            translate([0,0,1.25]) union(){
                hull(){
                    cylinder(r=inner_r,h=tube_lens_edge_h);
                    translate([-inner_r,-body_r-d,0]) cube([inner_r*2,inner_r,tube_lens_edge_h]);
                }
            }
            rotate([0,45,0]) cube([1,999,1]*(inner_r+tube_lens_edge_h)*sqrt(2),center=true);
            translate([0,-inner_r+4,0]) cube([999,2*body_r,999],center=true);
        }
        //indent and hole for lens
        translate([0,0,0.5]) cylinder(r1=tube_lens_r+tube_lens_edge_h,r2=tube_lens_edge_h,h=tube_lens_r);
        translate([0,0,0.5]) hull() repeat([0,999,0],2) cylinder(r1=tube_lens_r+tube_lens_edge_h-0.2,r2=tube_lens_edge_h-0.2,h=tube_lens_r);
        cube([tube_lens_r*2-1,inner_r*2,999],center=true);
        
        
        
    }
}

module lens() {
    intersection(){
        dh=tube_lens_centre_h-tube_lens_edge_h;
        rs=(pow(dh,2) + pow(tube_lens_r,2))/(2*dh);
        cylinder(r=tube_lens_r,h=999);
        translate([0,0,tube_lens_centre_h-rs]) sphere(r=rs);
    }
}

gripper();
//body();

%translate([0,0,0.5]) lens();
