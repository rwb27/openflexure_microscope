use <utilities.scad>;
use <picam_push_fit.scad>;
use <tube_lens_gripper.scad>;


module trylinder(r=1, flat=1, h=d, center=false){
    //A fade between a cylinder and a triangle.
    hull() for(a=[0,120,240]) rotate(a)
        translate([0,flat/sqrt(3),0]) cylinder(r=r, h=h, center=center);
}

rms_r = 20/2;
objective_r = 25/2;
tube_lens_r = 16/2+0.2;
f_tube = 21.5;
pedestal_h = 2;
t=0.65;
d=0.05;
$fn=48;

bottom = -8; //nominal distance from PCB to microscope bottom
dt_bottom = -1; //where the dovetail starts (<0 to allow some play)
//sample_z = 40; //height of the sample above the bottom of the microscope
lens_assembly_z = bottom+f_tube-pedestal_h; //base of the lens assembly
lens_assembly_base_r = rms_r+1; //outer size of the lens grippers
top = lens_assembly_z; //top of the mount
dt_top = top+12;
dt_h=dt_top-dt_bottom;
d = 0.05;
//neck_h=h-dovetail_h;
body_r=9;
neck_r=max( (body_r+tube_lens_r-0.5)/2, tube_lens_r+1.5);
camera_angle = 45;

objective_clip_w = 10;
objective_clip_y = 12;

$fn=24;

module lens_gripper(lens_r=10,h=6,lens_h=3.5,base_r=-1,flange=0.5,t=0.65){
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

module dovetail(w=10,dt=1.5,h=10,t=2,arm_t=2){
    // This produces a vertical dovetail (doesn't slide without
    // considerable force - it's designed to stay put!)
    // w is the dovetail width - i.e. the width between the
    //   insides of the flexible struts on the holder. The
    //   actual width of the part is less than this.
    // dt is the size of the dovetail "teeth"
    // h is the height of the structure
    // t is the thickness of the back of the dovetail.
    // y=0 is the plane of the flat part of the dovetail, i.e.
    // the part that makes contact with the front of the clip.
	assign(r=0.5,corner=[w/2-dt,0,0]) difference(){
		union(){
			sequential_hull(){
				translate([-w/2+dt,r,0]) cube([w-2*dt,d,h]);
				translate([-w/2+dt-r,-r,0]) cube([w-2*dt+2*r,d,h]);
				translate([-w/2,-r,0]) cube([w,d,h]);
				translate([-w/2-arm_t,-t,0]) cube([w+2*arm_t,t-r,h]);
			}
			difference(){
				union(){
					reflect([1,0,0]) hull(){
						translate(corner+[sqrt(3)*r,-r,0]) cylinder(r=r,h=h);	
						translate([w/2+arm_t-r,-r,0]) cylinder(r=r,h=h);	
				}
					hull() reflect([1,0,0]) translate(corner) rotate(45) translate([sqrt(3)*r,r,0]) repeat([1,0,0],2) cylinder(r=r,h=h);
				}
			}
		}
		reflect([1,0,0]) translate(corner) cylinder(r=r,h=3*h,center=true);
		reflect([1,0,0]) translate(corner+[0,0,-1]) clip_tooth(999);
	}
}

module optical_path(){
    union(){
        //camera
        rotate(camera_angle) translate([0,0,bottom]) picam_push_fit_2(); 
        //light path between lens and sensor
        translate([0,0,bottom+6]) lighttrap_cylinder(r1=5, r2=tube_lens_r-0.5, h=lens_assembly_z-bottom-6+d-0.5,ridge=0.75); //beam path
        translate([0,0,lens_assembly_z-0.5-d]) cylinder(r=tube_lens_r-0.5,h=0.5+2*d);
    }
}

module body(){
    union(){
        sequential_hull(){
            rotate(camera_angle) translate([0,2.4,bottom]) cube([25,24,d],center=true);
            rotate(camera_angle) translate([0,2.4,bottom+1.5]) cube([25,24,d],center=true);
            rotate(camera_angle) translate([0,2.4,bottom+4]) cube([25-5,24,d],center=true);
            //translate([0,0,dt_bottom]) cube([15,16,d],center=true);
            translate([0,0,dt_bottom]) hull(){
                cylinder(r=body_r,h=d);
                translate([0,objective_clip_y,0]) dovetail(w=objective_clip_w, h=d, t=2);
            }
            translate([0,0,dt_bottom]) cylinder(r=body_r,h=d);
            translate([0,0,lens_assembly_z]) cylinder(r=lens_assembly_base_r,h=d);
            
        }
        
        difference(){
            //dovetail
            translate([0,objective_clip_y,dt_bottom]) dovetail(w=objective_clip_w, h=dt_top-dt_bottom, t=10);
            //make sure dovetail joins on, without fouling lens clips
            scale([0.99,0.99,1]) hull() intersection(){
                lens_assembly();
                cylinder(r=999,h=dt_top+d,$fn=8);
            }
        }
    }
}

module lens_assembly(){
    translate([0,0,lens_assembly_z]){
        lens_gripper(lens_r=rms_r, lens_h=12.5,h=15, base_r=lens_assembly_base_r);
        lens_gripper(lens_r=tube_lens_r, lens_h=3.5,h=6);
        difference(){
            cylinder(r=tube_lens_r,h=2);
            cylinder(r=tube_lens_r-0.5,h=999,center=true);
        }
    }
}
difference(){
    union(){
        
        lens_assembly(); //the grippers for objective/lens
        body(); //the camera holder/base
        
        
    }
    
    optical_path();
 //   cube(999);
}
    