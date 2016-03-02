use <utilities.scad>;
use <./nut_seat_with_flex_6a.scad>;
use <./picam_push_fit.scad>;
use <./logo.scad>;

d = 0.05;
$fn=32;

big_stage = true;

sample_z = 40; //height of the top of the stage
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
leg_r = big_stage?27:25; //radius of innermost part of legs
leg_dr = 20;
hole_r = big_stage?15:10; //size of hole in the stage
lever_ratio = 1; //mechanical advantage of actuator over stage

flex_w = 4; //width of XY axis flexures
flex_l = 1.5;    //length and height of flexures
flex_t = 0.75;
flex_z1 = 0;      //height of lower flexures
flex_z2 = sample_z-stage_t; //height of upper flexures
leg = [4,flex_w,flex_z2+flex_t];
leg_middle_w = 34; //width of the middle part of each leg
motor_lugs=true;
objective_clip_y = big_stage?12:6;
objective_clip_w = 10;

flex_angle = 8.5; //angle through which flexures will bend safely
nut_seat_r = 8.5;
actuator_pillar_r = nut_seat_r+1.5+2.5;
nut_seat_h = 14;
leg_outer_w = leg_middle_w + 2*flex_l + 2*leg[0];
actuating_nut_r = leg_dr+flex_w+(6+3+flex_w)*sin(flex_angle)+12;
actuator = [6,actuating_nut_r,6];
xy_actuator_travel = actuating_nut_r*sin(flex_angle);
xy_actuator_travel_top = nut_seat_h+xy_actuator_travel;
z_travel = leg_dr * sin(flex_angle);

bridge_dz = 10;
base_t=1;
wall_h=15;
wall_t=1.5;

module actuator(){
    union(){
		//leg part
        reflect([1,0,0]){
            //legs (tapered and sloping outer parts)
            translate([leg_middle_w/2+flex_l,0,0]) hull(){
    			translate([0,0,flex_z2]) cube([leg[0],flex_w,flex_t]);
    			translate([0,flex_w,0]) cube([leg[0],leg_dr,flex_t]);
            }
            
            //flexible joints between the outer legs
            for(p=[[0,0,flex_z2], [0,flex_w,actuator[2]+z_travel]]) translate(p){
                translate([-leg_outer_w/2,0,0]) cube([leg_outer_w,flex_w,flex_t]);
                translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,flex_w,stage_t-1]);
            }
            
