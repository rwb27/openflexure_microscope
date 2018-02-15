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
use <./z_axis.scad>;
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

            //flexure bridges between the legs
            zs = [flex_z1, flex_z2]; //heights of bridges between legs
            bs = [brace, 0]; //"brace positions" - a nonzero value here
                             //widens the leg, and adds another flexure
                             //at the new position.  bs[i]=fw will double
                             //the width of the flexure, while a larger 
                             //value produces two distinct flexures.
			for(i=[0,1]) translate([0,0,zs[i]]){
				translate([-d,0,0]) hull() repeat([0,bs[i],0],2) //solid part
                        cube([leg_middle_w/2+d,leg[1],stage_t-0.2*leg[1]]);
				translate([-d,0,0]) repeat([0,bs[i],0],2) //flexures
                        cube([leg_middle_w/2+zflex_l+leg[0],leg[1],zflex_t]);
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
    // No longer includes the flexible nut seat actuating column.
    // TODO: find the code that unifies this with leg()
	brace=20;
    fw=stage_flex_w;
    w = actuator[0];
    union(){
        leg(brace=brace);

		//arm (horizontal bit)
		difference(){
            sequential_hull(){
                translate([-leg_middle_w/2,0,0]) cube([leg_middle_w,brace+fw,4]);
                translate([-w/2,0,0]) cube([w,brace+fw+0,actuator[2]]);
                translate([-w/2,0,0]) cube(actuator);
            }
            //don't foul the actuator column
            translate([0,actuating_nut_r,0]) actuator_end_cutout(); 
        }
        
        //flag (for the end-stop sensor)
        if(endstops) sequential_hull(){
            translate([-w/2,0,0]) cube([w,brace,actuator[2]]);
            translate([0,0,zawall_h]) cube([w/2,6,d]);
            translate([0,0,zawall_h + 6]) cube([w/2,6,d]);
        }
	}
}
module actuator_silhouette(h=999){
    // This defines the cut-out from the base structure for the XY
    // actuators.
    linear_extrude(2*h,center=true) minkowski(){
        circle(r=zflex_l,$fn=12);
        projection() actuator();
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
    smatrix(xz=tan(y_tilt), yz=-tan(x_tilt)) cylinder(r=r, h=h, $fn=8);
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

module z_bridge_wall_vertex(){
    // This is the vertex of the "inner wall" nearest the
    // new (cantilevered) Z axis.
    inner_wall_vertex(45, leg_outer_w/2+wall_t/2, zbwall_h);
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

module y_actuator_wall_vertex(x=1){
    // A wall vertex for the y actuator.  x=-1,1 picks the side
    // of the actuator where the vertex is placed.
    leg_frame(45) translate([x*(ss_outer()[0]/2-wall_t/2),
                             actuating_nut_r, 0]) wall_vertex();
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

module xy_limit_switch_mount(d=3.3*2, h=6){
    // A mount for the XY limit switch (M3)
    leg_frame(45) translate([-9, -zflex_l-zawall_h*sin(6)-3.3, zawall_h-6]) cylinder(d=d,h=h);
}

///////////////////// MAIN STRUCTURE STARTS HERE ///////////////
difference(){
union(){

	//legs (incl. actuators)
	reflect([1,0,0]) leg_frame(135) leg();
	each_actuator(){
        actuator();
		translate([0,actuating_nut_r,0]) actuator_column(h=actuator_h, join_to_casing=true);
    }
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
    z_axis_flexures();
    z_axis_struts();
    objective_mount();
    translate([0,z_nut_y,0]) actuator_column(actuator_h, tilt=z_actuator_tilt, join_to_casing=true);

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
                mirror([1,0,0]) z_bridge_wall_vertex();
                z_bridge_wall_vertex();
                inner_wall_vertex(45, -leg_outer_w/2, zawall_h);
                z_anchor_wall_vertex();
                inner_wall_vertex(135, leg_outer_w/2, zawall_h);
                inner_wall_vertex(135, -leg_outer_w/2, wall_h);
                inner_wall_vertex(-135, leg_outer_w/2, wall_h);
            }
            // add mounts for the optical end-stops for X and Y
            reflect([1,0,0]) hull(){
                inner_wall_vertex(45, -9, zawall_h);
                xy_limit_switch_mount();
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
                }
                // Casing for the Z axis
                intersection(){
                    linear_extrude(h=999) minkowski(){
                        circle(r=wall_t+1);
                        hull() projection() z_axis_struts();
                    }
                    hull(){
                        reflect([1,0,0]) z_bridge_wall_vertex();
                        translate([-99,z_anchor_y,0]) cube([999,4,z_flexures_z2+2]);
                        translate([0,z_nut_y,0]) cylinder(d=10,h=20);
                    }
                }
                // Connect the Z anchor to the XY actuators
                reflect([1,0,0]) hull(){
                    translate([-(z_anchor_w/2+wall_t/2+1), z_anchor_y + 1, 0]) 
                                 wall_vertex();
                    y_actuator_wall_vertex();
                }
                    
                // Finally, link the actuators together
                reflect([1,0,0]) hull(){
                    y_actuator_wall_vertex();
                    translate([0,z_nut_y+ss_outer()[1]/2-wall_t/2,0]) wall_vertex();
                }
                // add a small object to make sure the base is big enough
                wall_vertex(h=base_t);
            }
            //these are the holes to mount onto the baseplate 
            for(p=base_mounting_holes) {
                if(p[1]<0 && p[0]>0) reflect([1,0,0]) hull(){
                    translate([z_flexure_x,0,0]) rotate(-120) cube([10,d,10]);
                    translate(p) cylinder(r=4*1.1,h=3);
                }
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
		translate([0,z_nut_y,0]) screw_seat_outline(h=999,adjustment=-d,center=true, tilt=z_actuator_tilt);

		// Central cut-out for optics
        intersection(){
            sequential_hull(){
                h=999;
                aw = 2*column_base_radius() + 3;
                translate([0,z_flexure_x+1.5-18/2,0]) cube([18,2*d,h],center=true);
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
        // Z actuator and struts
        z_axis_clearance();
        // access hole for the objective mounting screw
        translate([0,objective_mount_back_y, z_flexures_z2/2]) 
                rotate([-75,0,0]) cylinder(h=999, d=10, $fn=16);
        
        //post mounting holes 
        for(p=base_mounting_holes) translate(p){ 
             cylinder(r=3/2*1.1,h=999,center=true); 
             translate([0,0,3]) cylinder(r=3*1.1, h=999); 
        }
        
        // mount for limit switches
        if(endstops){
            reflect([1,0,0]) xy_limit_switch_mount(d=2.9, h=10);
        }
        
        // screw holes for adjustment of condenser angle/position
        // (only useful if screws=true in the illumination arm)
        condenser_mounting_screws(h=18,d=3*0.95,center=true);
        
        //////////////// logo and version string /////////////////////
        size = big_stage?0.25:0.2;
        place_on_wall() translate([8,wall_h-2-15*size,-0.5]) 
        scale([size,size,10]) logo_and_name(version_string);
        
        mirror([1,0,0]) place_on_wall() translate([8,wall_h-2-15*size,-0.5]) 
        scale([size,size,10]) oshw_logo();
	} ///////// End of things to chop out of base/walls ///////
    
	//Actuator housings (screw seats and motor mounts)
	each_actuator() translate([0,actuating_nut_r,0]){
        screw_seat(h=actuator_h, travel=xy_actuator_travel, motor_lugs=motor_lugs, extra_entry_h=actuator[2]+2);
    }
    difference(){
        translate([0,z_nut_y,0]) screw_seat(h=actuator_h, 
                                            tilt=z_actuator_tilt, 
                                            travel=z_actuator_travel, 
                                            motor_lugs=motor_lugs, 
                                            lug_angle=180);
        z_axis_clearance(); //make sure the actuator can get in ok!
    }
}
//reflect([1,0,0]) translate([13.5,0,0]) rotate([0,90,0]) cylinder(r=999,h=999,$fn=4);
//rotate([90,0,0]) cylinder(r=999,h=999,$fn=4);
//translate([0,0,50]) cylinder(r=999,h=999,$fn=4);
}
//%rotate(180) translate([0,2.5,-2]) cube([25,24,2],center=true);
