/*

Adapter plate to mount a translation stage on the side of a fibre-alignment flexure stage.

(c) Richard Bowman 2016, released under CERN open hardware license

*/

use <utilities.scad>;

//origin is at the top of the mount, in the centre.  Y points downwards.
M3_holes = [[-24,26,0],[24,26,0],[27,59.5,0],[-24,53.3,0]];
base = [60.5,62.5,12];

difference(){
    hull(){
        translate([-base[0]/2,0,0]) cube(base);
        translate([0,0,0]) cylinder(r=8,h=base[2],$fn=32);
    }
    
    //holes to mount to the fibre stage
    for(pos = M3_holes) translate(pos){
        cylinder(d=3.5*1.2, h=999,center=true, $fn=16);
        translate([0,0,base[2]-4.5]) cylinder(d=6.6*1.1,h=999,$fn=16);
    }
    
    //holes to mount to the coarse stage
    repeat([0,25,0], 2){
        translate([0,0,0]) nut_from_bottom(6,h=8);
    }
}