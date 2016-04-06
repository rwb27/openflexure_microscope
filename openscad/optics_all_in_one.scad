/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Optics unit (single small lens version) *
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
use <cameras/picam_push_fit.scad>;
use <cameras/C270_mount.scad>;
use <dovetail.scad>;

//camera = "C270";
camera = "picamera";


sample_z = 40; //height of the sample above the bottom of the microscope
bottom = -8; //nominal distance from PCB to microscope bottom (was 8, increased to 10)
dt_bottom = -2; //where the dovetail starts (<0 to allow some play)
d = 0.05;

// The camera parameters depend on what camera we're using,
// sorry about the ugly syntax, but I couldn't find a neater way.
camera_angle = (camera=="picamera"?45:
               (camera=="C270"?-45:0));
camera_h = (camera=="picamera"?24:
           (camera=="C270"?53:0));
camera_shift = (camera=="picamera"?2.4:
               (camera=="C270"?(45-53/2):0));

// This needs to match the microscope body (NB this is for the 
// standard-sized version, not the LS version)
objective_clip_w = 10;

$fn=24;

module lighttrap_cylinder(r1,r2,h,ridge=1.5){
    //A "cylinder" made up of christmas-tree-like cones
    //good for trapping light in an optical path
    //r1 is the outer radius of the bottom
    //r2 is the inner radius of the top
    //NB for a straight-sided cylinder, r2==r1-ridge
    n_cones = floor(h/ridge);
    cone_h = h/n_cones;
    
	for(i = [0 : n_cones - 1]){
        p = i/(n_cones - 1);
		translate([0, 0, i * cone_h - d]) 
			cylinder(r1=(1-p)*r1 + p*(r2+ridge),
					r2=(1-p)*(r1-ridge) + p*r2,
					h=cone_h+2*d);
    }
}
module trylinder(r=1, flat=1, h=d, center=false){
    //Halfway between a cylinder and a triangle.
    hull() for(a=[0,120,240]) rotate(a)
        translate([0,flat/sqrt(3),0]) cylinder(r=r, h=h, center=center);
}
module camera(){
    //This creates a cut-out for the camera we've selected
    if(camera=="picamera"){
        picam_push_fit();
    }else{
        C270(beam_r=5,beam_h=6+d);
    }
}

module optical_path(lens_aperture_r, lens_z){
    // The cut-out part of a camera mount, consisting of
    // a feathered cylindrical beam path and a camera mount
    union(){
        rotate(camera_angle) translate([0,0,bottom]) camera();
        // //camera
        translate([0,0,bottom+6]) lighttrap_cylinder(r1=5, r2=lens_aperture_r, h=lens_z-bottom-6+d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_aperture_r,h=2*d); //lens
    }
}

