/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Z axis                                  *
*                                                                 *
* This is the Z axis for the OpenFlexure Microscope.              *
* It also contains the fitting for the optics module to attach    *
* it to the objective mount, as the objective mount is part of    *
* the Z axis assembly.                                            *
*                                                                 *
* (c) Richard Bowman, January 2018                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/
/*

The Z axis assembly is a 4-bar mechanism, kept as short as possible
to maximise stiffness.  It's constructed in several parts:
objective_mount() is the wedge-shaped rail to which the optics attach
z_axis_flexures() makes the thin parts that flex as it is moved
z_axis_struts() makes the two connections between the objective_mount()
                and the static part

*/

use <./utilities.scad>;
use <./compact_nut_seat.scad>;
use <./main_body_transforms.scad>;
use <./wall.scad>;
use <./gears.scad>;
use <./illumination.scad>;
include <./microscope_parameters.scad>;

module each_om_contact_plane(){
    // This transform puts y=0 in the plane of contact between the
    // optics module and the mount for it, with the origin at the
    // nominal corner of the wedge.
    reflect([1,0,0]) translate([-objective_mount_nose_w/2,objective_mount_y,0])
                rotate(135) children();
}

module objective_mount(){
    // The fitting to which the optics module is attached
    h = z_flexures_z2 + 4*sqrt(2);
    overlap = 4; // we have this much contact between 
                 // the mount and the wedge on the optics module.
    roc=1.5; // radius of curvature of the arms
    w = objective_mount_nose_w + 2*overlap + 4;//+2*roc; //overall width
    difference(){
        hull(){
            // the back of the mount
            translate([-w/2,objective_mount_back_y+5,0]) cube([w,d,h]);
            //hull() reflect([1,0,0]) z_bridge_wall_vertex();
            // the front of the mount (this makes contact with the optics module)
            each_om_contact_plane() translate([0,overlap-d,0]) cube([2*roc,d,h]);
        }
        
        // bolt slot to mount objective
        hull(){
            translate([0,0,z_flexures_z1+8]) rotate([-90,0,0]) cylinder(d=3.5, h=999);
            translate([0,0,z_flexures_z2-5]) rotate([-90,0,0]) cylinder(d=3.5, h=999);
        }
        // make the bolt slot keyhole-shaped to allow the screw to be easily inserted
        translate([0,0,z_flexures_z1+6]) rotate([-90,0,0]) cylinder(d=6.5, h=999);
        
        
        objective_fitting_wedge(h=999,nose_shift=-0.25,center=true);
        
        // cut-outs for flexures to attach
        hull() reflect([1,0,0]) translate([1, d, -4])  z_axis_flexures(h=5+8);
        
        // cut out the back so it fits in the available space
        reflect([1,0,0]) translate([-z_flexure_x,0,-99]) rotate(45) cube(999);
    }
    // Nice rounded fronts either side
    each_om_contact_plane() translate([roc,overlap,0]) cylinder(r=roc,h=h);
}

function objective_mount_screw_pos() = [0, objective_mount_back_y, (z_flexures_z2 + z_flexures_z1)/2];

module objective_mount_screw(){
    translate(objective_mount_screw_pos()) rotate([-90,0,0]){
        cylinder(r=3, h=2.5);
        mirror([0,0,1]) cylinder(d=3, h=12);
    }
}

module objective_fitting_wedge(h=z_flexures_z2+4, nose_shift=0.2, center=false){
    // A trapezoidal wedge that clamps onto the objective mount.  
    // NB you must subtract the objective_fitting_cutout from this to allow
    // the screw and nut to be attached.
    // NB nose_shift moves the tip of the wedge in the -y direction (i.e. increases
    // the gap at the tip, if we are making the optics module).  If subtracting this
    // to make a mount for the optics module, use nose_shift < 0
    nw = objective_mount_nose_w; //width of the pointy end
    translate([0,objective_mount_y,0]) mirror([0,1,0]) hull(){
        translate([-nw/2-nose_shift,nose_shift,center?-h/2:0]) cube([nw+2*nose_shift,d,h]);
        reflect([1,0,0]) translate([-nw/2-5+sqrt(2), 5+sqrt(2), 0]) 
                cylinder(r=2, h=h, $fn=16, center=center);
    }
}

