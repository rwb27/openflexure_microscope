use <utilities.scad>;
use <./nut_seat_with_flex_6a.scad>;
use <./picam_push_fit.scad>;
use <./logo.scad>;

d = 0.05;
$fn=32;

big_stage = true; //switches between normal and large-stage versions
sample_z = 40; //height of the top of the stage
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
leg_r = big_stage?30:25; //radius of innermost part of legs
hole_r = 10; //size of hole in the stage
xy_lever_ratio = 1; //mechanical advantage of actuator over stage
z_lever_ratio = big_stage?2.2:2.6; //as above, for Z axis (must be >1)

stage_flex_w = 4; //width of XY axis flexures
zflex_l = 1.5;    //length and height of flexures
zflex_t = 0.75;
flex_z1 = 0;      //height of lower flexures
flex_z2 = sample_z-stage_t; //height of upper flexures
z_strut_l = big_stage?20:15; //length of struts supporting Z carriage
z_strut_t = 6;  //thickness of above
z_flex_w = 4;   //width of above
leg = [stage_flex_w,2*stage_flex_w,flex_z2+zflex_t];
leg_middle_w = 12; //width of the middle part of each leg
motor_lugs=false;
objective_clip_y = big_stage?12:6;
objective_clip_w = 10;

flex_angle = 8.5; //angle through which we can bend the flexure links
nut_seat_h = 14; //height of the nut seat (i.e. z position of actuating nuts)
leg_outer_w = leg_middle_w + 2*zflex_l + 2*leg[0]; //width of the leg
actuating_nut_r = (flex_z2 - flex_z1)*xy_lever_ratio; //effective lever length
actuator = [6,actuating_nut_r,6]; //size of the actuator for XY
xy_actuator_travel = actuating_nut_r*tan(flex_angle); //distance the XY actuator moves at the end
xy_travel = max(1.5,(flex_z2 - flex_z1)*sin(flex_angle)); //distance the stage can move
xy_actuator_travel_top = nut_seat_h+xy_actuator_travel;
z_flexure_x = (leg_r-zflex_l-max(5,leg[2]*0.1))*sqrt(2);
z_nut_y = (z_strut_l+zflex_l)*z_lever_ratio+zflex_l/2;
z_actuator_travel = z_nut_y*0.15;
z_actuator_travel_top = nut_seat_h+z_actuator_travel;
bridge_dz = 10; //Z spacing between thin bridges on legs
base_t=0.75; //thickness of the flat bottom (should be >3 layers
wall_h=15; //height of reinforcing wall
wall_t = 2; //thickness of reinforcing wall
xy_foot = [1,1,0]*(leg_r+actuating_nut_r)/sqrt(2)-[15,0,0];
z_foot = [0,-(leg_r+leg_outer_w/2)/sqrt(2)+5,0];

xy_carriage_r = leg_r - zflex_l - wall_t - xy_travel*(1+wall_h/flex_z2);
z_flexure_y1 = xy_carriage_r/sqrt(2) - wall_t - zflex_l/2;
z_flexure_y2 = -(leg_r+leg_middle_w/2)/sqrt(2)-xy_travel + zflex_l/2;
z_travel = (z_flexure_y1 - z_flexure_y2) * sin(flex_angle);
//z_actuator_anchor = (leg_r+leg_middle_w/2)/sqrt(2);
push_y = z_flexure_y1 - 3;
z_actuator_anchor = push_y+0.5*(z_flexure_y1 - z_flexure_y2);
z_nut_z = (z_flexure_y1-z_flexure_y2)/2;

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
module leg(leg, leg_middle_w){
    //make a parallelogram leg
    //leg is a 3-vector describing the bounding cuboid of the outer
    //two legs, leg_middle_w is the length of the linking part in between
	union() reflect([1,0,0]){
		//legs (tapered)
		translate([leg_middle_w/2+zflex_l,0,0]) hull(){
			cube([leg[0],stage_flex_w,leg[2]]);
			cube([leg[0],leg[1],d]);
		}
		
