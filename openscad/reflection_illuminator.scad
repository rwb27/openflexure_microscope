use <./utilities.scad>;
use <./optics.scad>;
include <./microscope_parameters.scad>;
use <./dovetail.scad>;

module lens_holder(){
    // A simple one-lens condenser, re-imaging the LED onto the sample.
    led_h = 8;              //distance from bottom to the top of the LED
    aperture_h = 2;
    aperture_to_lens = 7.8; //distance from aperture stop to lens
    aperture_stop_r = 0.6;
    
    lens_z = led_h + aperture_to_lens + aperture_h;
    pedestal_h = 3;
    lens_r = 13/2;
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
                }
            }
            cylinder(r=base_r, h=lens_z-pedestal_h+d);
        }
        //beam
        hull(){
            translate([0,0,led_h+aperture_h]) cylinder(r=4,h=d);
            translate([0,0,lens_z]) cube([3,4,d], center=true);
        }
        
        //LED
        deformable_hole_trylinder(led_r-0.1,led_r+0.6,h=2*led_h+d, center=true);
        translate([0,0,led_h]) cylinder(r1=led_r+0.6, r2=aperture_stop_r,h=aperture_h-0.5+d);
        translate([0,0,led_h+aperture_h]) cylinder(r=aperture_stop_r,h=2,center=true);
        cylinder(r=led_r+0.5, h=1.5, center=true);
    }
}

module illuminator_holder(illuminator_d = 17){
    h = fl_cube_width() - 1;
    w = illuminator_d+4;
    difference(){
        union(){
            fl_led_mount(led_d=7);
            translate([-illuminator_d/2-2,10.5,0]) cube([w,20,h]);
        }
        //translate([0,13,0]) rotate([-90,0,0]) cylinder(h=999,r=999,$fn=5);
        rotate([180,0,0]) cylinder(h=999,r=999,$fn=5); //ground plane to fix up fl_led_mount
        
        // grip the illuminator
        translate([0,16, h/2]) rotate([-90,0,0]) cylinder(h=999,d=illuminator_d);
        translate([-w/2+2,15,-1]) cube([w-4, 4+d,999]); // cut out flexible bits
        translate([-w/2+5,19,-1]) cube([w-5*2, 999,999]); // cut out flexible bits
        // cable tie grooves to squeeze it
        translate([0,22,h/2]) rotate([-90,0,0]) difference(){
            cylinder(d=999,h=4.5,$fn=5);
            cylinder(d=illuminator_d + 2*3, h=999, center=true);
        }
    }
}

translate([20,0,0]) illuminator_holder();

difference(){
    lens_holder();
    //rotate([90,0,0]) cylinder(r=99,h=999,$fn=5);
}
//led_holder();
//for(i=[0:3]) translate([i*15,-20, 0]) difference(){
//    cylinder(h=0.5 * pow(2,i), d=12); 
//    cylinder(h=999,d=6,center=true);
//}