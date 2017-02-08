/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope Feet                         *
*                                                                 *
* This file generates the feet for the microscope                 *
*                                                                 *
* Each foot sits under one actuator column, and clips in with     *
* lugs either side.  They have hooks in the bottom to hold the    *
* elastic bands and stops to limit the lower travel of the stage. *
*                                                                 *
* (c) Richard Bowman, January 2017                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
* http://www.github.com/rwb27/openflexure_microscope              *
* http://www.docubricks.com/projects/openflexure-microscope       *
* http://www.waterscope.org                                       *
*                                                                 *
******************************************************************/

include <microscope_parameters.scad> //for foot_height
use <utilities.scad>;
use <compact_nut_seat.scad>;
d = 0.05;

module foot_ground_plane(tilt=0, top=0, bottom=-999){
    //This represents where the ground would be, given that the
    //foot is usually printed tilted, pivoting around it's +y edge
    //As printed, the ground plane is the print bed, i.e. z=0
    //However, the foot is used in a different orientation, tilted
    //around the outer edge (so the microscope sits on the outer 
    //edges of the feet).
    //NB top and bottom refer to coordinates in the printing frame, so
    //they will be slightly larger Z shifts in the tilted (model) frame.
    l = ss_outer()[1];
    translate([0, l/2, 0]) rotate([-tilt+180,0,0]) translate([0,0,-top]) cylinder(r=999,h=top-bottom,$fn=8);
}

module foot(travel=5, 
            tilt=0, 
            hover=0, 
            entry_w=2*column_base_radius()+3, 
            lie_flat=true){
    w = ss_outer()[0]; //size of the outside of the screw seat column
    l = ss_outer()[1];
    cw = column_core_size()[0]; //size of the inside of the screw seat column
    cl = column_core_size()[1];
    wall_t = (w-cw)/2; //thickness of the wall
    h = foot_height - hover; //defined in parameters.scad, set hover=2 to not touch ground
    rotate([lie_flat?tilt:0,0,0]) //the foot prints tilted, lie_flat
    translate([0,0,lie_flat?-l/2*tan(tilt):-h]) //makes the bottom z=0
    difference(){
        union(){
            resize([w,l,2*h]) cylinder(d=w, h=h, center=true); //main part of foot
            resize([cw-d,cl,2*h+3]) cylinder(d=w, h=h, center=true); //lugs on top
        }
        //hollow out the inside
        difference(){
            //the core tapers at the top to support the lugs
            sequential_hull(){
                translate([0,0,-999]) resize([cw,cl,d]) cylinder(d=w,h=d);
                translate([0,0,h-4]) resize([cw,cl,d]) cylinder(d=w,h=d);
                translate([0,0,h]) resize([cw-2*wall_t,cl-2*wall_t,d]) cylinder(d=w,h=d);
                translate([0,0,999]) resize([cw-2*wall_t,cl-2*wall_t,d]) cylinder(d=w,h=d);
            }
            cube([entry_w, 999, 2*(h-travel-1)],center=true); //anchor for elastic bands
        }
        //cut out the core again, without tapering, in the middle (to make two lugs,
        //one on either side - rather than a ring around the top.
        translate([0,0,h-travel-1]) intersection(){
            cube([cw-4*2, 999, 999],center=true);
            resize([cw,cl,999]) cylinder(d=w,h=999);
        }
        
        //cut out the shell close to the microscope centre to allow the actuator 
        //to protrude (and bands to get in)
        difference(){
            translate([0,-l/2,0]) cube([entry_w, l-7, 999], center=true);
            //NB we leave the very bottom, to help it stick to the bed.
            foot_ground_plane(tilt=tilt, top=0.5);
        }
        
        //cut out a slot to allow bands to locate nicely, and/or to wrap round the outside
        intersection(){
            cube([999, 3, 999],center=true); 
            foot_ground_plane(tilt=tilt, bottom=0.5, top=(h-travel-4)*cos(tilt) - l/2*sin(tilt)); //bed adhesion...
        }
        cube([entry_w+d, 3, l*sin(tilt)+2], center=true); //make a real hole in the
        //middle - the other adhesion-helping bits will snap easily but this may not.

        //cut off the foot below the "ground plane" (i.e. print bed)
        foot_ground_plane(tilt=tilt);
    }
}
//foot(tilt=15);
//foot(tilt=0,hover=2);

reflect([0,1,0]) translate([0,ss_outer()[1]+2, 0]) foot(tilt=15, lie_flat=true);
foot(tilt=0,hover=2, lie_flat=true);