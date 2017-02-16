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

use <./utilities.scad>;
use <./compact_nut_seat.scad>;
use <./logo.scad>;
use <./dovetail.scad>;
include <./microscope_parameters.scad>; //All the geometric variables are now in here.

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
module leg(brace=stage_flex_w){
    // The legs support the stage - this is either used directly
    // or via "actuator" to make the legs with levers
    fw=stage_flex_w;
	union(){
       	//leg
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
        leg(brace=brace);

		//arm (horizontal bit)
		difference(){
            sequential_hull(){
                w = actuator[0];
                translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,brace+fw,4]);
                translate([-w/2,0,0]) cube([w,brace+fw+0,actuator[2]]);
                translate([-w/2,0,0]) cube(actuator);
            }
            //don't foul the actuator column
            translate([0,actuating_nut_r,0]) actuator_end_cutout(); 
        }
		//nut seat
		translate([0,actuating_nut_r,0]) actuator_column(h=actuator_h); 
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
module condenser_mounting_screws(d=3*0.95, h=16, center=true){
    for(p = illumination_arm_screws){
        translate(p) cylinder(d=d, h=h,center=center);
    }
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
    difference(){
		sequential_hull(){
			translate([-2,z_nut_y,0]) cube([4,d, z_strut_t]); //thin part of actuator
			//translate([-2,z_flexure_x-2,0])cube([4,6, z_strut_t]); //taper
            translate([-2,z_flexure_x-2,0])cube([4,2, z_strut_t+4]); //join to raised struts
		}
        //make sure we don't foul the actuator column
        translate([0,z_nut_y,0]) actuator_end_cutout(); 
	}
	translate([0,z_nut_y,0]) actuator_column(actuator_h);
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
        translate([0,objective_clip_y,0]) dovetail_clip_cutout([clip_outer_w,arm_length,999],solid_bottom=0.5,slope_front=2.5);
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
module add_roof(inner_h){
    // Take the convex hull of some objects, and add the top
    // of it as a roof.  NB you must specify the height of
    // the underside of the roof - finding it automatically
    // would be too much work...
    union(){
        difference(){
            hull() children();
            cylinder(r=9999,$fn=8,h=inner_h);
        }
        children();
    }
}
module wall_vertex(r=wall_t/2, h=wall_h, x_tilt=0, y_tilt=0){
    // A cylinder, rotated by the given angles about X and Y,
    // but with the top and bottom kept in the XY plane
    // (i.e. it's sheared rather than tilted).    These form the
    // stiffening "wall" that runs around the base of 
    // the legs
    hull() repeat([tan(y_tilt), -tan(x_tilt), 1]*(h-d), 2){
        cylinder(r=r, h=d, $fn=8);
    }
}
module inner_wall_vertex(leg_angle, x, h=wall_h, y_tilt=-999, y=-zflex_l-wall_t/2){
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
    leg_frame(leg_angle) translate([x,y,0]){
            wall_vertex(h=h,x_tilt=6,y_tilt=y_tilt);
    }
}

module z_anchor_wall_vertex(){
    // This is the vertex of the supporting wall nearest
    // to the Z anchor - it doesn't make sense to use the
    // function above as it's got the wrong symmetry.
    // We also use this in a few places so it's worth saving
    translate([-z_flexure_x-wall_t/2,-wall_t/2,0]){
        wall_vertex(h=zawall_h, y_tilt=atan(wall_t/zawall_h));
    }
}

module place_on_wall(){
    //this is a complicated transformation!  The wall runs from
    wall_start = [z_flexure_x+wall_t/2,-wall_t/2,0]; // to
    wall_end = ([1,1,0]*(leg_r+actuating_nut_r)
                 +[1,-1,0]*(ss_outer()[0]/2-wall_t/2))/sqrt(2);
    wall_disp = wall_end - wall_start; // vector along the wall base
    // pivot about the starting corner of the wall so X is along it
    translate(wall_start) rotate(atan(wall_disp[1]/wall_disp[0]))
    // move out to the surface (the above are centres of cylinders)
    // and then align y with the vertical axis of the wall
    translate([0,-wall_t/2,0]) rotate([90-atan(wall_t/zawall_h/sqrt(2)),0,0])
    // now X and Y are in the plane of the wall, and z=0 is its surface.
    children();
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
union(){

	//legs
	reflect([1,0,0]) leg_frame(135) leg();
	each_actuator() actuator();
	//flexures connecting bottoms of legs to centre
	each_leg() reflect([1,0,0]) translate([0,0,flex_z1]){
        w=stage_flex_w;
        translate([leg_middle_w/2-w,0,0.5]) hull()
			repeat([1,-1,0]*(zflex_l+wall_t/2),2) cube([w,d,zflex_t]);
    }

	//flexures between legs and stage
	difference(){
		hull() each_leg() translate([0,0,flex_z2+zflex_t/2+0.5]) cube([leg_middle_w,d,zflex_t],center=true);
		hull() each_leg() cube([leg_middle_w-2*stage_flex_w,d,999],center=true);
	}

	//stage
   // this must get built up carefully: we start with the bridges round the edge, then work inwards.
	difference(){
		hull() each_leg() translate([0,-zflex_l-d,flex_z2+1+(stage_t-1)/2]) cube([leg_middle_w+2*zflex_l,2*d,stage_t-1],center=true); //hole in the stage
        translate([0,0,flex_z2+1]) rotate(45) hole_from_bottom(hole_r,h=999,base_w=2*(leg_r+leg_middle_w/2-stage_flex_w - hole_r));
		each_leg() reflect([1,0,0]) translate([leg_middle_w/2,-zflex_l-4,flex_z2+1.5]) cylinder(r=3/2*0.95,h=999); //mounting holes
	}
	
