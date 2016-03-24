/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope body                         *
*                                                                 *
* This is the chassis of the OpenFlexure microscope, an open      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
use <./nut_seat_with_flex.scad>;
use <./logo.scad>;
use <./dovetail.scad>;

d = 0.05;
$fn=32;

version_string = "5.14";

big_stage = true;
motor_lugs = true;

sample_z = big_stage?70:40; //height of the top of the stage
stage_t=5; //thickness of the stage (at thickest point, most is 1mm less)
leg_r = big_stage?30:25; //radius of innermost part of legs
hole_r = big_stage?15:10; //size of hole in the stage
xy_lever_ratio = big_stage?4.0/7.0:1.0; //mechanical advantage of actuator over stage
z_lever_ratio = big_stage?2.4:2.6; //as above, for Z axis (must be >1)

stage_flex_w = 4; //width of XY axis flexures
zflex_l = 1.5;    //length and height of flexures
zflex_t = 0.75;
flex_z1 = 0;      //height of lower flexures
flex_z2 = sample_z-stage_t; //height of upper flexures
z_strut_l = big_stage?20:15; //length of struts supporting Z carriage
z_strut_t = 6;  //thickness of above
z_flex_w = 4;   //width of above
leg = [4,stage_flex_w,flex_z2+zflex_t];
leg_middle_w = 12; //width of the middle part of each leg
objective_clip_y = big_stage?12:6;
objective_clip_w = 10;

nut_seat_r = 8.5;
actuator_pillar_r = nut_seat_r+1.5+2.5;
nut_seat_h = 14;
leg_outer_w = leg_middle_w + 2*zflex_l + 2*leg[0];
actuator = [6,(flex_z2 - flex_z1)*xy_lever_ratio,6];
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
base_t=1;
wall_h=15;
wall_t=2;
xy_foot = [1,1,0]*(leg_r+actuating_nut_r)/sqrt(2)-[15,0,0];
z_foot = [0,-(leg_r+leg_outer_w/2)/sqrt(2)+5,0];

module shear_x(amount=1){
    // Shear transformation: tilt the Y axis towards the X axis
    // e.g. if amount=1, then a straight line in Y will be
    // tilted to 45 degrees between X and Y, while X lines are
    // unchanged.  This is used in the Z axis.
	multmatrix([[1,amount,0,0],
					 [0,1,0,0],
					 [0,0,1,0],
					 [0,0,0,1]]) children();
}
module leg(){
    // The legs support the stage - this is either used directly
    // or via "actuator" to make the legs with levers
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
			n=floor((flex_z2-flex_z1)/bridge_dz);
			dz=(flex_z2-flex_z1)/n;
			translate([0,leg[1]/2,flex_z1+dz]) repeat([0,0,dz],n-1) cube([leg_outer_w,2,0.5],center=true);
		}
	}
}
module actuator(){
    // A leg that supports the stage, plus a lever to tilt it.
    // Includes the flexible nut seat actuating column.
    // TODO: find the code that unifies this with leg()
	brace=20;
    fw=stage_flex_w;
    union(){
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
			n=floor((flex_z2-flex_z1)/bridge_dz);
			dz=(flex_z2-flex_z1)/n;
			translate([0,leg[1]/2,flex_z1+dz]) repeat([0,0,dz],n-1) cube([leg_outer_w,2,0.5],center=true);
		}
	}
}
module actuator_silhouette(h=999){
    // This defines the cut-out from the base structure for the XY
    // actuators.
	linear_extrude(2*h,center=true){
		minkowski(){
			circle(r=zflex_l,$fn=12);
			projection() union(){
				actuator();
			}
		}
	}
}

module leg_frame(angle){
    // Transform into the frame of one of the legs of the stage
	rotate(angle) translate([0,leg_r,]) children();
}
module each_leg(){
    // Repeat for each of the legs of the stage
	for(angle=[45,135,-135,-45]) leg_frame(angle) children();
}
module each_actuator(){
    // Repeat this for both of the actuated legs (the ones with levers)
	reflect([1,0,0]) leg_frame(45) children();
}
module each_nonactuator_leg(){
    // Repeat this for both legs that don't have actuators.
	reflect([1,0,0]) leg_frame(135) children();
}

