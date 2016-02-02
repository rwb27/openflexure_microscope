use <utilities.scad>;
use <picam_push_fit.scad>;

///picamera lens
lens_outer_r=3.04+0.2; //outer radius of lens (plus tape)
lens_aperture_r=2.2; //clear aperture of lens
lens_t=3.0; //thickness of lens
parfocal_distance = 6; //rough guess!
//*/
/*//ball lens, 4mm sapphire
lens_outer_r=2+0.2;
lens_aperture_r=1.9;
lens_t=2;
//*/
/*//asphere, 5.6mm diameter (nom)
lens_outer_r=5.5/2+0.2;
lens_aperture_r = 4/2;
lens_t=2.5;
//*/
/*//blu ray lens
lens_outer_r=3.5/2+0.1;
lens_aperture_r = 2.6/2+0.1;
lens_t=0.3;
//*/
/*//EO lens
lens_outer_r=12/2+0.4;
lens_aperture_r = 11/2+0.1;
lens_t=1.5;
//*/

sample_z = 40; //height of the sample above the bottom of the microscope
lens_z = sample_z - parfocal_distance; //bottom of lens
top = lens_z + lens_t; //top of the mount
bottom = -10; //nominal distance from PCB to microscope bottom (was 8, increased to 10)
dt_bottom = -2; //where the dovetail starts (<0 to allow some play)
dt_top = 27;
dt_h=dt_top-dt_bottom;
d = 0.05;
//neck_h=h-dovetail_h;
body_r=8;
neck_r=max( (body_r+lens_aperture_r)/2, lens_outer_r+1.5);
camera_angle = 45;

objective_clip_w = 10;
objective_clip_y = 6;
camera_clip_y = -7;

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
module clip_tooth(h){
	intersection(){
		cube([999,999,h]);
		rotate(-45) cube([1,1,1]*999*2);
	}
}


module optical_path(){
    union(){
        rotate(camera_angle) translate([0,0,bottom]) picam_push_fit_2(); //camera
        translate([0,0,bottom+6]) lighttrap_cylinder(r1=5, r2=lens_aperture_r, h=lens_z-bottom-6+d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_outer_r,h=parfocal_distance); //lens
    }
}
module optical_path_with_lens(){
    union(){
        rotate(camera_angle) translate([0,0,bottom]) picam_push_fit_2(); //camera
        translate([0,0,bottom+6]) lighttrap_cylinder(r1=5, r2=lens_aperture_r, h=lens_z-bottom-6+d); //beam path
        translate([0,0,lens_z]) cylinder(r=lens_outer_r,h=parfocal_distance); //lens
    }
}

module body(){
    difference(){
        union(){
            sequential_hull(){
                rotate(camera_angle) translate([0,2.4,bottom]) cube([25,24,d],center=true);
                rotate(camera_angle) translate([0,2.4,bottom+1.5]) cube([25,24,d],center=true);
                rotate(camera_angle) translate([0,2.4,bottom+4]) cube([25-5,24,d],center=true);
                //translate([0,0,dt_bottom]) cube([15,16,d],center=true);
                translate([0,0,dt_bottom]) hull(){
                    cylinder(r=body_r,h=d);
                    translate([0,objective_clip_y,0]) cube([objective_clip_w,4,d],center=true);
                }
                translate([0,0,dt_bottom]) cylinder(r=body_r,h=d);
                translate([0,0,dt_top]) cylinder(r=body_r,h=d);
                translate([0,0,min(lens_z, dt_top + 3)]) cylinder(r=neck_r,h=d);
                translate([0,0,top]) cylinder(r=neck_r,h=d);
            }
            
            //dovetail
			reflect([1,0,0]) translate(corner+[sqrt(3)*r,-r,0]) hull() repeat([1,0,0],2) cylinder(r=r,h=dt_h);	
			hull() reflect([1,0,0]) translate(corner) rotate(45) translate([sqrt(3)*r,r,0]) repeat([1,0,0],2) cylinder(r=r,h=dt_h);
        }
        //dovetail
        r=0.5;
        corner=[objective_clip_w/2-1.5,objective_clip_y,dt_bottom];
		reflect([1,0,0]) translate(corner) cylinder(r=r,h=dt_h);
		reflect([1,0,0]) translate(corner+[0,0,-d]) clip_tooth(dt_h);
        
        //clearance for camera clip
        reflect([1,0,0]) translate([4,camera_clip_y-1,dt_bottom]) cylinder(r=2,h=999);
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

/*////////// Sealed optics module, infinity corrected ////////
difference(){
    body();
    optical_path_with_lens();
}//*/
/////////// Sealed optics module ////////////////
difference(){
    body();
    optical_path();
}//*/
/////////// Camera board cover //////////////
//picam_cover();
//*/