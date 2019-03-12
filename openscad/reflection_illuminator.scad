use <./utilities.scad>;
use <./optics.scad>;
include <./microscope_parameters.scad>;
use <./dovetail.scad>;

module lens_holder(){
    // A simple one-lens condenser, re-imaging the LED onto the sample.
    lens_z = 5;
    pedestal_h = 3;
    lens_r = 13/2;
    aperture_r = lens_r-3;
    lens_t = 1;
    base_r = lens_r+2;
    led_r = 5/2;
    difference(){
        union(){
            //lens gripper to hold the plastic asphere
            translate([0,0,lens_z-pedestal_h]){
                // gripper
                trylinder_gripper(inner_r=lens_r, grip_h=pedestal_h + lens_t/3,h=pedestal_h+lens_t+1.5, base_r=base_r, flare=0.5);
                // pedestal to raise the tube lens up within the gripper
                difference(){
                    cylinder(r=lens_r-0.5,h=pedestal_h);
                    //translate([0,0,pedestal_h]) cylinder(r=aperture_r,h=0.6,center=true);
                }
            }
            cylinder(r=base_r, h=lens_z-pedestal_h+d);
        }
        //beam
        hull(){
            translate([0,0,-d]) cylinder(r=4,h=d);
            translate([0,0,lens_z]) cube([3,4,d], center=true);
        }
    }
}

module led_holder(led_r=5/2, h=5){
    //bottom part
        difference(){
            union(){
                cylinder(r=5, h=h);
            }
            
            //LED
            deformable_hole_trylinder(led_r-0.1,led_r+0.6,h=2*(h-1), center=true);
            translate([0,0,h-1.5]) cylinder(r1=led_r, r2=0.7,h=1.5+d);
            
        }
}

translate([0,20,0]) lens_holder();
led_holder();
for(i=[0:3]) translate([i*15,-20, 0]) difference(){
    cylinder(h=0.5 * pow(2,i), d=12); 
    cylinder(h=999,d=6,center=true);
}