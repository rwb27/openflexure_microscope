/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Riser to mount sample slightly higher   *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <utilities.scad>;
include <microscope_parameters.scad>;

sep = 26;
$fn=24;

slide = [75.8,25.8,1.0];
h = 10;
size = slide + [1,1,0]*8*2 + [0,0,h+1];

module slide_riser(){
    difference(){
        translate([-size[0],-size[1],0]/2) cube(size);
        
        //cut-out for slide
        hull() translate([-slide[0]/2,-slide[1]/2,h]){
            translate(-[1,1,0]*slide[2]/2) cube([999,999,d]);
            translate([1,1,2]*999+[0,0,slide[2]]) cube([999,999,d]);
        }
        
        //mounting holes
        reflect([1,0,0]) reflect([0,1,0]) rotate(-45) translate([leg_middle_w/2,leg_r-zflex_l-4,2]){
            cylinder(r=3/2*1.15,h=999,center=true); //mounting holes
            cylinder(r=3*1.15,h=999); //mounting holes
        }
        
        //central hole
        cylinder(r=hole_r,h=999,center=true, $fn=32);
        
        //mounting holes at the side
        translate([size[0]/2,0,h/2]) repeat([0,8,0], floor(size[1]/8-1), center=true){
           rotate([0,90,0]) cylinder(r=3/2*0.95, h=16,center=true);
        }
    } 
       
}

module slide_clip(){
    translate([slide[0]/2,slide[1]/2,h+d/2]) rotate(45) hull(){
        // this part clamps the slide
        cube([7,8,d],center=true);
        translate([0,0,slide[2]+1-d/2]) cube([7+2+2*slide[2],8,d],center=true);
    }
    
    difference(){
        // Mounting plate
        translate([size[0]/2,-8*2,0]) cube([4,8*2,size[2]]);
        
        // mounting holes at the side
        translate([size[0]/2,0,h/2]) repeat([0,8,0], floor(size[1]/8-1), center=true){
           rotate([0,90,0]) cylinder(r=3/2*1.1, h=16,center=true);
        }
    }
    
    // join the two with a curve.  It goes 45 degrees.  
    // it passes the point [slide[0],slide[1],h]/2 and also [size[0]/2+1,?,h]
    // the change in X over 45 degrees is equal to (1-sqrt(2)) of
    // the radius, so 
    dx = size[0]/2+1 - slide[0]/2;
    roc = dx/(1-1/sqrt(2));
    echo(roc);
    translate([size[0]/2+1-roc, slide[1]/2-roc/sqrt(2),h]) difference(){
        intersection(){
            cylinder(r=roc+1, h=size[2]-h, $fn=32);
            linear_extrude(999) polygon([[0,0],[1,0],[1,1]]*999);
        }
        cylinder(r=roc-1,h=999,center=true,$fn=32);
    }
}

//slide_riser();
rotate([180,0,0]) slide_clip();