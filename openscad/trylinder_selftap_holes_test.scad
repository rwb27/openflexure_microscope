/* Test object for self-tapping holes
Released under CERN open hardware license v1
*/

use <utilities.scad>;

sizes = [2.4, 2.6, 2.8, 2.9, 3.0, 3.1, 3.2, 3.4, 3.6, 3.8, 4.0, 4.2, 4.4];
N = len(sizes);
r = 5;

difference(){
    hull(){
        cylinder(d=2*r, h=6);
        translate([2*r*(N-1),0,0]) cylinder(d=2*r, h=6);
    }
    
    for(i=[0:N-1]) translate([2*r*i,0,0]){
        trylinder_selftap(sizes[i], h=999, center=true);
        
        translate([0, -r+0.5, 0.5]) rotate([90,0,0]) linear_extrude(1) text(str(sizes[i]), size=4, halign="center");
    }
}