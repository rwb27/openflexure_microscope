use <utilities.scad>;
$fn=16;
d=0.05;

big_stage = true;

sample_z = big_stage?60:40; //height of the top of the stage
leg_r = big_stage?30:25;
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
clip_w = 8; //internal width of clip for dovetail

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

led_z = 12;
dt_h = 13;
below_led = 6;
led_r = 3/2*1.1;
led_angle = 20;

intersection(){
	cylinder(r=999,h=999,$fn=8);
//rotate([atan(25/(leg_r+3)),0,0])
	translate([0,0,-led_z+below_led]) //rotate([atan((25+3-14)/(leg_r)),180,0])
    rotate(atan((led_z-below_led-5)/(leg_r+2)),[1,0,0])
    difference(){
		union(){
			translate([0,leg_r+2,5]) dovetail(w=clip_w,h=dt_h);
			hull(){
				translate([-clip_w/2-2,leg_r+d,5]) cube([clip_w+2*2,d,dt_h]);
				translate([0,0,led_z-below_led]) cylinder(r=4,h=below_led+1);
			}
		}
		#translate([0,0,led_z-4]) cylinder(r=led_r,h=5);
		translate([0,0,led_z]) cylinder(r=led_r+1,h=999);
		translate([0,0,led_z-30-2]) cylinder(r1=led_r+30*tan(led_angle),r2=led_r,h=30);
	}
}