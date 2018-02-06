/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Z axis                                  *
*                                                                 *
* This is the Z axis for the OpenFlexure Microscope.              *
*                                                                 *
* (c) Richard Bowman, January 2018                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
use <compact_nut_seat.scad>;
include <microscope_parameters.scad>;

module objective_mount(){
    // The mount for the objective
    h = z_flexures_z2 + 4;
    difference(){
        translate([0,objective_mount_y,0]) hull(){
            translate([-3,0,0]) cube([6,d,h]);
            reflect([1,0,0]) translate([-3-5+sqrt(2), 5+sqrt(2), 0]) 
                    cylinder(r=2, h=h, $fn=8);
        }
        translate([0,0,h/2]) rotate([-90,0,0]) cylinder(d=3.5, h=999);
        hull() reflect([1,0,0]) translate([1, d, -4])  z_axis_flexures(h=5+8);
    }
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
    // The parts that tilt as the Z axis is moved
    intersection(){ // The two horizontal parts
        for(z=[z_flexures_z1, z_flexures_z2]){
            translate([-99,objective_mount_back_y+zflex[1],z+dz]) cube([999,z_strut_l,5]);
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

// "scenery"
//legs
for(a=[-45,45]) rotate(a) translate([-leg_outer_w/2,leg_r,0]) cube([leg_outer_w, 4, sample_z]);
    
//actuator
translate([0,z_nut_y,0]){
    screw_seat(h=actuator_h, tilt=z_actuator_tilt, travel=z_actuator_travel, extra_entry_h=z_strut_t+2, motor_lugs=motor_lugs);
    actuator_column(actuator_h, tilt=z_actuator_tilt);
}

objective_mount();
z_axis_flexures();
z_axis_struts();
reflect([1,0,0]) z_axis_anchor();