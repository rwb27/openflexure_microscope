/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope body wall                    *
*                                                                 *
* This defines utility functions to create the "wall" around the  *
* main body of the microscope.                                    *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/
use <./utilities.scad>;
use <./main_body_transforms.scad>;
use <./compact_nut_seat.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.


module add_hull_base(h=1){
    // Take the convex hull of some objects, and add it in as a
    // thin layer at the bottom
    union(){
        intersection(){
            hull() children();
            cylinder(r=9999,$fn=8,h=h); //make the base thin
        }
        children();
    }
}
module add_roof(inner_h){
    // Take the convex hull of some objects, and add the top
    // of it as a roof.  NB you must specify the height of
    // the underside of the roof - finding it automatically
    // would be too much work...
    union(){
        difference(){
            hull() children();
            cylinder(r=9999,$fn=8,h=inner_h);
        }
        children();
    }
}
module wall_vertex(r=wall_t/2, h=wall_h, x_tilt=0, y_tilt=0){
    // A cylinder, rotated by the given angles about X and Y,
    // but with the top and bottom kept in the XY plane
    // (i.e. it's sheared rather than tilted).    These form the
    // stiffening "wall" that runs around the base of 
    // the legs
    smatrix(xz=tan(y_tilt), yz=-tan(x_tilt)) cylinder(r=r, h=h, $fn=8);
}
module inner_wall_vertex(leg_angle, x, h=wall_h, y_tilt=-999, y=-zflex_l-wall_t/2){
    // A thin cylinder, close to one of the legs.  It
    // tilts inwards to clear the leg.  These form the
    // stiffening "wall" that runs around the base of 
    // the legs
    
    // leg_angle specifies the leg, x is the X position
    // of the vertex in that leg frame.  h is its height,
    // y and y_tilt override position and angle in y
    
    // unless specified, tilt the leg so the wall at the
    // edge is vertical (i.e. the bit at 45 degrees to
    // the leg frame)
    y_tilt = (y_tilt==-999) ? (x>0?6:-6) : y_tilt;
    leg_frame(leg_angle) translate([x,y,0]){
            wall_vertex(h=h,x_tilt=6,y_tilt=y_tilt);
    }
}

module z_bridge_wall_vertex(){
    // This is the vertex of the "inner wall" nearest the
    // new (cantilevered) Z axis.
    inner_wall_vertex(45, leg_outer_w/2+wall_t/2, zbwall_h);
}

module z_anchor_wall_vertex(){
    // This is the vertex of the supporting wall nearest
    // to the Z anchor - it doesn't make sense to use the
    // function above as it's got the wrong symmetry.
    // We also use this in a few places so it's worth saving
    translate([-z_flexure_x-wall_t/2,-wall_t/2,0]){
        wall_vertex(h=zawall_h, y_tilt=atan(wall_t/zawall_h));
    }
}

module y_actuator_wall_vertex(x=1){
    // A wall vertex for the y actuator.  x=-1,1 picks the side
    // of the actuator where the vertex is placed.
    leg_frame(45) translate([x*(ss_outer()[0]/2-wall_t/2),
                             actuating_nut_r, 0]) wall_vertex();
}