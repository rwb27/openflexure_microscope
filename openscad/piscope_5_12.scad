use <utilities.scad>;
use <./nut_seat_with_flex_6a.scad>;
use <./picam_push_fit.scad>;
use <./logo.scad>;

d = 0.05;
$fn=32;

sample_z = 40; //height of the top of the stage
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
leg_r = 25; //radius of innermost part of legs
hole_r = 10; //size of hole in the stage
xy_lever_ratio = 1; //mechanical advantage of actuator over stage
z_lever_ratio = 2.6; //as above, for Z axis (must be >1)

stage_flex_w = 4; //width of XY axis flexures
zflex_l = 1.5;    //length and height of flexures
zflex_t = 0.75;
flex_z1 = 0;      //height of lower flexures
flex_z2 = sample_z-stage_t; //height of upper flexures
z_strut_l = 15; //length of struts supporting Z carriage
z_strut_t = 6;  //thickness of above
z_flex_w = 4;   //width of above
leg = [4,stage_flex_w,flex_z2+zflex_t];
leg_middle_w = 12; //width of the middle part of each leg
motor_lugs=false;
objective_clip_y = 6;
objective_clip_w = 10;
camera_clip_y = -7;

nut_seat_r = 8.5;
actuator_pillar_r = nut_seat_r+1.5+2.5;
nut_seat_h = 14;
leg_outer_w = leg_middle_w + 2*zflex_l + 2*leg[0];
actuator = [6,flex_z2 - flex_z1,6];
actuating_nut_r = (flex_z2 - flex_z1)*xy_lever_ratio;
xy_actuator_travel = actuating_nut_r*0.15;
xy_actuator_travel_top = nut_seat_h+xy_actuator_travel;
z_flexure_x = (leg_r-zflex_l-max(5,leg[2]*0.1))*sqrt(2);
z_flexure_spacing = flex_z2-actuator[2]-z_strut_l*0.22-2;
z_carriage = [(z_flexure_x-zflex_l*2-z_strut_l)+d,4,z_flexure_spacing+zflex_t];
z_support_y = 2*zflex_l+z_strut_l+z_carriage[1]+z_flexure_spacing*0.1;
z_nut_y = (z_strut_l+zflex_l)*z_lever_ratio+zflex_l/2;
z_actuator_travel = z_nut_y*0.15;
z_actuator_travel_top = nut_seat_h+z_actuator_travel;
z_carriage_y = z_strut_l+2*zflex_l;
z_link_w = 4;
bridge_dz = 10;
base_t=6;
xy_foot = [1,1,0]*(leg_r+actuating_nut_r)/sqrt(2)-[15,0,0];
z_foot = [0,-(leg_r+leg_outer_w/2)/sqrt(2)+5,0];

module shear_x(amount=1){
	multmatrix([[1,amount,0,0],
					 [0,1,0,0],
					 [0,0,1,0],
					 [0,0,0,1]]) children();
}
module shear_yz(amount=1){
	multmatrix([[1,0,0,0],
					 [0,1,0,0],
					 [0,amount,1,0],
					 [0,0,0,1]]) children();
}
module leg(){
	union() reflect([1,0,0]){
		//legs (tapered)
		translate([leg_middle_w/2+zflex_l,0,0]) hull(){
			cube(leg);
			cube([leg[0],leg[1]+stage_flex_w,d]);
		}
		
		//middle part and flexure to outer legs
		intersection(){
			translate([0,0,flex_z1]) repeat([0,0,flex_z2-flex_z1],2){
				translate([-d,0,0]) cube([leg_middle_w/2+d,999,stage_t-0.2*leg[1]]);
				cube([leg_middle_w/2+zflex_l+d,999,zflex_t]);
			}
			translate([-999,0,0]) sequential_hull(){ //make it taper from small at the bottom to large at the top.
				cube([999*2,leg[1]+stage_flex_w,d]);
				cube([999*2,leg[1],leg[2]]);
				cube([999*2,leg[1],leg[2]+10]);
			}
		}
		
