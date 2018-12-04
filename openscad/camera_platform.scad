/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Optics unit                             *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* The optics module holds the camera and whatever lens you are    *
* using as an objective - current options are either the lens     *
* from the Raspberry Pi camera module, or an RMS objective lens   *
* and a second "tube length conversion" lens (usually 40mm).      *
*                                                                 *
* See the section at the bottom of the file for different         *
* versions, to suit different combinations of optics/cameras.     *
* NB you set the camera in the variable at the top of the file.   *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
use <dovetail.scad>;
use <z_axis.scad>;
include <microscope_parameters.scad>; // NB this defines "camera" and "optics"
use <thorlabs_threads.scad>;

use <cameras/camera.scad>; // this will define the 2 functions and 1 module for the camera mount, using the camera defined in the "camera" parameter.

dt_bottom = -2; //where the dovetail starts (<0 to allow some play)
camera_mount_top = dt_bottom - 3 - (optics=="rms_f50d13"?11:0); //the 50mm tube lens requires the camera to stick out the bottom.
bottom = camera_mount_top-camera_mount_height(); //nominal distance from PCB to microscope bottom
fl_cube_bottom = optics=="rms_f50d13"?-8:0; //bottom of the fluorescence filter cube
fl_cube_w = 16; //width of the fluorescence filter cube
fl_cube_top = fl_cube_bottom + fl_cube_w + 2.7; //top of fluorescence cube
fl_cube_top_w = fl_cube_w - 2.7;
d = 0.05;
$fn=24;


module optical_path(lens_aperture_r, lens_z){
    // The cut-out part of a camera mount, consisting of
    // a feathered cylindrical beam path.  Camera mount is now cut out
    // of the camera mount body already.
    union(){
        translate([0,0,camera_mount_top-d]) lighttrap_cylinder(r1=5, r2=lens_aperture_r, h=lens_z-camera_mount_top+2*d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_aperture_r,h=2*d); //lens
    }
}
module optical_path_fl(lens_aperture_r, lens_z){
    // The cut-out part of a camera mount, with a space to slot in a filter cube.
    union(){
        translate([0,0,camera_mount_top-d]) lighttrap_sqylinder(r1=5, f1=0,
                r2=0, f2=fl_cube_w-4, h=fl_cube_bottom-camera_mount_top+2*d); //beam path to bottom of cube
        rotate(180) fl_cube_cutout(); //filter cube
        translate([0,0,fl_cube_top-d]) lighttrap_sqylinder(r1=1.5, f1=fl_cube_w-4-3, r2=lens_aperture_r, f2=0, h=lens_z-fl_cube_top+4*d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_aperture_r,h=2*d); //lens
    }
}
    
module lens_gripper(lens_r=10,h=6,lens_h=3.5,base_r=-1,t=0.65,solid=false, flare=0.4){
    // This creates a tapering, distorted hollow cylinder suitable for
    // gripping a small cylindrical (or spherical) object
    // The gripping occurs lens_h above the base, and it flares out
    // again both above and below this.
    trylinder_gripper(inner_r=lens_r, h=h, grip_h=lens_h, base_r=base_r, t=t, solid=solid, flare=flare);
}

module chamfer_bottom_edge(chamfer=0.3, h=0.5){
    difference(){
        children();
        
        minkowski(){
            cylinder(r1=2*chamfer, r2=0, h=2*h, center=true);
            linear_extrude(d) difference(){
                square(9999, center=true);
                projection(cut=true) translate([0,0,-d]) hull() children();
            }
        }
    }
}
  
module camera_mount_top(){
    // A thin slice of the top of the camera mount
    linear_extrude(d) projection(cut=true) camera_mount();
}
module objective_fitting_base(){
    // A thin slice of the mounting wedge that bolts to the microscope body
    linear_extrude(d) projection() objective_fitting_wedge();
}

module camera_platform(
        base_r, //radius of mount body
        h //height of dovetail (camera will be above this by 4mm
    ){
    // Make a camera platform with a dovetail on the side and a platform on the top
    difference(){
        union(){
            // This is the main body of the mount
            sequential_hull(){
                translate([0,0,0]) hull(){
                    cylinder(r=base_r,h=d);
                    objective_fitting_base();
                }
                translate([0,0,h]) hull(){
                    cylinder(r=base_r,h=d);
                    objective_fitting_base();
                    camera_bottom_mounting_posts(h=d);
                }
            }
            
            // add the camera mount
            translate([0,0,h]) camera_bottom_mounting_posts(r=2, h=4);
        }
        
        // fitting for the objective mount
        //translate([0,0,dt_bottom]) objective_fitting_wedge();
        // Mount for the nut that holds it on
        translate([0,0,-4]) objective_fitting_cutout(y_stop=true);
        // add the camera mount
        translate([0,0,h]) camera_bottom_mounting_posts(outers=false, cutouts=true);
    }
}

camera_platform(5, z_flexures_z2);