module ofc_nut(shaft=false, max_screw=12){
    // For convenience, this is the nut that we use to hold the optics module on.
    // it is used from objective_fitting_cutout only.
    nut_y(3, h=2.5, extra_height=0, shaft=shaft, shaft_length=shaft?max_screw-4:0);
}

module objective_fitting_cutout(max_screw=12, y_stop=false, nose_shift=0.2){
    // Subtract this from the optics module, to cut out a hole for the nut
    // that anchors it to the objective mount.
    // TODO: also relieve the faces of the mount in case there are protrusions
    oms = objective_mount_screw_pos();
    translate([oms[0], objective_mount_y - 1.2 - 2.5, oms[2]]){
        ofc_nut(shaft=true, max_screw=max_screw);
        sequential_hull(){
            ofc_nut();
            translate([0,0,7]) ofc_nut();
            translate([0,10,7]) repeat([0,0,10],2) ofc_nut();
        }
    }
    if(y_stop) translate([-10,objective_mount_y-nose_shift,-99])cube([20,999,999]); 
}

module z_axis_flexure(h=zflex[2], z=0){
    // The parts that bend as the Z axis is moved
    union(){
        reflect([1,0,0]) hull(){
            translate([-zflex[0]-1,objective_mount_back_y-d,z]) cube([zflex[0],d,h]);
            translate([-z_anchor_w/2,z_anchor_y,z]) cube([zflex[0],d,h]);
        }
    }
}
module z_axis_flexures(h=zflex[2]){
    // The parts that bend as the Z axis is moved
    for(z=[z_flexures_z1, z_flexures_z2]){
        z_axis_flexure(h=h, z=z);
    }
}

module z_axis_struts(){
    // The parts that tilt as the Z axis is moved, including the lever that 
    // connects to the actuator column (but not the column itself).
    intersection(){ // The two horizontal parts
        for(z=[z_flexures_z1, z_flexures_z2]) hull(){
            translate([-99,objective_mount_back_y+zflex[1],z+dz]) cube([999,z_strut_l,1]);
            translate([-99,objective_mount_back_y+zflex[1]+3,z+dz]) cube([999,z_strut_l-6,5]);
        }
        hull() z_axis_flexures(h=999);
    }
    // The link to the actuator
    w = column_base_radius() * 2;
    lever_h = 6;
    difference(){
        sequential_hull(){
            translate([0, z_nut_y, 0]) cylinder(d=w, h=lever_h);
            translate([0, z_anchor_y + w/2 + 2, 0]) cylinder(d=w, h=z_flexures_z1+2*dz);
            translate([-w/2, z_anchor_y - zflex[0] - d, z_flexures_z1 + dz]) cube([w,d, 5-d]);
        }
        translate([0, z_nut_y, 0]) actuator_end_cutout();
    }
}

module pivot_z_axis(angle){
    // Pivot the children around the point where the Z axis pivots
    // The Y value for the pivot is z_anchor_y
    // Because the rotation is small we can approximate with
    // shear; this means the whole axis moves as intended rather
    // than rotating about a particular height (i.e. both flexures
    // pivot about the right y value).
    smatrix(zy=sin(angle), zt=-sin(angle)*z_anchor_y) children();
}

module z_axis_clearance(){
    // Clearance for the moving part of the Z axis
    for(a=[-6,0,6]) pivot_z_axis(a) minkowski(){
        cylinder(r=1, h=4, center=true, $fn=8);
        z_axis_struts();
    }
}

