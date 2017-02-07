/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope Feet                         *
*                                                                 *
* This file generates the feet for the microscope                 *
*                                                                 *
* (c) Richard Bowman, January 2017                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
* http://www.github.com/rwb27/openflexure_microscope              *
* http://www.docubricks.com/projects/openflexure-microscope       *
* http://www.waterscope.org                                       *
*                                                                 *
******************************************************************/
use <utilities.scad>;
use <compact_nut_seat.scad>;

reflect([0,1,0]) translate([0,-ss_outer()[1]-2, 0]) foot(tilt=15, lie_flat=true);
foot(tilt=0,hover=2, lie_flat=true);