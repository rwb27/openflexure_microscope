include <microscope_parameters.scad>;
use <dovetail.scad>;
use <utilities.scad>;

clip_outer_w = objective_clip_w + 4;
h = 11.5;

//Centre of mounting holes to centre of mounting holes on static part is
// stage[1]/2 + z_lever + zflex[1]+4 (in the +y direction)
// stage[1] = 20
// z_lever = 10
// zflex[1] = 1.5
// so dy = 10 + 10 + 1.5 + 4 = 25.5
// actually the mounting holes are +/-5mm from this (10mm centres) so add 5mm
dy = 25.5 + 5;

difference(){
    union(){
        translate([0,objective_clip_y,0]) dovetail_clip([clip_outer_w,10,h],solid_bottom=0.5,slope_front=1.5);
        sequential_hull(){
            translate([-7,objective_clip_y - d + 10, 0]) cube([14, d, h]);
            translate([-8,dy-4,0]) cube([16,d,5]);
            reflect([1,0,0]) translate([5,dy,0]) cylinder(r=3,h=5);
        }
    }
    
    reflect([1,0,0]) translate([5,dy,0])
            cylinder(d=3*1.2, h=999,center=true);
}