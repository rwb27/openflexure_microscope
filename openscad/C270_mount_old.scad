use <utilities.scad>;



$fn=48;
d=0.05;

module C270(beam_r=5, beam_h=5){
    //cut-out to fit logitech C270 webcam
    //optical axis at (0,0)
    //top of PCB at (0,0,0)
    camera_h=0;
    mounting_hole_x = 8.25;
    mirror([0,0,1]){
        //beam clearance
        hull(){
            cube([8,8,6],center=true);
            cylinder(r=beam_r,h=2*beam_h,center=true);
        }

        //mounting holes
        reflect([1,0,0]) translate([mounting_hole_x,0,-5]) cylinder(r=0.6,h=999,$fn=12); 
        
        //clearance for PCB
        translate([0,0,0]){
            hull(){
                translate([-10/2,-13.5,0]) cube([10,d,8]);
                translate([-21.5/2,-4,0]) cube([21.5,49.5,8]);
            }
            reflect([0,1,0]) hull(){
                translate([-4.5,6,-1.5]) cube([9,7.5,8]);
                translate([-5.5,6,-1.5]) cube([11,6.5,8]);
            }
            hull(){
                translate([0,22.5,4]) cube([20.5,28,13],center=true);
                translate([0,22.5,4]) cube([18.5,28,15],center=true);
            }
        }
    }
}

C270();