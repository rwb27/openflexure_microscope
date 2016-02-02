use <utilities.scad>;
use <./picam_push_fit.scad>;
$fn=16;
d=0.05;

clip_y = 7;
clip_w = 14; //external width of clip for dovetail
clip_h = 10; //height of dovetail
tube_h = 8; //height of tube that meshes with objective
beam_r = 3; //radius of beam (must be > camera diagonal/2)
bottom = -10;
led_z = 6; //height of LED beam path
filter_r = 16/2+0.3; //radius of circular filters
dichroic = [12.5+0.8,16,1.1]; //size of filter cube

//the dovetail should sit at ([0,-leg_r-2,sample_z+5])
//the LED should sit at ([0,0,sample_z+30])
module clip_tooth(h){
	intersection(){
		cube([999,999,h]);
		rotate(-45) cube([1,1,1]*999*2);
	}
}
module dovetail(w=10,dt=1.5,h=10,t=2){
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
		difference(){ //barrel/body
			union(){
				difference(){ //camera mount at bottom
					translate([-10,-12,bottom]) cube([20,24,5]);
					translate([0,0,bottom ]) rotate(90) picam_push_fit();
				}
				translate([0,clip_y,0]) dovetail(w=clip_w-4,h=clip_h); //dovetail
				sequential_hull(){ //body
					translate([-10,-10,bottom+5-d]) cube([20,20,-bottom-5]);
					union(){
						translate([-20/2,-20/2,0]) cube([20,20-clip_y-1,d]);
						cylinder(r=8,h=d);
					}
					translate([0,0,clip_h]) union(){
						translate([-20/2,0,0]) cube([20,clip_y-1,1]);
						cylinder(r=beam_r+1,h=3);
						cube([dichroic[0]*0.7+1,2*beam_r+2,6],center=true);
					}
					translate([0,0,clip_h]) cylinder(r=beam_r+1,h=d);
					translate([0,0,clip_h]) cylinder(r=beam_r+1,h=tube_h);
				}
			}
			union(){
				sequential_hull(){ //original clearance for beam
					intersection(){
						union(){
							translate([0,0,bottom+5-1]) cylinder(r=filter_r,h=2);
							translate([-filter_r,-filter_r,bottom+5]) cube([filter_r*2,filter_r,2]);
						}
						translate([0,3,0]) cube([filter_r,filter_r,999]*2,center=true);
					}
					cylinder(r=6,h=d);
					cylinder(r=beam_r,h=clip_h+d);
					cylinder(r=beam_r,h=clip_h+tube_h+d);
				}
				//dichroic
				mirror([0,1,0]) sequential_hull(){
#					translate([0,0,led_z-dichroic[2]/sqrt(2)]) rotate([45,0,0]) cube(dichroic,center=true);
					translate([0,0,led_z+1]) rotate([45,0,0]) cube([dichroic[0]-2,dichroic[1],d],center=true);
					translate([0,0,led_z+1]) rotate([45,0,0]) translate([-dichroic[0]/2,-dichroic[1]/2,0]) cube([dichroic[0]-2,dichroic[1]/2+beam_r+1.5,d]);
					translate([0,0,clip_h]) cylinder(r=beam_r,h=3);
				}
				//LED beam
#				translate([0,0,led_z]) rotate([-90,0,0]) cylinder(r=3/2+0.2,h=999);
#				translate([0,7,led_z]) rotate([-90,0,0]) cylinder(r=5/2+0.2,h=999);
				//Emission filter entry slot
				translate([-filter_r,-999,bottom+5-1+0.25]) cube([2*filter_r,999,2]);
//#				translate([0,-4,led_z+5]) rotate([90,0,0]) cylinder(r=16/2+0.2,h=1.3,center=true);
			}
		}
	}
}

picam_mount();