		//thin links between legs
		if(flex_z2-flex_z1 > 2*bridge_dz){
			assign(n=floor((flex_z2-flex_z1)/bridge_dz))
			assign(dz=(flex_z2-flex_z1)/n )
			translate([0,leg[1]/2,flex_z1+dz]) repeat([0,0,dz],n-1) cube([leg_outer_w,2,0.5],center=true);
		}
	}
}
module actuator(){
	assign(brace=20, fw=stage_flex_w) union(){
		//leg (vertical bit)
		reflect([1,0,0]){
			//vertical legs
			translate([leg_middle_w/2+zflex_l,0,0]) hull(){
				cube(leg);
				cube([leg[0],fw+brace,d]); //extend it to be a triangle
			}

			//middle part and flexure to outer legs
			translate([0,0,flex_z1]) repeat([0,0,flex_z2-flex_z1],2){
				translate([-d,0,0]) cube([leg_middle_w/2+d,leg[1],stage_t-0.2*leg[1]]);
				cube([leg_middle_w/2+zflex_l+d,leg[1],zflex_t]);
			}
			//flexure to outer part of braces{
			translate([0,brace,flex_z1]) cube([leg_middle_w/2+zflex_l+d,fw,zflex_t]);
		}
		//arm (horizontal bit)
		sequential_hull(){
			translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,brace+fw,4]);
			translate([-actuator[0]/2,0,0]) cube([actuator[0],brace+fw+0,actuator[2]]);
			translate([-actuator[0]/2,0,0]) cube(actuator-[0,6,0]);
		}
		//nut seat
		translate([0,actuating_nut_r,0]) nut_seat_with_flex(); //cylinder(r=6,h=actuator[2]);

		//thin links between legs
		if(flex_z2-flex_z1 > 2*bridge_dz){
			assign(n=floor((flex_z2-flex_z1)/bridge_dz))
			assign(dz=(flex_z2-flex_z1)/n )
			translate([0,leg[1]/2,flex_z1+dz]) repeat([0,0,dz],n-1) cube([leg_outer_w,2,0.5],center=true);
		}
	}
}
module actuator_silhouette(h=999){
	linear_extrude(2*h,center=true){
		minkowski(){
			circle(r=zflex_l,$fn=12);
			projection() union(){
				actuator();
			}
		}
	}
}
module actuator_cutout(){
	union(){
		actuator_silhouette(h=8);
		translate([-2,xy_carriage_front_y,0]) cube([4,z_nut_y-xy_carriage_front_y,7+1.5]);
	}
}