module camera_mount_body(body_r, body_top, dt_top, objective_clip_y, extra_rz = []){
    // Make a camera mount, with a cylindrical body and a dovetail.
    // Just add a lens mount on top for a complete optics module!
    dt_h=dt_top-dt_bottom;
    bottom_r=8;
    union(){
        difference(){
            // This is the main body of the mount
            sequential_hull(){
                rotate(camera_angle) translate([0,camera_shift,bottom]) cube([25,camera_h,d],center=true);
                rotate(camera_angle) translate([0,camera_shift,bottom+1.5]) cube([25,camera_h,d],center=true);
                rotate(camera_angle) translate([0,camera_shift,bottom+4]) cube([25-5,camera_h,d],center=true);
                translate([0,0,dt_bottom]) hull(){
                    cylinder(r=bottom_r,h=d);
                    translate([0,objective_clip_y,0]) cube([objective_clip_w,4,d],center=true);
                }
                translate([0,0,dt_bottom]) cylinder(r=bottom_r,h=d);
                translate([0,0,body_top]) cylinder(r=body_r,h=d);
                // allow for extra coordinates above this, if wanted.
                // this should really be done with a for loop, but
                // that breaks the sequential_hull, hence the kludge.
                if(len(extra_rz) > 0) translate([0,0,extra_rz[0][1]-d]) cylinder(r=extra_rz[0][0],h=d);
                if(len(extra_rz) > 1) translate([0,0,extra_rz[1][1]-d]) cylinder(r=extra_rz[1][0],h=d);
                if(len(extra_rz) > 2) translate([0,0,extra_rz[2][1]-d]) cylinder(r=extra_rz[2][0],h=d);
                if(len(extra_rz) > 3) translate([0,0,extra_rz[3][1]-d]) cylinder(r=extra_rz[3][0],h=d);
            }
            
            // flatten the cylinder for the dovetail
            reflect([1,0,0]) translate([3,objective_clip_y-0.5,dt_bottom]){
                cube(999);
            }
			
        }
        // add the dovetail
        translate([0,objective_clip_y,dt_bottom]){
            dovetail_m([14,objective_clip_y,dt_h],waist=dt_h-15);
        }
    }
}
module lens_gripper(lens_r=10,h=6,lens_h=3.5,base_r=-1,t=0.65){
    // This creates a tapering, distorted hollow cylinder suitable for
    // gripping a small cylindrical (or spherical) object
    // The gripping occurs lens_h above the base, and it flares out
    // again both above and below this.
    $fn=48;
    bottom_r=base_r>0?base_r:lens_r+1+t;
    difference(){
        sequential_hull(){
            translate([0,0,0]) cylinder(r=bottom_r,h=d);
            translate([0,0,lens_h-0.5]) trylinder(r=lens_r-1+t,flat=2.5,h=d);
            translate([0,0,lens_h+0.5]) trylinder(r=lens_r-1+t,flat=2.5,h=d);
            translate([0,0,h-d]) trylinder(r=lens_r-0.5+t,flat=3,h=d);
        }
        sequential_hull(){
            translate([0,0,-d]) cylinder(r=bottom_r-t,h=d);
            translate([0,0,lens_h-0.5]) trylinder(r=lens_r-1,flat=2.5,h=d);
            translate([0,0,lens_h+0.5]) trylinder(r=lens_r-1,flat=2.5,h=d);
            translate([0,0,h]) trylinder(r=lens_r-0.5,flat=3,h=d);
        }
    }
}
module rms_mount_and_tube_lens_gripper(){
    // This assembly holds an RMS objective and a correcting
    // "tube" lens.
    union(){
        lens_gripper(lens_r=rms_r, lens_h=lens_assembly_h-2.5,h=lens_assembly_h, base_r=lens_assembly_base_r);
        lens_gripper(lens_r=tube_lens_r, lens_h=3.5,h=6);
        difference(){
            cylinder(r=tube_lens_aperture + 1.0,h=2);
            cylinder(r=tube_lens_aperture,h=999,center=true);
        }
    }
}

/////////// Cover for camera board //////////////
module picam_cover(){
    // A cover for the camera PCB, slips over the bottom of the camera
    // mount.
    start_y=-12+2.4;//-3.25;
    l=-start_y+12+2.4; //we start just after the socket and finish at 
    //the end of the board - this is that distance!
    difference(){
        union(){
            //base
            translate([-15,start_y,-4.3]) cube([25+5,l,4.3+d]);
            //grippers
            reflect([1,0,0]) translate([-15,start_y,0]){
                cube([2,l,4.5-d]);
                hull(){
                    translate([0,0,1.5]) cube([2,l,3]);
                    translate([0,0,4]) cube([2+2.5,l,0.5]);
                }
            }
        }
        translate([0,0,-1]) picam_pcb_bottom();
        //chamfer the connector edge for ease of access
        translate([-999,start_y,0]) rotate([-135,0,0]) cube([9999,999,999]);
    }
} 



module optics_module_single_lens(lens_outer_r, lens_aperture_r, lens_t, parfocal_distance){
    // This is the "classic" optics module, using the raspberry pi lens
    // It should be fitted to the smaller microscope body
    
    // Lens parameters are passed as arguments.
    ///picamera lens
    //lens_outer_r=3.04+0.2; //outer radius of lens (plus tape)
    //lens_aperture_r=2.2; //clear aperture of lens
    //lens_t=3.0; //thickness of lens
    //parfocal_distance = 6; //rough guess!
    
    // Maybe there should be a way to switch between LS and standard?
    dovetail_top = 27; //height of the top of the dovetail
    sample_z = 40; // height of the sample above the bottom of the microscope
    body_r = 8; // radius of the main part of the mount
    lens_z = sample_z - parfocal_distance; // position of lens
    neck_r=max( (body_r+lens_aperture_r)/2, lens_outer_r+1);
    neck_z = sample_z-5-2; // height of top of neck
    
