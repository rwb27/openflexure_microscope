/*

This file should render the optics of the microscope...

(c) 2017 Richard Bowman, released under CERN Open Hardware License

*/

use <../optics.scad>;
include <../microscope_parameters.scad>;

mounts=true;
lenses=true;

module lens(d=16, f=40, ct=4.5){
    intersection(){
        cylinder(d=d, h=999);
        translate([0,0,-f+ct]) sphere(r=f);
    }
}
module led(){
    union(){
        cylinder(d=6, h=0.7);
        cylinder(d=5, h=5);
        translate([0,0,5]) sphere(r=5/2);
    }
}

module cutaway(){
    difference(){
        children();
        
        rotate([0,90,0]) cylinder(r=999,h=999,$fn=4); //cutaway
    }
}

condenser_z = sample_z + 21 + 12;

if(mounts) cutaway(){
    // Optics module for RMS objective, using Comar 40mm singlet tube lens
    optics_module_rms(
        tube_lens_ffd=38, 
        tube_lens_f=40, 
        tube_lens_r=16/2+0.1, 
        objective_parfocal_distance=35,
        fluorescence=false
    );
}

if(mounts) cutaway(){
    // Condenser module
    translate([0,0,condenser_z]) rotate([180,0,0]) condenser();
}

if(lenses){
    translate([0,0,20]) lens(d=16, f=24, $fn=64);
    
    translate([0,0,condenser_z-17]) mirror([0,0,1]) lens(d=13,f=9,ct=6);

    translate([0,0,condenser_z]) rotate([180,0,0]) led();
}
