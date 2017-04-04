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
    //NB top and bottom refer to distances in the model frame, so
    //they will be slightly smaller Z shifts in the printer frame.
    //top or bottom=0 places the plane on the print bed, which is
    // z=l/2*tan(tilt) in the foot frame (as it's tilted about one
    // corner).
    translate([0,0,bottom])
        skew_flat(tilt, true) cylinder(r=999,h=top-bottom,$fn=8);
}
module skew_flat(tilt, shift=false){
    // This transformation skews a plane so it's parallel to the print bed, in
    // the foot (which has been rotated by an angle `tilt`).  Z coordinates are
    // unchanged by this transform; it's a skew **not** a rotation.
    // if shift is true, move things up so that z=0 corresponds to the print
    // bed.  Otherwise, z=0 is below the bottom of the foot (because z=0 is
    // touched by the edge of the foot in the unskewed frame - and the skew will
    // move that side of the model downwards.  It's all because we rotate the
    // model about the corner, rather than the centre...
    l = ss_outer()[1];
    multmatrix([[1,0,0,0],
                [0,1,0,0],
                [0,tan(-tilt),1,shift ? l/2*tan(tilt) : 0],
                [0,0,0,1]]) children();
}
module rx(){
    //handy shorthand for reflecting in X
    reflect([1,0,0]) children();
}

module filleted_bridge(gap, roc_xy=2, roc_xz=2){
    // This can be subtracted from a structure of width gap[0] to form
    // a hole in the bottom of the object with rounded edges.
    // It's used here to smooth the band anchor to avoid damaging the bands.
    w = gap[0];
    b = gap[1];
    h = gap[2];
    x1 = w/2 - roc_xy;
    x2 = w/2 - roc_xz;
    y1 = b/2 + roc_xy;
    difference(){
        translate(-zeroz(gap)/2 -[0,roc_xy,999]) cube(gap + [0,2*roc_xy,roc_xz] + [0,0,999]);
        reflect([0,1,0]) sequential_hull(){
            rx() translate([x1, y1, -999]) cylinder(r=roc_xy, h=d);
            rx() translate([x1, y1, 0]) cylinder(r=roc_xy, h=h+roc_xz);
            rx() translate([x2, b/2, h+roc_xz]) rotate([-90,0,0]) cylinder(r=roc_xz, h=d);
            rx() translate([x2, -2*d, h+roc_xz]) rotate([90,0,0]) cylinder(r=roc_xz ,h=d);
        }
    }
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
            //we double-subtract the anchor for the bands at the bottom, so that it
            //doesn't protrude outside the part.
            cube([2*column_base_radius()+1.5, 999, 2*(h-travel-0.5)],center=true); 
        }
        //cut out the core again, without tapering, in the middle (to make two lugs,
        //one on either side - rather than a ring around the top.
        translate([0,0,h-travel-1]) intersection(){
            cube([cw-3.3*2, 999, 999],center=true);
            resize([cw,cl,999]) cylinder(d=w,h=999);
        }
        
        //cut out the shell close to the microscope centre to allow the actuator 
        //to protrude below the bottom of the body
        difference(){
            translate([0,-l/2,0]) cube([entry_w, wall_t*3, 999], center=true);
            //NB we leave the very bottom, to help it stick to the bed.
            foot_ground_plane(tilt=tilt, top=0.5);
        }
        
        //cut out a slot to allow bands to wrap round the outside (useful if too long)
        //NB this should match the height and width of the filleted_bridge below.
        intersection(){
            cube([999, 3, 999],center=true); 
            foot_ground_plane(tilt=tilt, bottom=0.5, top=(h-travel-4) - l/2*tan(tilt)); //set the top/bottom of the slot to be parallel to the print bed, and
                //leave an 0.5mm layer on the bottom to help adhesion.
        }
        
        //round the edges of the above slot, and make an actual hole (i.e. no adhesion
        //layer) for the elastic bands to sit in.  Rounded edges should help strength
        //and avoid damaging the bands.  NB width should match the band anchor above,
        //and height/span should match the slot above.
        skew_flat(tilt) translate([0,0,h-travel-4-2]){
            filleted_bridge([2*column_base_radius()+1.5, 3, 2], roc_xy=4, roc_xz=3);
        }
        
        //cut off the foot below the "ground plane" (i.e. print bed)
        foot_ground_plane(tilt, top=0);
    }
}
//foot(tilt=15);
//foot(tilt=0,hover=2);

reflect([0,1,0]) translate([0,ss_outer()[1]+3, 0]) foot(tilt=15, lie_flat=true);
foot(tilt=0,hover=2, lie_flat=true);