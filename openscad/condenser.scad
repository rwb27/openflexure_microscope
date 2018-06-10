use <./illumination.scad>;
include <./microscope_parameters.scad>;

difference(){
    rotate([-15,0,0]) tall_condenser();
    mirror([0,0,1]) cylinder(r=999,h=999,$fn=4);
}
