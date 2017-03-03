// Very simple adapter to hold a 1 inch disc on the microscope
// This is useful if you've got a 1 inch calibration target.
// This file is CC-0 public domain.

difference(){
    cylinder(d=40,h=1.7);
    
    translate([0,0,0.7]) cylinder(d=26,h=999);
    cylinder(d=23, h=999, center=true);
}