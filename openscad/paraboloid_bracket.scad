/***************************************************************
*  Mount for custom parabolic "objective"                      *
*                                                              *
*  (c) Richard Bowman 2016                                     *
*  Released under CERN open hardware license                   *
***************************************************************/

use <utilities.scad>;
use <./C270_mount.scad>
paraboloid_outer_r = 25;
paraboloid_bolt_r = 20;
paraboloid_h = 17;
beam_r = 25/2;
d=0.05;

module paraboloid_bracket(){
    // A right-angle bracket that will hold the custom-machined paraboloid
    plate = [40,6,40];
    screw_sep = 32;
    plate_t = 6;
    camera_z = plate_t*2+1+4;
    t = 3;
    beam_h = paraboloid_outer_r+plate[1];
    difference(){
        hull(){
            cylinder(r=paraboloid_outer_r,h=plate_t);
            translate([-plate[0]/2,-beam_h,0]) cube(plate + [0,0,plate_t]);
            translate([-paraboloid_outer_r,-12,0]) cube([d,24,2*camera_z]);
        }
        //beam/other mount clearance
        translate([0,0,plate_t]) cylinder(r=paraboloid_outer_r - t,h=999);
        cylinder(r=beam_r+t,h=999,center=true);
        
        //screw holes for translation stage
        translate([0,-beam_h+3,plate[2]/2+plate_t]){
            repeat([screw_sep,0,0],2,center=true)
            repeat([0,0,screw_sep],2,center=true){
                screw_y(3, h=999, shaft=true);
            }
        }
        //M4 screw holes for other mounts
        translate([0,-beam_h+3,plate[2]/2+plate_t]){
            repeat([1,0,1]*25/2,2,center=true)
            repeat([1,0,-1]*25/2,2,center=true){
                screw_y(4, h=999, shaft=true);
            }
            screw_y(4, h=999, shaft=true);
        }
        
        //nut traps for paraboloid
        for(a=[0,120,240]) rotate(a+60) translate([0,paraboloid_bolt_r,3]){
            nut(3,fudge=1.15,h=999,shaft=true);
        }
        
        //screw holes for spotting scope
        for(a=[0,120,240]) rotate(a) translate([0,18,3]){
            cylinder(r=3/2*0.95,h=999,center=true);
        }
        //camera mount for spotting scope
        translate([-paraboloid_outer_r,0,camera_h]) rotate([90,0,0]) c270_mount();
    }
}

paraboloid_bracket();