module z_axis(){
    // Flexures and struts for motion in the Z direction
	w=z_flex_w;
    reflect([1,0,0]) difference(){
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
			translate([0,-w,0]) cube([w,w,z_carriage[2]]); //static anchors
		}
		translate([d,0,-d]) cube([1,1,1]*9999); //stop things crossing the Y axis
		rotate([0,0,45]) cube([1,1,9999]*17,center=true);
	}
}
module z_actuator(){
	//Z actuating lever
	gap=z_carriage[0]*2-2*z_flex_w;
    difference(){
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
    // Moving carriage for the objective, incl. dovetail clip
	arm_length=10;
	clip_h=z_flexure_spacing-z_strut_t-3;
    arm_w=2;
	clip_outer_w=objective_clip_w+2*arm_w;
    inner_w = clip_outer_w - 2*arm_w;
	base_y=z_carriage_y-6;
	difference(){
		intersection(){
			union(){
				w1=z_carriage[0]*2;
                w2=clip_outer_w;
                dy=z_carriage_y-objective_clip_y;
                translate([0,objective_clip_y,0]) sequential_hull(){
					translate([-w1/2,dy,0]) cube([w1,z_carriage[1],2]);
					translate([-w2/2,dy,0]) cube([w2,d,10]);
					translate([-w2/2,0,0]) cube([w2,arm_length+arm_w,z_strut_t]);
					translate([-w2/2,dy-4,z_carriage[2]/2]) cube([w2,4,d]);
					translate([-w1/2,dy,z_carriage[2]-z_carriage[1]]) cube([w1,z_carriage[1],z_carriage[1]]);
				}
				translate([-clip_outer_w/2,objective_clip_y,0]) cube([clip_outer_w,dy-d,z_flexure_spacing+z_strut_t]);
			}
			rotate(45) cube([1,1,999]*z_flexure_x*sqrt(2),center=true);
		}
		// carve out the block to form a dovetail
        translate([0,objective_clip_y,0.5+d]) dovetail_clip_cutout([clip_outer_w,arm_length,999]);
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
		//TODO: this code is now in dovetail.scad.  Should use it!
        //sloped bottom to improve quality of the dovetail clip and
        //allow insertion of the optics from the bottom
        translate([0,objective_clip_y,0]){
            rotate([45,0,0]) cube([999,1,1]*sqrt(2)*2.5,center=true); //slope up arms
            hull() reflect([0,0,1]) translate([0,0,2.5]) rotate([0,45,0]) cube([inner_w/sqrt(2),8,inner_w/sqrt(2)],center=true);
        }
	}
}

module add_hull_base(h=1){
    // Take the convex hull of some objects, and add it in as a
    // thin layer at the bottom
    union(){
        intersection(){
            hull() children();
            cylinder(r=9999,$fn=8,h=h); //make the base thin
        }
        children();
    }
}

module wall_vertex(leg_angle, x, h=wall_h, y_tilt=-999, y=-zflex_l-wall_t/2){
    // A thin cylinder, close to one of the legs.  It
    // tilts inwards to clear the leg.  These form the
    // stiffening "wall" that runs around the base of 
    // the legs
    
    // leg_angle specifies the leg, x is the X position
    // of the vertex in that leg frame.  h is its height,
    // y and y_tilt override position and angle in y
    
    // unless specified, tilt the leg so the wall at the
    // edge is vertical (i.e. the bit at 45 degrees to
    // the leg frame)
    y_tilt = (y_tilt==-999) ? (x>0?6:-6) : y_tilt;
    intersection(){
        leg_frame(leg_angle) translate([x,y,0]){
            rotate([6,y_tilt,0]) cylinder(r=wall_t/2,h=h*2,center=true,$fn=8);
        }
        cylinder(r=9999,$fn=8,h=9999); //don't go below Z=0
    }
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
difference(){union(){

	//legs
	each_nonactuator_leg() leg();
	each_actuator() actuator();
	//flexures connecting bottoms of legs to centre
	each_leg() reflect([1,0,0]) translate([0,0,flex_z1]){
        w=stage_flex_w;
        translate([leg_middle_w/2-w,0,0.5]) hull()
			repeat([zflex_l,-zflex_l,0],2) cube([w,d,zflex_t]);
    }

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
        //TODO: use hole_from_bottom
		rotate(45) translate([0,0,flex_z2+2]) assign(f=[4,8,16,32]) for(i=[0:(len(f)-1)]) rotate(180/f[i]) translate([0,0,i*0.5]) cylinder(r=10/cos(180/f[i]),h=1.05,$fn=f[i],center=true);
		cylinder(r=hole_r,h=9999,$fn=64);
		each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-zflex_l-4,flex_z2+1.5]) cylinder(r=3/2,h=999);
	}
	
