/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Camera mount                            *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines the camera mount module, as well as two       *
* functions that return the height of the module and the position *
* of the sensor within that module.  It picks between the various *
* supported cameras using the "camera" variable.                  *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

include <../microscope_parameters.scad>;
use <./logitech_c270.scad>;
use <./picamera_2.scad>;
use <./m12.scad>;
use <./6led.scad>;

// If I was able to selectively include different files, this wouldn't be needed.
// However, doing this saves the faff of precompiling the SCAD source with some
// dodgy ad-hoc script, and is probably the best compromise.  The ternary operator
// is necessary as proper if statements aren't currently allowed in OpenSCAD functions.

// See the function below for valid values of "camera".

function camera_mount_height() =
    // the height of the camera mount - above this comes the optics module.
    camera=="logitech_c270"?c270_camera_mount_height()
    :(camera=="m12"?m12_camera_mount_height()
    :(camera=="6led"?6led_camera_mount_height()
    :picamera_2_camera_mount_height()
    ));
function camera_sensor_height() =
    // the height of the camera mount - above this comes the optics module.
    camera=="logitech_c270"?c270_camera_sensor_height()
    :(camera=="m12"?m12_camera_sensor_height()
    :(camera=="6led"?6led_camera_sensor_height()
    :picamera_2_camera_sensor_height()
    ));
module camera_mount(counterbore=false){
    if(camera=="logitech_c270") c270_camera_mount();
    else if(camera=="m12") m12_camera_mount();
    else if(camera=="6led") 6led_camera_mount();
    else picamera_2_camera_mount(counterbore=counterbore);
}
module camera_bottom_mounting_posts(h=-1, r=-1, outers=true, cutouts=true){
    if(camera=="logitech_c270") c270_bottom_mounting_posts();
    else if(camera=="m12") m12_bottom_mounting_posts();
    else if(camera=="6led") 6led_bottom_mounting_posts(height=h, radius=r, outers=outers, cutouts=cutouts);
    else picamera_2_bottom_mounting_posts(height=h, radius=r, outers=outers, cutouts=cutouts);
}

echo(str("Camera mount height: ",camera_mount_height()));
echo(str("Camera sensor height: ",camera_mount_height()));
camera_mount();