module objective_mounting_screw_access(){
    // access hole for the objective mounting screw
    //translate([0,objective_mount_back_y, z_flexures_z2/2]) 
    //        rotate([-75,0,0]) cylinder(h=999, d=8, $fn=16);
    translate([0,objective_mount_back_y, z_flexures_z2/2]) hull(){
        rotate([-90,0,15]) cylinder(h=999, d=8, $fn=16);
        translate([0,0,6]) rotate([-90,0,0]) cylinder(h=d, d=4, $fn=16);
    }
}

module z_motor_clearance(){
    // clearance for the motor and gears, to be subtracted from the condenser mount
    translate([0,z_nut_y,0]) rotate([z_actuator_tilt,0,0]) 
        translate([0,0,actuator_h+z_actuator_travel+2-1]) rotate(180) motor_and_gear_clearance(gear_h=11);
}

module z_axis_casing(condenser_mount=false){
    // Casing for the Z axis - needs to have the axis subtracted from it
    intersection(){
        linear_extrude(h=999) minkowski(){
            circle(r=wall_t+1);
            hull() projection() z_axis_struts();
        }
        hull(){
            reflect([1,0,0]) z_bridge_wall_vertex();
            translate([-99,z_anchor_y,0]) cube([999,4,z_flexures_z2+2]);
            translate([0,z_nut_y,0]) cylinder(d=10,h=20);
        }
    }
    if(condenser_mount) hull(){
        // At the bottom, connect to the top of the housing and the motor lugs
        translate([-z_anchor_w/2-1.5, z_anchor_y - 1, z_flexures_z2]) cube([z_anchor_w+3, d, d]);
        translate([0,z_nut_y,0]) rotate(180) 
                     motor_lugs(h=actuator_h + z_actuator_travel, angle=180, tilt=-z_actuator_tilt);
        // The top is a flat shape that the illumination arm screws onto.
        each_illumination_arm_screw() mirror([0,0,1]) cylinder(r=5,h=7);
    }
    
}

module z_axis_casing_cutouts(){
    // The Z axis casing is a solid shape, we need to cut out clearance for the moving bits
    // This module contains all the bits we need to cut out.
    z_axis_clearance();
    objective_mounting_screw_access();
    z_actuator_cutout();
    z_motor_clearance();
    reflect([1,0,0]) right_illumination_arm_screw(){
        trylinder_selftap(3, h=16, center=true); 
        hull() rotate(110) repeat([100,0,0],2) translate([0,0,-6]) cylinder(d=6.9,h=2.8,$fn=6);
    }
}

////////////// These modules define the actuator column and housing (where the screw/nut/band go)

module z_actuator_column(){
    translate([0,z_nut_y,0]) actuator_column(actuator_h, tilt=z_actuator_tilt, join_to_casing=true);
}

module z_actuator_housing(){
    // This houses the actuator column and provides screw seat/motor lugs
    translate([0,z_nut_y,0]) screw_seat(h=actuator_h, 
                                        tilt=z_actuator_tilt, 
                                        travel=z_actuator_travel, 
                                        motor_lugs=motor_lugs, 
                                        lug_angle=180);
}
module z_actuator_cutout(){
    // This chops out a void for the actuator column
    translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true, tilt=z_actuator_tilt);
}


// "scenery" so we can see how it fits with the rest of the microscope
//legs
// for(a=[-45,45]) rotate(a) translate([-leg_outer_w/2,leg_r,0]) cube([leg_outer_w, 4, sample_z]);

// These are the moving parts of the axis
objective_mount();
//z_axis_flexures();
//z_axis_struts();
//z_actuator_column();

// The casing needs to have voids subtracted from it to fit the moving bits in
difference(){
    z_axis_casing(condenser_mount=true);
    z_axis_casing_cutouts();
}

// We add on the actuator housing last, because it's got the clearance subtracted already.
//z_actuator_housing();
//*/
// This is what fits onto it
//translate([0,-1.5,0])
//difference(){
//    objective_fitting_wedge(nose_shift=0.2);
//    objective_fitting_cutout();
//}
//objective_mount_screw();