module leg_frame(angle){
	rotate(angle) translate([0,leg_r,]) children();
}
module each_leg(){
	for(angle=[45,135,-135,-45]) leg_frame(angle) children();
}
module each_actuator(){
	reflect([1,0,0]) leg_frame(45) children();
}
module each_nonactuator_leg(){
	reflect([1,0,0]) leg_frame(135) children();
}
module z_axis(){
	assign(w=z_flex_w) reflect([1,0,0]) difference(){
		translate([-z_flexure_x,0,0]) {
			//flexures and struts
			shear_x(){
				repeat([0,0,z_flexure_spacing],2){
					translate([0,-d,0]) cube([w,z_strut_l+2*d+2*zflex_l,zflex_t]);//flexures
					translate([0,zflex_l,0]) cube([w,z_strut_l,z_strut_t]); //struts
				}
				translate([0,z_strut_l+zflex_l-z_link_w,z_flexure_spacing+0.5]) cube([999,z_link_w,z_strut_t-0.5]); //link the two struts (and the actuator)
				hull(){
					translate([0,z_strut_l,zflex_t+3]) cube([1,z_flexure_x-1-z_strut_l,6]);
					translate([0,z_strut_l-4,z_strut_t-1]) cube([z_flex_w,z_flexure_x-z_flex_w-z_strut_l+4,1]);
				}
			}
//			shear_x() translate([0,2*zflex_l+z_strut_l,0]) cube(z_carriage); //moving anchor
			translate([0,-w,0]) cube([w,w,z_carriage[2]]); //static anchors
		}
		translate([d,0,-d]) cube([1,1,1]*9999); //stop things crossing the Y axis
		rotate([0,0,45]) cube([1,1,9999]*17,center=true);
//		translate([-3, z_strut_l+zflex_l*1.5,-d]) cube([6,999,z_strut_t+3-0.5]); //clearance for actuator
//		hull() mirror([1,0,0]) assign(l=z_strut_t-1.5){ //clearance for objective clip
//			translate([2+l/2,z_carriage_y-2*d,1.5]) cube([999,d,d]);
//			translate([2-d,z_carriage_y-l,1.5+l]) cube([999,l,d]);
//		}
	}
}
module z_actuator(){
	//Z actuating lever
	assign(gap=z_carriage[0]*2-2*z_flex_w) difference(){
		union(){
			translate([-2,z_flexure_x-z_flex_w,0]) cube([4,z_nut_y - (z_flexure_x-z_flex_w)-5, z_strut_t]); //thin part of actuator
			translate([0,z_flexure_x-2,0]) hull(){
				translate([-1,0,0])cube([2,2, z_strut_t+4]); //join to raised struts
				translate([-2,0,0])cube([4,6, z_strut_t]); //taper
			}
			translate([0,z_nut_y,0]) nut_seat_with_flex();//cylinder(r=6,h=z_strut_t);
		}
		//translate([0,z_nut_y,z_strut_t-3]) mirror([0,0,1]) nut(3,fudge=1.18,shaft=true,h=99);
	}
}
module objective_clip_3(){
	assign(arm_length=10)
	assign(clip_h=z_flexure_spacing-z_strut_t-3,arm_w=2)
	assign(clip_outer_w=objective_clip_w+2*arm_w)
	assign(base_y=z_carriage_y-6)
	difference(){
		intersection(){
			union(){
				assign(w1=z_carriage[0]*2,w2=clip_outer_w,dy=z_carriage_y-objective_clip_y) translate([0,objective_clip_y,0]) sequential_hull(){
					translate([-w1/2,dy,0]) cube([w1,z_carriage[1],2]);
					hull(){
						translate([-w2/2,0,0]) cube([w2,arm_length+arm_w,z_strut_t]);
						translate([-2/2,0,0]) cube([2,dy,z_strut_t]);
					}
					translate([-w2/2,0,z_carriage[2]/2]) cube([w2,dy,d]);
					translate([-w2/2,0,z_carriage[2]-z_carriage[1]]) cube([w2,dy+z_carriage[1],z_carriage[1]]);
				}
				translate([-clip_outer_w/2,objective_clip_y,0]) cube([clip_outer_w,arm_length,z_flexure_spacing+z_strut_t]);
			}
			rotate(45) cube([1,1,999]*z_flexure_x*sqrt(2),center=true);
		}
		//opening for clip (forms the arms from the block)
		hull() reflect([1,0,0]) translate([0,objective_clip_y,1]){
			translate([-clip_outer_w/2+arm_w+2,arm_length-2,0]) cylinder(r=2,h=999);
			translate([-clip_outer_w/2+arm_w,1.5,0]) rotate(-45) cube([3,d,999]);
		}
		//clearance for top linker bar between flexure arms
		translate([-999,z_carriage_y-zflex_l-z_link_w-1.5,z_flexure_spacing-2]) cube([999*2,zflex_l+z_link_w+1.5,999]);
		//clearance for z axis struts passing under the carriage
		reflect([1,0,0]) hull() translate([-z_flexure_x-d,0,0]) shear_x(){
			translate([0,z_strut_l,zflex_t+1.5]) cube([d,z_flexure_x-1-z_strut_l,12]);
			translate([0,z_strut_l-4,z_strut_t-1-0.75]) cube([z_flex_w+1.5,z_flexure_x-z_flex_w-z_strut_l+4,1+2]);
		}
		//cut-out for actuator
		translate([0,z_flexure_x-z_flex_w+10-2,0]) cube([7,20,(z_strut_t+3)*2],center=true);
		//cut-outs for flexures
		reflect([1,0,0]) hull() translate([-z_flexure_x-d,0,0]) shear_x()
			translate([-d,0,-d]) cube([z_flex_w+1.5,z_carriage_y,z_strut_t+1.5]);
		//cut-out for stage (camera mount)
		hull() reflect([0,0,1]) translate([0,0,4]) rotate([45,0,0]) cube([999,1,1]*sqrt(2)*11,center=true);
	}
}
module dovetail_clip_cutout(size,dt=1.5,t=2,h=999){
	hull() reflect([1,0,0]) translate([-size[0]/2+t,0,-d]){
		translate([dt,size[1]-dt,0]) cylinder(r=dt,h=h,$fn=16);
		translate([0,dt,0]) rotate(-45) cube([dt*2,d,h]);
	}
}
module dovetail_clip(size,dt=1.5,t=2){
	difference(){
		translate([-size[0]/2,0,0]) cube(size);
		dovetail_clip_cutout(size,dt=dt,t=t,h=999);
	}
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){

	//legs
	each_nonactuator_leg() leg();
	each_actuator() actuator();
	//flexures connecting bottoms of legs to centre
	each_leg() reflect([1,0,0]) translate([0,0,flex_z1])
			assign(w=stage_flex_w) translate([leg_middle_w/2-w,0,0.5]) hull()
					repeat([zflex_l,-zflex_l,0],2) cube([w,d,zflex_t]);

	//flexures between legs and stage
	difference(){
		hull() each_leg() translate([0,0,flex_z2+zflex_t/2+0.5]) cube([leg_middle_w,d,zflex_t],center=true);
		hull() each_leg() cube([leg_middle_w-2*stage_flex_w,d,999],center=true);
	}

	//stage
   // this must get built up carefully: we start with the bridges round the edge, then work inwards.
	difference(){
		hull() each_leg() translate([0,-zflex_l-d,flex_z2+1+(stage_t-1)/2]) cube([leg_middle_w+2*zflex_l,2*d,stage_t-1],center=true); //body of the stage
		hull() for(a=[45,-45]) rotate(a) translate([0,0,flex_z2+1]) cube([2*(leg_r+leg_middle_w/2-stage_flex_w-hole_r),2*hole_r,1],center=true); //cut-out from the bottom: start filling in the corners
		rotate(45) translate([0,0,flex_z2+1]) cube([2*(leg_r+leg_middle_w/2-stage_flex_w-hole_r),2*hole_r,2],center=true);
		//central hole, building in gradually
		rotate(45) translate([0,0,flex_z2+2]) assign(f=[4,8,16,32]) for(i=[0:(len(f)-1)]) rotate(180/f[i]) translate([0,0,i*0.5]) cylinder(r=10/cos(180/f[i]),h=1.05,$fn=f[i],center=true);
		cylinder(r=hole_r,h=9999,$fn=64);
		each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-zflex_l-4,flex_z2+1.5]) cylinder(r=3/2,h=999);
	}
	
	//z axis
	z_axis();
	z_actuator();
	objective_clip_3();

	//base
	assign(h=base_t) difference(){
		union(){
			hull(){ //make it big enough to support legs and actuators
				each_leg() translate([-leg_outer_w/2,-zflex_l-d,0]) cube([leg_outer_w,d,h]);
				each_actuator() translate([0,actuating_nut_r,0]) screw_seat_outline(h=h);
			}
			
			//reinforcement for Z axis (and eventually illumination)
			reflect([1,0,0]) translate([0,0,base_t-d]) sequential_hull(){
				rotate(-45) translate([12-2,actuating_nut_r+leg_r,0]) cube([2,d,8]);
				union(){
					translate([z_flexure_x+1-2,-3,0]) cylinder(r=1,h=z_flexure_spacing-base_t);
					leg_frame(-135) translate([-leg_outer_w/2,-zflex_l-2,0]) cube([d,2,d]);
				}
				leg_frame(-135) translate([leg_outer_w/2+1.5,-zflex_l-2,0]) rotate([6,6,0]) cube([d,2,12]);
			}
		}
		each_actuator(){//cut-outs for actuators (XY)
			linear_extrude(2*xy_actuator_travel_top,center=true) minkowski(){ 
				projection() actuator();
				circle(r=1.5, $fn=8);
			}
			translate([0,actuating_nut_r,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		}
		//Z actuator cut-out
		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		translate([-7/2,z_carriage_y,-d]) cube([7,z_nut_y-z_carriage_y,999]); //z actuating arm

		//objective/stuff cut-out
		sequential_hull(){
			translate([0,z_flexure_x+1.5-d,0]) cube([2*d,2*d,999],center=true);
			translate([0,0,0]) cube([2*(z_flexure_x+1.5-d),2*d,999],center=true);
			translate([0,0,0]) cube([2*(z_flexure_x-z_flex_w-d),2*d,999],center=true);
			translate([0,8-(z_flexure_x-z_flex_w-d),0]) cube([16,2*d,999],center=true);
		}

		//post mounting holes
		reflect([1,0,0]) translate([20,z_nut_y+2,0]) cylinder(r=4/2*1.1,h=999,center=true);
        
        //logo
        leg_frame(-45){
#            translate([leg_r,6, 10]) rotate([90,0,90+atan((leg_r-12)/(actuating_nut_r-6))]) scale([0.2,0.2,1]) logo_and_name();
        }
	}
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0])
        screw_seat(travel=xy_actuator_travel, motor_lugs=motor_lugs);
	translate([0,z_nut_y,0]) 
        screw_seat(travel=z_actuator_travel, motor_lugs=motor_lugs);
    
	//camera mount
	translate([0,camera_clip_y,0]) mirror([0,1,0]) dovetail_clip([14,7,10]);
	hull(){
		translate([-7,8-(z_flexure_x-z_flex_w-d)-3,0]) cube([14,d,base_t]);
		translate([-7,-7-7,0]) cube([14,d,10]);
	}

	////////////// illumination mount ///////////////////
	difference(){
		sequential_hull(){ //leg structure (oval tube)
			hull() reflect([1,0,0]) leg_frame(-135) translate([leg_outer_w/2,-zflex_l-2,0]){
				translate([0,0,base_t-d]) rotate([6,6,0]) cube([d,2,12]);
				cube([d,2,base_t]);
			}
			translate([0,-leg_r-8,0]) scale([0.8,1.1,1]) cylinder(r=8,h=12+base_t);
			translate([0,-leg_r-10,sample_z]) scale([1,1.1,1]) cylinder(r=6,h=d);
			translate([-6,-leg_r-12,sample_z+4]) cube([12,10,15]);
		}
		//hole in the bottom for foot
		translate([0,-leg_r-8,-d]) scale([0.8,1.1,1]) cylinder(r1=6+0.75,r2=6,h=2); //chamfered bottom
		sequential_hull(){
			//make the tube hollow
			translate([0,-leg_r-8,-d]) scale([0.8,1.1,1]) cylinder(r=6,h=12+base_t); 
			translate([0,-leg_r-10,sample_z]) scale([1,1.1,1]) cylinder(r=4,h=d);
			//cutout for the clip at the top
			translate([0,-leg_r-2,sample_z+5]) intersection(){
				mirror([0,1,0]) dovetail_clip_cutout([12,8,d],h=d);
				translate([0,-2-999,0]) cube([1,1,1]*999*2,center=true);
			}
			translate([0,-leg_r-2,sample_z+5]) mirror([0,1,0]) dovetail_clip_cutout([12,8,12]);
		}
		reflect([1,0,0]) translate([6*0.8,-leg_r-8,3]) sphere(r=1);
		//hole from back for access to objective
		hull(){
			translate([0,0,sample_z/2]) cube([6,999,sample_z/2],center=true);
			translate([0,0,sample_z]) cube([2,999,d],center=true);
		}
	}
}



//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