	//z axis
    difference(){
        z_axis(); //some of the condenser mount screws pass the Z axis
        condenser_mounting_screws(h=18,d=3*0.95,center=true);
    }
    z_actuator();
    objective_clip_3();

	//base
	difference(){
		union(){
            ////////////// Reinforcing wall and base /////////////////
            // First, go around the inside of the legs, under the stage.
            // This starts at the Z nut seat.  Add_hull generates the 
            // flat base of the structure.  I've split it into two
            // blocks, because the shape is not convex so the base
            // would be bigger than the walls otherwise.
            add_hull_base(base_t) reflect([1,0,0]) sequential_hull(){
                //inner_wall_vertex(-45, -leg_outer_w/2-wall_t/2, zbwall_h);
                inner_wall_vertex(45, leg_outer_w/2+wall_t/2, zbwall_h);
                inner_wall_vertex(45, -leg_outer_w/2, zawall_h);
                z_anchor_wall_vertex();
                inner_wall_vertex(135, leg_outer_w/2, zawall_h);
                inner_wall_vertex(135, -leg_outer_w/2, wall_h);
                inner_wall_vertex(-135, leg_outer_w/2, wall_h);
            }
            add_hull_base(base_t) {
                // Next, link the XY actuators to the wall
                reflect([1,0,0]) sequential_hull(){
                    z_anchor_wall_vertex(); // join at the Z anchor
                    // anchor at the same angle on the actuator
                    // NB the base of the wall is outside the
                    // base of the screw seat
                    leg_frame(45) translate([-ss_outer()[0]/2+wall_t/2,actuating_nut_r,0]){
                        rotate(-45) wall_vertex(y_tilt=atan(wall_t/zawall_h));
                    }
                    // neatly join to the screw seat (actuator column)
                    leg_frame(45) translate([0,actuating_nut_r,0]) screw_seat_outline(h=wall_h);
                }
                // Link the Z actuator to the wall
                add_roof(zbwall_h-2) reflect([1,0,0]) hull(){
                    translate([-7/2-wall_t/2,z_nut_y,0]) wall_vertex(h=zbwall_h);
                    inner_wall_vertex(45, leg_outer_w/2+wall_t/2, zbwall_h);
                }
                // Finally, link the actuators together
                reflect([1,0,0]) hull(){
                    leg_frame(45) translate([ss_outer()[0]/2-1,actuating_nut_r,-d]) cylinder(r=1,h=wall_h,$fn=8);
                    translate([0,z_nut_y+ss_outer()[1]/2-1,-d]) cylinder(r=1,h=wall_h,$fn=8);
                }
                // add a small object to make sure the base is big enough
                wall_vertex(h=base_t);
            }
            
            //screw supports for adjustment of condenser angle/position
            // (only useful if screws=true in the illumination arm)
            condenser_mounting_screws(h=10,d=6,center=false);
            // clip for illumination/back foot (if not using screws)
            translate([0,illumination_clip_y,0]) mirror([0,1,0]) dovetail_m([12,2,12]);
                    
		}
        //////  Things we need to cut out holes for... ///////////
        // XY actuator cut-outs
		each_actuator(){
			actuator_silhouette(xy_actuator_travel+actuator[2]);
			translate([0,actuating_nut_r,0]) screw_seat_outline(h=999,adjustment=-d,center=true);
		}
		//Z actuator cut-out
		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true);

		// Central cut-out for Z axis, inc. actuator arm
        intersection(){
            sequential_hull(){
                h=999;
                translate([0,z_nut_y,0]) cube([7,d,h],center=true);
                translate([0,z_flexure_x+1.5-7/2,0]) cube([7,2*d,h],center=true);
                translate([0,0,0]) cube([2*(z_flexure_x+0.5),1,h],center=true);
                translate([0,0,0]) cube([2*(z_flexure_x-z_flex_w),1,h],center=true);
                translate([0,8-(z_flexure_x-z_flex_w-d),0]) cube([16,2*d,h],center=true);
            }
            // Limit the height so it slopes up gently to allow for
            // actuator travel, etc.
            sequential_hull(){
                translate([0,-999,0]) cube([999,d,z_strut_t+1]*2,center=true);
                cube([999,d,z_strut_t+1]*2,center=true);
                translate([0,z_nut_y,0]) cube([999,d,z_strut_t+z_actuator_travel+1]*2,center=true);
            }
		}
        
		//post mounting holes
		//reflect([1,0,0]) translate([20,z_nut_y+2,0]) cylinder(r=4/2*1.1,h=999,center=true);
        
        // screw holes for adjustment of condenser angle/position
        // (only useful if screws=true in the illumination arm)
        condenser_mounting_screws(h=18,d=3*0.95,center=true);
        
        //////////////// logo and version string /////////////////////
        size = big_stage?0.28:0.22;
        place_on_wall() translate([8,wall_h-2-15*size,-0.5]) 
        scale([size,size,10]) logo_and_name(version_string);
        
        mirror([1,0,0]) place_on_wall() translate([8,wall_h-2-15*size,-0.5]) 
        scale([size,size,10]) oshw_logo();
	} ///////// End of things to chop out of base/walls ///////
    
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0]){
        screw_seat(h=actuator_h, travel=xy_actuator_travel, motor_lugs=motor_lugs);
    }
	translate([0,z_nut_y,0]){
        screw_seat(h=actuator_h, travel=z_actuator_travel, motor_lugs=motor_lugs);
    }
}

//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