    union(){
        // the bottom part is a camera mount, tapering to a neck
        difference(){
            // camera mount body, with a neck on top via extra_rz
            camera_mount_body(body_r=8, body_top=dovetail_top, dt_top=dovetail_top, objective_clip_y=6, extra_rz=[[neck_r,neck_z],[neck_r,lens_z+lens_t]]);
            // hole through the body for the beam
            optical_path(lens_aperture_r, lens_z);
            // cavity for the lens
            translate([0,0,lens_z]) cylinder(r=lens_outer_r,h=999);
        }
    }
}

module optics_module_rms(tube_lens_ffd=16.1, tube_lens_f=20, 
    tube_lens_r=16/2+0.2, objective_parfocal_distance=35){
    // This optics module takes an RMS objective and a 20mm focal length
    // correction lens.
    rms_r = 20/2; //radius of RMS thread, to be gripped by the mount
    //tube_lens_r (argument) is the radius of the tube lens
    //tube_lens_ffd is the front focal distance (from flat side to focus)
    //tube_lens_f is the nominal focal length of the tube lens.
    tube_lens_aperture = tube_lens_r - 1.5; // clear aperture of above
    pedestal_h = 2; //height of tube lens above bottom of lens assembly
    
    dovetail_top = 27; //height of the top of the dovetail
    sample_z = 70; // height of the sample above the bottom of the microscope (depends on size of microscope)
    
        
    //we need to shift the tube lens so that it focuses the
        //already-converging light from the objective:
    tube_lens_shift = tube_lens_f - 1/(1/tube_lens_f+1/160);
    tube_lens_z = bottom + tube_lens_ffd - tube_lens_shift;
    lens_assembly_z = tube_lens_z - pedestal_h; //height of lens assembly
    lens_assembly_base_r = rms_r+1; //outer size of the lens grippers
    lens_assembly_h = sample_z-lens_assembly_z-objective_parfocal_distance; //the
        //objective sits parfocal_distance below the sample
    union(){
        // The bottom part is just a camera mount with a flat top
        difference(){
            // camera mount with a body that's shorter than the dovetail
            camera_mount_body(body_r=lens_assembly_base_r, body_top=lens_assembly_z, dt_top=dovetail_top, objective_clip_y=12);
            // camera cut-out and hole for the beam
            optical_path(tube_lens_aperture, lens_assembly_z);
            // make sure it makes contact with the lens gripper, but
            // doesn't foul the inside of it
            hull() intersection(){
                 translate([0,0,lens_assembly_z]) lens_gripper(lens_r=rms_r-d, lens_h=lens_assembly_h-2.5,h=lens_assembly_h, base_r=lens_assembly_base_r-d); //same as the big gripper below
                cylinder(r=999,h=dovetail_top+d,$fn=8);
            }
            
        }
        // A pair of nested lens grippers to hold the objective
        translate([0,0,lens_assembly_z]){
            // gripper for the objective
            lens_gripper(lens_r=rms_r, lens_h=lens_assembly_h-2.5,h=lens_assembly_h, base_r=lens_assembly_base_r);
            // gripper for the tube lens
            lens_gripper(lens_r=tube_lens_r, lens_h=3.5,h=6);
            // pedestal to raise the tube lens up within the gripper
            difference(){
                cylinder(r=tube_lens_aperture + 1.0,h=2);
                cylinder(r=tube_lens_aperture,h=999,center=true);
            }
        }
    }
}

/*/ Optics module for pi camera, with standard stage (i.e. the classic)
optics_module_single_lens(
    ///picamera lens
    lens_outer_r=3.04+0.2, //outer radius of lens (plus tape)
    lens_aperture_r=2.2, //clear aperture of lens
    lens_t=3.0, //thickness of lens
    parfocal_distance = 6 //sample to bottom of lens
);//*/
// Optics module for RMS objective
intersection(){
    optics_module_rms(tube_lens_ffd=16.1, tube_lens_f=20, 
    tube_lens_r=16/2+0.2, objective_parfocal_distance=35);
//    cube([999,999,40],center=true);
}//*/
//picam_cover();
