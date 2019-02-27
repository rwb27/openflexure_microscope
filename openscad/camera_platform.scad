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
        // cable routing, if needed
        //rotate(135) translate([-2,0,0.5]) cube([4,999,999]);
    }
}

camera_platform(5, z_flexures_z2);