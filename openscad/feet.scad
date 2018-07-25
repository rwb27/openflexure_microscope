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
use <endstop.scad>
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
module thick_section(h=d, center=false, shift=true){
    // A 3D object, corresponding to the linearly-extruded projection of another object.
    linear_extrude(h, center=center) projection(cut=true) translate([0,0,shift?-d:0]) children();
}
module offset_thick_section(h=d, offset=0, center=false, shift=true){
    // A 3D object, corresponding to the linearly-extruded projection of another object.
    linear_extrude(h, center=center) offset(r=offset) projection(cut=true) translate([0,0,shift?-d:0]) children();
}

module foot_section(foot_angle=0,    //the angle the actuator column makes with the Z axis
                    section_angle=0, //the angle between the section and the XY plane
                    offset=0,        //grow the section by this much
                    h=d,             //thickness
                    z=0){
    intersection(){
        translate([0,0,z]) rotate([section_angle,0,0]) cube([999,999,h],center=true);
        rotate([foot_angle,0,0]) offset_thick_section(h=9999, center=true, offset=offset) children();
    }
}

module foot(travel=5,       // how far into the foot the actuator can move down
            bottom_tilt=0,  // the angle of the bottom of the foot
            hover=0,        // distance between the foot and the ground
            actuator_tilt=0,// the angle of the top of the foot
            entry_w=2*column_base_radius()+3, 
            lie_flat=true){
    w = ss_outer()[0]; //size of the outside of the screw seat column
    l = ss_outer()[1];
    cw = column_core_size()[0]; //size of the inside of the screw seat column
    cl = column_core_size()[1];
    wall_t = (w-cw)/2; //thickness of the wall
    h = foot_height - hover; //defined in parameters.scad, set hover=2 to not touch ground
    tilt = bottom_tilt - actuator_tilt; //the angle of the ground relative to the axis of the foot
    // The following transforms will either make the foot "in place" (i.e. the top is z=0) or
    // printable (i.e. with the bottom on z=0).
    translate([0,(lie_flat?(l/2*tan(tilt)*sin(actuator_tilt)):h*tan(actuator_tilt)),0])
    rotate([lie_flat?tilt:0,0,0]) //the foot base may be tilted, lie_flat makes this z=0
    translate([0,0,lie_flat?-l/2*tan(tilt):-h]) //makes the bottom z=0
    difference(){
        union(){
            foot_section(actuator_tilt, 0, h=2*h) screw_seat_shell(); //main part of foot
            foot_section(actuator_tilt, 0, h=2*h+3) nut_seat_void(); //lugs on top
        }
        //hollow out the inside
        difference(){
            //the core tapers at the top to support the lugs
            sequential_hull(){
                foot_section(actuator_tilt, 0, z=-999) nut_seat_void();
                foot_section(actuator_tilt, 0, z=h-4) nut_seat_void();
                foot_section(actuator_tilt, 0, offset=-wall_t, z=h) nut_seat_void();
                foot_section(actuator_tilt, 0, offset=-wall_t, z=999) nut_seat_void();
            }
            //we double-subtract the anchor for the bands at the bottom, so that it
            //doesn't protrude outside the part.
            cube([2*column_base_radius()+1.5, 999, 2*(h-travel-0.5)],center=true); 
        }
        //cut out the core again, without tapering, in the middle (to make two lugs,
        //one on either side - rather than a ring around the top.
        intersection(){
            cube([cw-3.3*2, 999, 999],center=true);
            foot_section(actuator_tilt, 0, h=999, z=999/2+h-travel+1) nut_seat_void();
        }
        
        //cut out the shell close to the microscope centre to allow the actuator 
        //to protrude below the bottom of the body
        difference(){
            rotate([actuator_tilt,0,0]) translate([0,-l/2,0]) cube([entry_w, wall_t*3, 999], center=true);
            //NB we leave the very bottom, to help it stick to the bed.
            foot_ground_plane(tilt=tilt, top=0.5);
        }
        
        //cut out a slot to allow bands to wrap round the outside 
        //(this is useful if the available bands are too long)
        //NB this should match the height and width of the filleted_bridge below.
        intersection(){
            rotate([actuator_tilt,0,0]) cube([999, 4, 999],center=true); 
            foot_ground_plane(tilt=tilt, bottom=0.5, top=(h-travel-4) - l/2*tan(tilt)-endstop_extra_ringheight); //set the top/bottom of the slot to be parallel to the print bed, and
                //leave an 0.5mm layer on the bottom to help adhesion.
        }
        
        //round the edges of the above slot, and make an actual hole (i.e. no adhesion
        //layer) for the elastic bands to sit in.  Rounded edges should help strength
        //and avoid damaging the bands.  NB width should match the band anchor above,
        //and height/span should match the slot above.
        skew_flat(bottom_tilt) rotate([actuator_tilt,0,0]) translate([0,0,h-travel-4-2-endstop_extra_ringheight]){
            filleted_bridge([2*column_base_radius()+1.5, 4, 2], roc_xy=4, roc_xz=3);
        }
        //cut off the foot below the "ground plane" (i.e. print bed)
        foot_ground_plane(tilt, top=0);

        //TODO: check properly parametrized
        
        if(feet_endstops){           
            translate([0,0.5-(h-travel)*sin(actuator_tilt),h-travel-endstop_hole_offset]) rotate([0,0,-90]) scale([1.03,1.08,1])endstop_hole(actuator_tilt);
          }
    } 
    
}   
//foot(tilt=15);
//foot(tilt=0,hover=2);

module middle_foot(lie_flat=false){
        foot(travel=z_actuator_travel,bottom_tilt=0, actuator_tilt=z_actuator_tilt, hover=2, lie_flat=lie_flat);
}

module outer_foot(lie_flat=false){
    foot(travel=xy_actuator_travel-avoid_objective_xyfoot_offset,bottom_tilt=15, lie_flat=lie_flat);
}

module feet_for_printing(lie_flat=true){
    reflect([1,0,0]) translate([ss_outer()[0]+1.5, 0]) outer_foot(lie_flat=lie_flat);
    middle_foot(lie_flat=lie_flat);
}
//outer_foot(lie_flat=true);
//foot(bottom_tilt=0, actuator_tilt=0, hover=2, lie_flat=true);
feet_for_printing(lie_flat=true);
//middle_foot();
//translate([20,0,0])rotate([90,0,0]) endstop_switch();
//translate([0,30,0]) feet_for_printing(lie_flat=false);