	//z axis
	z_axis();
	z_actuator();
	objective_clip_3();

	//base
	difference(){
		add_hull_base(base_t) union(){
			hull(){ //make it big enough to support legs and actuators
				each_leg() translate([-leg_outer_w/2,-zflex_l-d,0]) cube([leg_outer_w,d,base_t]);
				//each_actuator() translate([0,actuating_nut_r,0]) screw_seat_outline(h=base_t);
			}
            
            ////////////// Reinforcing wall //////////////////////////
            // Define the position of the outer vertices, such that
            // the wall slopes up to join the Z axis anchor 5mm below
            // the flexure
            zawall_h = z_flexure_spacing - 5; //height of wall near anchor
            zawall_x = (z_flexure_x+wall_t/2)*sqrt(2)-(leg_r-zflex_t-wall_t/2); //wall will just graze bottom of Z pillar
            zawall_tilt = -6 + atan(wall_t/zawall_h);
            // First, go around the inside of the legs, under the stage.
            reflect([1,0,0]) sequential_hull(){
                wall_vertex(-45, -leg_outer_w/2, wall_h);
                wall_vertex(45, leg_outer_w/2, wall_h);
                wall_vertex(45, -zawall_x, zawall_h, zawall_tilt);
                wall_vertex(135, zawall_x, zawall_h, -zawall_tilt);
                wall_vertex(135, -leg_outer_w/2, wall_h);
                wall_vertex(-135, leg_outer_w/2, wall_h);
            }
            // Next, link the XY actuators to the wall
            reflect([1,0,0]) sequential_hull(){
                wall_vertex(45, -12, wall_h, zawall_tilt, 
                                        y=actuating_nut_r);
                wall_vertex(135, zawall_x, zawall_h, -zawall_tilt);
            }
			
			//reinforcement "walls"
            //first, round the outside from the XY actuators to the illumination
/*			reflect([1,0,0]) translate([0,0,-d]) sequential_hull(){
				rotate(-45) translate([12-2,actuating_nut_r+leg_r,0]) cube([2,d,wall_h]); //side of actuator
//				#union(){
//					translate([z_flexure_x+1-2,-3,0]) cylinder(r=1,h=z_flexure_spacing-base_t);
//					leg_frame(-135) translate([-leg_outer_w/2,-zflex_l-2,0]) cube([d,2,d]);
//                    translate([(leg_r-zflex_l-1)*sqrt(2)-2,2,0.5]) rotate([-6,-6,45]) cylinder(r=1,h=wall_h,$fn=8);
//2				}
                leg_frame(-135) translate([-leg_r+zflex_l+4,-zflex_l-2,0]) rotate([6,6,0]) cube([d,2,z_flexure_spacing]);
                    translate([z_flexure_x-1,-z_flex_w,0]) cube([1,z_flex_w,min(z_flexure_spacing, ((leg_r-zflex_l-2)*sqrt(2)-z_flexure_x)/sin(6))]);
				leg_frame(-135) translate([leg_outer_w/2+1.5,-zflex_l-2,0]) rotate([6,-6,0]) cube([d,2,12]);
				mirror([1,0,0]) leg_frame(-135) translate([leg_outer_w/2+1.5,-zflex_l-2,0]) rotate([6,-6,0]) cube([d,2,12]);
			}
            //join the wall around the edge to the Z pillars
            reflect([1,0,0]) hull(){
                leg_frame(-135) translate([-leg_r+zflex_l+4,-zflex_l-2,0]) rotate([6,6,0]) cube([d,2,z_flexure_spacing]);
                translate([z_flexure_x-d,-z_flex_w,0]) cube([d,z_flex_w,z_flexure_spacing]);
            }
            //next, from the XY actuators to the Z actuator
            reflect([1,0,0]) hull(){
                leg_frame(45) translate([12-1,actuating_nut_r,-d]) cylinder(r=1,h=wall_h,$fn=8);
                translate([0,z_nut_y+10-1,-d]) cylinder(r=1,h=wall_h,$fn=8);
            }
            //and from the Z flexure anchors to the Z actuator
            reflect([1,0,0]) sequential_hull(){
                translate([(leg_r-zflex_l-1)*sqrt(2)-2,2,-d]) rotate([-6,-6,45]) cylinder(r=1,h=wall_h,$fn=8);
                translate([5+1,(leg_r-zflex_l-1)*sqrt(2)-5-1,-d]) rotate([0,-6,45])cylinder(r=1,h=max(wall_h, z_flexure_x*0.15 + z_strut_t+4+4),$fn=8);
                translate([5+1,z_nut_y,-d]) cylinder(r=1,h=wall_h,$fn=8);
                //SEE ALSO the bridge
            } */
		}
        
		each_actuator(){//cut-outs for actuators (XY)
			linear_extrude(2*xy_actuator_travel_top,center=true) minkowski(){ 
				projection() actuator();
				circle(r=1.5, $fn=8);
			}
			translate([0,actuating_nut_r,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		}
        //prevent things sticking out the bottom
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=8);
        
		//Z actuator cut-out
		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		translate([-7/2,z_carriage_y,-d]) cube([7,z_nut_y-z_carriage_y,999]); //z actuating arm

		//objective/stuff cut-out
		sequential_hull(){
			translate([0,z_flexure_x+1.5-d,0]) cube([2*d,2*d,999],center=true);
			translate([0,0,0]) cube([2*(z_flexure_x+0.5),2,999],center=true);
			translate([0,0,0]) cube([2*(z_flexure_x-z_flex_w-d),2*d,999],center=true);
			translate([0,8-(z_flexure_x-z_flex_w-d),0]) cube([16,2*d,999],center=true);
		}

		//post mounting holes
		reflect([1,0,0]) translate([20,z_nut_y+2,0]) cylinder(r=4/2*1.1,h=999,center=true);
        
        //logo
        x_shift = 3.1;
        size = big_stage?0.28:0.25;
        //translate([z_flexure_x+x_shift,0,10])
        logo_d = 0.7; 
        //this is a complicated transformation!  The rationale is:
        // 1. pivot about the corner of the base next to the leg
        rotate(45) 
        translate([leg_outer_w/2,-leg_r+zflex_l,0])
        // 2. pivot in so that we're parallel to the edge
        rotate([90-4, 0, atan((leg_r-zflex_l-12)/(leg_r+actuating_nut_r-leg_outer_w/2))])
        // 3. indent so we touch the surface
        translate([10,10,0])
        //rotate([90,0,atan(((leg_r+actuating_nut_r-12)/sqrt(2))/((leg_r+actuating_nut_r+12)/sqrt(2)-z_flexure_x-x_shift))])
        {
            //rotate([-4,0,0]) 
            translate([3,2,0.0]) scale([size,size,5]) logo_and_name();
            translate([leg_r+actuating_nut_r-26,-5,0]) linear_extrude(2) text(str("v",version_string, big_stage?"-LS":"", motor_lugs?"-M":""), size=3, font="Calibri",halign="right");
        }
            
	}
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0])
        screw_seat(travel=xy_actuator_travel, motor_lugs=motor_lugs);
	translate([0,z_nut_y,0]) 
        screw_seat(travel=z_actuator_travel, motor_lugs=motor_lugs);
    
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
	////////////// illumination/back foot mount ///////////////////
	union(){
		sequential_hull(){ //leg structure (oval tube)
			hull() reflect([1,0,0]) leg_frame(-135) translate([leg_outer_w/2,-zflex_l-2,0]){
				translate([0,0,base_t-d]) rotate([6,6,0]) cube([d,2,12]);
				cube([d,2,base_t]);
			}
            translate([-8,-leg_r,0]) cube([16,2,12]);
		}
        translate([0,-leg_r-8,0]) dovetail_clip([16,8,12]);
	}
}

translate([0,-99,-1]) cube(999);
}

//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
