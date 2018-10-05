/*

A footprint for the microscope stand - this can be used to laser-cut
a pocket for it to sit neatly in a baseplate.

*/

module footprint(){
    hull() projection(cut=true) translate([0,0,-1]) import("../builds/microscope_stand.stl");
}

difference(){
    offset(0.1) footprint();
    offset(-3) footprint();
}