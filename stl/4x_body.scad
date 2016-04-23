/*

This is a trivial utility script for the openflexure microscope.
It gets round an annoyance with the Ultimaker plater in Cura.

Or it would if it worked!  Apparently it can't cope with four 
copies of the same STL?

*/

module microscope(){
    difference(){
        import("main_body_vanilla.stl");
        translate([0,0,-10]) cube(1);
    }
}
    

//translate([25,40,0]) microscope();
for(a=[0,90,180,270]) rotate(a) translate([25,40,0]) microscope();