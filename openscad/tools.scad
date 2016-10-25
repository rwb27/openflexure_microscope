/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Tools to help remove the pi camera lens *
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

d=0.05;

pcb = [25.4+0.5,24+0.5,2]; //size of the picam PCB (+0.5mm so it fits)
camera_housing = [9,9,2.5]; //size of the plastic housing
camera_housing_y = 2.5; //shift of the camera housing from the centre
lens_unscrew_r = 5.5/2; //size of the bit we unscrew
    
module generous_camera_bits(){
    //The other stuff on the PCB (mostly the ribbon cable)
    camera = [8.5,8.5,2.3]; //size of camera box
	cw = camera[0]+1; //side length of camera box at bottom (slightly larger)
	union(){
		//ribbon cable at top of camera
        sequential_hull(){
            translate([0,0,0]) cube([cw-1,d,4],center=true);
            translate([0,9.4-(4.4/1)/2,0]) cube([cw-1,1,4],center=true);
        }
        //flex connector
        translate([-1.25,9.4,0]) cube([cw-1+2.5, 4.4+1, 4],center=true);
        
	}
}

module picam2_gripper(){
    // this little bit of plastic grips the plastic camera housing
    // and allows you to safely unscrew the lens
    // it protects the (surprisingly delicate) flex that connects the camera to the PCB.
    outer = pcb+[4,-5,camera_housing[2]]; //size of the tool
    difference(){
        translate([0,-1,outer[2]/2]) cube(outer, center=true);
        
        //central hole for the camera housing
        translate([0,camera_housing_y,0]) cube(camera_housing + [0,0,999],center=true);
        
        //cut-outs for the other bits (cable etc.)
        translate([0,camera_housing_y,camera_housing[2]]) rotate([180,0,0]) generous_camera_bits();
        
        //indent for PCB
        translate([0,0,outer[2]]) cube(pcb + [0,0,pcb[2]],center=true);
    
    }
}

module picam_lens_gripper(){
    //a tool to unscrew the lens from the pi camera
    inner_r = 4.7/2;
    union(){
        difference(){
            cylinder(r=7,h=2);
            cylinder(r=5,h=999,center=true);
        }
        for(a=[0,90,180,270]) rotate(a) translate([inner_r,0,0]) cube([1.5,5,2]);
    }
}

module hold_gear_10mm_higher(){
    union(){
        difference(){
            cylinder(r=6,h=10,$fn=24);
            cylinder(r=3,h=999,center=true,$fn=12);
            translate([-999,0,-999]) cube([1,1,1]*9999);
        }
        reflect([1,0,0]) translate([4.5,0,0]) hull()
            repeat([0,3,0],2) cylinder(r=1.5,h=10,$fn=12);
    }
}
//hold_gear_10mm_higher();
//translate([pcb[0]/2+15,pcb[1]/2,0]) 
picam2_gripper();
//picam_lens_pliers();
//picam_lens_gripper();
