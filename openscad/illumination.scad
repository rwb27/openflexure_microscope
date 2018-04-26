/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination                            *
*                                                                 *
* The illumination module includes the condenser lens mounts and  *
* the arm that holds them.                                        *
*                                                                 *
* (c) Richard Bowman, April 2018                                  *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;
include <./microscope_parameters.scad>;

module each_illumination_arm_screw(){
    // A transform to repeat objects at each mounting point
    for(p=illumination_arm_screws) translate(p) children();
}