            //link between the bottoms of the legs
            reflect([1,0,0]) translate([0,leg_dr,0]) sequential_hull(){
                translate([-leg_outer_w/2,0,0]) cube([d,flex_w,flex_t]);
                translate([-leg_middle_w/2,0,0]) cube([d,flex_w,flex_t]);
                translate([-leg_middle_w/2,0,0]) cube([flex_w,flex_w,d]);
                translate([-leg_middle_w/2,0,3+actuator[2]]) cube([flex_w,flex_w,actuator[2]]);
                translate([-d,0,3+actuator[2]]) cube([flex_w,flex_w,actuator[2]]);
            }
        }
		//arm (horizontal bit)
        sequential_hull(){
			translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,leg_dr-flex_l,4]);
			translate([-actuator[0]/2,0,0]) cube([actuator[0],leg_dr-flex_l,actuator[2]]);
			translate([-actuator[0]/2,0,0]) cube(actuator-[0,6,0]);
		}
        reflect([1,0,0]) translate([-leg_middle_w/2,0,0.5]) cube([flex_w,leg_dr+d,flex_t]); //flexures to centre and leg
		//nut seat
		translate([0,actuating_nut_r,0]) nut_seat_with_flex();
	}
}
module actuator_silhouette(h=999){
	linear_extrude(2*h,center=true){
		minkowski(){
			circle(r=flex_l,$fn=12);
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
	for(angle=[0, -120, 120]) leg_frame(angle) children();
}

module objective_clip(){
	arm_length=8;
	clip_h=sample_z-stage_t+2;
    arm_w=2;
	clip_outer_w=objective_clip_w+2*arm_w;
    inner_w = clip_outer_w - 2*arm_w;
	difference(){
        translate([-clip_outer_w/2,objective_clip_y,0]) cube([clip_outer_w,arm_length+arm_w,clip_h]);
        
		//opening for clip (forms the arms from the block)
		hull() reflect([1,0,0]) translate([0,objective_clip_y,0.5]){
			translate([-inner_w/2+2,arm_length-2,0]) cylinder(r=2,h=999);
			translate([-inner_w/2,1.5,0]) rotate(-45) cube([3,d,999]);
		}

		//sloped bottom to improve quality of the dovetail clip and
        //allow insertion of the optics from the bottom
        translate([0,objective_clip_y,0]){
            rotate([45,0,0]) cube([999,1,1]*sqrt(2)*2.5,center=true); //slope up arms
            hull() reflect([0,0,1]) translate([0,0,2.5]) rotate([0,45,0]) cube([inner_w/sqrt(2),8,inner_w/sqrt(2)],center=true);
        }
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

module add_hull_base(h=1){
    union(){
        linear_extrude(h) hull() projection() children();
        children();
    }
}

module area_inside_flexures(){
    hull() each_leg() cube([leg_middle_w-2*flex_w,d,999],center=true);
}
///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){

	//legs
	each_leg() actuator();
	//flexures connecting bottoms of legs to centre
	each_leg() reflect([1,0,0]) translate([0,0,flex_z1]){
		w=flex_w; 
        translate([leg_middle_w/2-w,0,0.5]) hull()
			repeat([flex_l,-flex_l,0],2) cube([w,d,flex_t]);
    }

	//flexures between legs and stage
	difference(){
		hull() each_leg() translate([0,0,flex_z2+flex_t/2+0.5]) cube([leg_middle_w,d,flex_t],center=true);
        area_inside_flexures();
	}

	//stage
   // this must get built up carefully: we start with the bridges round the edge, then work inwards.
	difference(){
        //make the body of the stage, sitting on the flexure links
		hull() each_leg() translate([0,-flex_l-d,flex_z2+1+(stage_t-1)/2]) cube([leg_middle_w+2*flex_l*tan(30),2*d,stage_t-1+d],center=true);
        
        intersection(){
            area_inside_flexures();
            
            //central hole, building in gradually]
            union(){
                f=[3,6,12,24];
                rotate(90) for(i=[0:(len(f)-1)]) rotate(180/f[i])
                    cylinder(r=hole_r/cos(180/f[i]),
                             h=i*0.5+flex_z2+2.5,
                             $fn=f[i]);
            }
        }
        //mounting holes on top
        each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-flex_l-4,flex_z2+1.5]) cylinder(r=3/2,h=999);
        //smooth through-hole
        cylinder(r=hole_r,h=9999,$fn=64);
        
	}

    //holder for optics module
    objective_clip();

	//base
	difference(){
        h=base_t;
		add_hull_base(h){
			hull(){ //make it big enough to support legs and actuators
				each_leg() translate([-leg_outer_w/2,-flex_l-d,0]) cube([leg_outer_w,d,h]);
				each_leg() translate([0,actuating_nut_r,0]) screw_seat_outline(h=h);
			}
			
			//reinforcement "walls"
            //first, round each leg
			each_leg() reflect([1,0,0]) sequential_hull(){
                    translate([12-wall_t/2,actuating_nut_r,0]) cylinder(d=wall_t,h=wall_h);
                    translate([leg_outer_w/2+1.5+wall_t/2,leg_dr+flex_w+1.5+wall_t/2,0]) cylinder(d=wall_t,h=wall_h);
                    translate([leg_outer_w/2+1.5+wall_t/2,-flex_l-wall_t/2,0]) rotate([flex_angle,0,0]) cylinder(d=wall_t,h=wall_h);
                    translate([-d,-flex_l-wall_t/2,0]) rotate([flex_angle,0,0]) cylinder(d=wall_t,h=wall_h);
			}
            //then link the legs up
            for(a=[0,120,-120]) rotate(a){
                hull() reflect([1,0,0]) leg_frame(-120) translate([leg_outer_w/2+1.5+wall_t/2,-flex_l-wall_t/2,0]) rotate([flex_angle,0,0]) cylinder(d=wall_t,h=wall_h);
                hull() reflect([1,0,0]) leg_frame(-120) translate([leg_outer_w/2+1.5+wall_t/2,leg_dr+flex_w+1.5+wall_t/2,0]) cylinder(d=wall_t,h=wall_h);
            }
		}
		each_leg(){//cut-outs for actuators (XY)
			linear_extrude(2*xy_actuator_travel_top,center=true) minkowski(){ 
				projection() actuator();
				circle(r=1.5, $fn=8);
			}
			translate([0,actuating_nut_r,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		}
        //prevent things sticking out the bottom
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8);

		//post mounting holes
		for(a=[0,120,-120]) rotate(a+60) repeat([12.5,0,0],1,center=true) translate([0,sin(30)*(actuating_nut_r+leg_r)+5,0]) cylinder(r=4/2*1.1,h=999,center=true);
        
        //central hole for the optics module
        hull() each_leg() translate([0,-flex_l-wall_t-d,0]) rotate([flex_angle,0,0]) cube([leg_outer_w+1.5*2+(1-cos(60))*wall_t, 2*d,wall_h*4],center=true);
    } 
 
	//Actuator housings (screw seats and motor mounts)
	each_leg() translate([0,actuating_nut_r,0])
        screw_seat(travel=xy_actuator_travel, motor_lugs=motor_lugs);
}



//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