		//middle part and flexure to outer legs
		intersection(){
            union(){
                //links between outer legs, incl. flexures
                repeat([0,0,leg[2]-zflex_t],2){
                    translate([-d,0,0]) cube([leg_middle_w/2+d,999,stage_t-0.2*leg[1]]);
                    cube([leg_middle_w/2+zflex_l+d,999,zflex_t]);
                }
                
                //outer legs
                translate([leg_middle_w/2+zflex_l,0,0]) cube(leg);
            }
            //this limits the size in Y (tapers from bottom to top)
			translate([-999,0,0]) sequential_hull(){
				cube([999*2,leg[1],d]);
				cube([999*2,stage_flex_w,leg[2]]);
				cube([999*2,stage_flex_w,leg[2]+10]);
			}
		}
		
		//thin links between legs
		if(leg[2]-zflex_t > 2*bridge_dz){
			assign(n=floor((flex_z2-flex_z1)/bridge_dz))
			assign(dz=(flex_z2-flex_z1)/n )
			translate([0,stage_flex_w/2,flex_z1+dz]) repeat([0,0,dz],n-1) cube([leg_outer_w,2,0.5],center=true);
		}
	}
}

module actuator(){
	assign(brace=20, fw=stage_flex_w) union(){
		//leg (vertical bit)
		leg([leg[0],brace+fw,leg[2]],leg_middle_w);
		//arm (horizontal bit)
		sequential_hull(){
			translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,brace+fw,4]);
			translate([-actuator[0]/2,0,0]) cube([actuator[0],brace+fw+0,actuator[2]]);
			translate([-actuator[0]/2,0,0]) cube(actuator-[0,6,0]);
		}
		//nut seat
		translate([0,actuating_nut_r,0]) nut_seat_with_flex();
	}
}
module actuator_silhouette(h=999){
	linear_extrude(2*h,center=true){
		minkowski(){
			circle(r=zflex_l,$fn=12);
			projection() actuator();
		}
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

module xy_carriage(h=sample_z-stage_t/2){
    // This attaches to the XY stage and forms the mount for the Z stage
    hole_edge_x=leg_r-zflex_l-wall_t-base_t*tan(flex_angle);
    outer_x = hole_edge_x - xy_travel*sqrt(2);
    reflect([1,0,0]) sequential_hull(){
        translate([2+xy_travel,z_flexure_y1+zflex_l/2,0]) cube([stage_flex_w,wall_t,h]);
        translate([xy_carriage_r*sqrt(2)-z_flexure_y1-wall_t-zflex_l/2, z_flexure_y1+zflex_l/2+wall_t/2, 0]) cylinder(d=wall_t,h=h);
        hull(){
            translate([outer_x-wall_t/2, xy_carriage_r*sqrt(2)-outer_x, 0]) cylinder(d=wall_t,h=h);
            translate([outer_x-wall_t/2, xy_travel/sqrt(2)+wall_t/2, 0]) cylinder(d=wall_t,h=h);
            translate([outer_x-wall_t/2, 0, 0]) cylinder(d=wall_t,h=h);
            translate([xy_carriage_r*sqrt(2)-z_flexure_y1-wall_t-zflex_l/2, 0, 0]) cylinder(d=wall_t,h=h);
        }

    }
}

module z_axis(){
    z1 = 0;//actuator[2]+z_travel;
    z2 = flex_z2 - z_strut_t - z_travel;
    push_anchor_y = z_flexure_y1*0.5+z_flexure_y2*0.5-zflex_l/2;
    push_y = z_flexure_y1 - 3;
    union(){
        //start with the anchor
        translate([-stage_flex_w, z_flexure_y2 - zflex_l/2, 0]) mirror([0,1,0]) cube([stage_flex_w*2,10,flex_z2-z_travel]);
        
        //flexures and struts
        translate([0,0,z1]) repeat([0,0,z2-z1],2) difference(){
            //start with struts joining the XY carriage to the XYZ carriage
            union(){
                //struts
                reflect([1,0,0]) hull(){
                    translate([2+xy_travel, z_flexure_y1+zflex_l/2,0]) cube([stage_flex_w,d,z_strut_t]);
                    translate([0, z_flexure_y2-zflex_l/2,0]) cube([stage_flex_w,d,z_strut_t]);
                }
                //join struts in middle
                translate([0,push_anchor_y-z_flex_w/2,z_strut_t/2]) cube([stage_flex_w+4/2+xy_travel,z_flex_w,z_strut_t-1],center=true);
                translate([-stage_flex_w/2,push_anchor_y-d,1]) cube([stage_flex_w,zflex_l+2*d,zflex_t]);
            }
            //cut out the ends to make flexures
            translate([-999,z_flexure_y1-zflex_l/2,zflex_t]) cube(9999);
            translate([-999,z_flexure_y2+zflex_l/2,zflex_t]) mirror([0,1,0]) cube(9999);
        }
        
        //secondary Z carriage for the push actuator to connect to
        translate([-stage_flex_w/2,push_anchor_y+zflex_l,0]) hull(){
            cube([stage_flex_w,1.5*stage_flex_w,d]);
            translate([0,0,z2]) cube([stage_flex_w, push_y - push_anchor_y - zflex_l*1.5, z_strut_t/2]);
        }
    }
    
    //actuator
    union(){
        w=stage_flex_w;
        //push rod
        sequential_hull(){
            //start at the push-point
            translate([0,push_y+w/2+zflex_l/2,z2+2]) cube([w,w,d],center=true);
            translate([0,push_y+w/2+zflex_l/2,z2]) cube([w,w,d],center=true);
            translate([0,push_y-zflex_l/2-w/2,0]) cube([w,w,d],center=true);
        }
        //flexure linking push rod to carriage
        translate([0,push_y,zflex_t/2+z1]) repeat([0,0,z2-z1+1],2) cube([w,zflex_l,zflex_t],center=true);
        //actuator triangle
        actuator_w = ((leg_r-zflex_l-wall_t)*sqrt(2) - z_actuator_anchor)*2;
        reflect([1,0,0]) hull(){
            translate([-actuator_w/2,z_actuator_anchor-zflex_l,0]) cube([w,d,d]);
            translate([-w/2,push_y+zflex_l/2,0]) cube([w,d,2]);
            translate([-w/2,z_actuator_anchor-zflex_l-2,z_nut_z]) cube([w,2,2]);
        }
        translate([-actuator_w/2,z_actuator_anchor,0]) cube([actuator_w,wall_t*sqrt(2),z_strut_t]); //static bit
        //flexures from triangle to static anchor
        reflect([1,0,0]) translate([-actuator_w/2,z_actuator_anchor-zflex_l-d,0]) cube([w,zflex_l+2*d,zflex_t]);
    }
}

module z_actuator(){
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
module reinforcement_walls(){			
    //reinforcement "walls"
    //first, round the outside from the XY actuators to the illumination
    reflect([1,0,0]) sequential_hull(){
        rotate(-45) translate([12-2,actuating_nut_r+leg_r,0]) cube([wall_t,d,wall_h]);
         rotate(-45) translate([1,1,0]*(leg_r-zflex_l-wall_t/2)) rotate([1,-1, 0]*flex_angle) translate([0,0,-1]) cylinder(r=wall_t/2,h=wall_h+1);
        leg_frame(-135) translate([leg_middle_w/2+zflex_l-wall_t/2*tan(45/2),-zflex_l-wall_t/2,0]) rotate([1,1,0]*flex_angle) translate([0,0,-1]) cylinder(r=wall_t/2,h=flex_z2 - z_strut_t-z_travel*2+1+2);
        translate([0,-(leg_r+leg_middle_w/2)/sqrt(2)+wall_t/2,0]) cylinder(r=wall_t/2,h=flex_z2 - z_strut_t-z_travel*2);
    }
    //next, from the XY actuators to the Z actuator
    reflect([1,0,0]) hull(){
        leg_frame(45) translate([12-wall_t/2,actuating_nut_r,d]) cylinder(r=wall_t/2,h=wall_h,$fn=8);
        translate([0,z_nut_y,d]) cylinder(r=wall_t/2,h=wall_h,$fn=8);
    }
    //and from the Z flexure anchors to the Z actuator
    reflect([1,0,0]) sequential_hull(){
        rotate(-45) translate([1,1,0]*(leg_r-zflex_l-wall_t/2)) rotate([1,-1, 0]*flex_angle) translate([0,0,-1]) cylinder(r=wall_t/2,h=wall_h+1);
        translate([5+1,(leg_r-zflex_l-1)*sqrt(2)-5-wall_t/2,0.5]) rotate([0,-6,45]) cylinder(r=wall_t/2,h=max(wall_h, z_flexure_x*0.15 + z_strut_t+4+4),$fn=8);
        translate([5+wall_t/2,z_nut_y,0.5]) cylinder(r=wall_t/2,h=wall_h,$fn=8);
        //SEE ALSO the bridge over the Z actuator
    }
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){

	//legs
	each_nonactuator_leg() leg(leg, leg_middle_w);
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

    //Z axis
    xy_carriage();
    z_actuator();
    z_axis();

	//base
	difference(){
		union(){
			hull(){ //make it big enough to support legs and actuators
//				each_leg() translate([-leg_outer_w/2,-zflex_l-d,0]) cube([leg_outer_w,d,base_t]);
				each_actuator() translate([0,actuating_nut_r,0]) screw_seat_outline(h=base_t);
                linear_extrude(base_t) projection() reinforcement_walls();
			}
			
            reinforcement_walls();
		}
        
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8); //flat bottom
        
		each_actuator(){//cut-outs for actuators (XY)
			linear_extrude(2*xy_actuator_travel_top,center=true) minkowski(){ 
				projection() actuator();
				circle(r=1.5, $fn=8);
			}
			translate([0,actuating_nut_r,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		}
		//Z actuator cut-out
//		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
//		translate([-7/2,z_carriage_y,-d]) cube([7,z_nut_y-z_carriage_y,999]); //z actuating arm
        translate([0,-leg_r,0]) cube([(stage_flex_w+xy_travel)*2,leg_r,(z_strut_t+z_travel)*2],center=true);

		//central cut-out
        intersection(){
            sl = 2*(leg_r-zflex_l-wall_t-base_t*tan(flex_angle)*sqrt(2));
            rotate(45) cube([sl,sl,base_t*2+2*d],center=true);
            translate([0,wall_t*2,0]) cube([1,1,999]*(sl-leg_outer_w/2-wall_t)*sqrt(2),center=true);
        }

		//post mounting holes
		reflect([1,0,0]) translate([17.5,z_nut_y-2,0]) cylinder(r=4/2*1.1,h=999,center=true);
	}
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0])
        screw_seat(travel=xy_actuator_travel, motor_lugs=motor_lugs);
    
    //bridge over the Z actuator (for strength)
    //SEE ALSO the reinforcement "walls" above
    difference(){
        hull() reflect([1,0,0]){
            translate([5+1,(leg_r-zflex_l-1)*sqrt(2)-5-1,0.5]) rotate([0,-6,45]) translate([0,0,max(wall_h, z_flexure_x*0.15 + z_strut_t+4+4)-1]) cylinder(r=1,h=2,$fn=8);
            translate([5+1,z_nut_y,wall_h-1+0.5]) cylinder(r=1,1,$fn=8);
        }
        //Z actuator cut-out
		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
    }

}



//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
