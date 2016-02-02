use <utilities.scad>;
use <./picam_push_fit.scad>;
$fn=16;
d=0.05;

clip_y = 7;  //position of dovetail (normal microscope)
//clip_y = 10; //position of dovetail (big-stage version)
clip_w = 14; //external width of clip for dovetail
clip_h = 10; //height of dovetail
tube_h = 8; //height of tube that meshes with objective
beam_r = 3; //radius of beam (must be > camera diagonal/2)
bottom = -10;

//the dovetail should sit at ([0,-leg_r-2,sample_z+5])
//the LED should sit at ([0,0,sample_z+30])
module clip_tooth(h){
	intersection(){
		cube([999,999,h]);
		rotate(-45) cube([1,1,1]*999*2);
	}
}
module dovetail(w=10,dt=1.5,h=10,t=2){
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
				translate([-w/2-t,-t,0]) cube([w+2*t,t-r,h]);
				echo("width of dovetail back is", w-2*dt+2*(sqrt(3)*r+1+r));
			}
			difference(){
				union(){
					reflect([1,0,0]) hull(){
						translate(corner+[sqrt(3)*r,-r,0]) cylinder(r=r,h=h);	
						translate([w/2+t-r,-r,0]) cylinder(r=r,h=h);	
				}
					hull() reflect([1,0,0]) translate(corner) rotate(45) translate([sqrt(3)*r,r,0]) repeat([1,0,0],2) cylinder(r=r,h=h);
				}
			}
		}
		reflect([1,0,0]) translate(corner) cylinder(r=r,h=3*h,center=true);
		reflect([1,0,0]) translate(corner+[0,0,-1]) clip_tooth(999);
	}
}

module picam_mount(){
	union(){
		translate([0,clip_y,0]) dovetail(w=clip_w-4,h=clip_h);
		difference(){ //barrel/body
			sequential_hull(){
                translate([2.4,0,bottom]) cube([24,25,d],center=true);
                translate([2.4,0,bottom+1.5]) cube([24,25,d],center=true);
                translate([2.4,0,bottom+4]) cube([24,25-5,d],center=true);
				translate([0,1,bottom+6-d]) cube([18,18,d],center=true);
				union(){
					translate([-clip_w/2,clip_y+2.5,0]) cube([clip_w,d,d]);
					cylinder(r=8,h=d);
				}
				union(){
					translate([-clip_w/2,clip_y-2,0]) cube([clip_w,d,d]);
					cylinder(r=8,h=d);
				}
				translate([0,0,clip_h]) union(){
					translate([-clip_w/2,clip_y-2,0]) cube([clip_w,d,d]);
					cylinder(r=beam_r+1,h=d);
				}
				translate([0,0,clip_h]) cylinder(r=beam_r+1,h=d);
				translate([0,0,clip_h]) cylinder(r=beam_r+1,h=tube_h);
			}
            //beam path
			sequential_hull(){
				translate([-7,-7,bottom+3.5]) cube([14,14,1]);
				cylinder(r=6,h=d);
				cylinder(r=beam_r,h=clip_h+d);
				cylinder(r=beam_r,h=clip_h+tube_h+d);
			}
            //camera
            rotate(-90) translate([0,0,bottom]) picam_push_fit_2(beam_length=8);
		}
	}
}

picam_mount();

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

//picam_cover();