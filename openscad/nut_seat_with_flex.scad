/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Nut seat (core of the actuator)         *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>;

ns_flex = [2.5,1,0.75];
ns_outer_r = 7;
ns_top_h = 20;
band_clearance_r = 3;
ss_wall_t = 2;
d=0.05;
actuator_h = 6;
zflex_l = 1.5;    //length and height of flexures
zflex_t = 0.75;

function ss_inner(travel)=[2*(ns_outer_r+band_clearance_r),2*(ns_outer_r+1.5),ns_top_h+travel];
function ss_outer(travel)=ss_inner(travel)+[2*ss_wall_t,2*ss_wall_t,3];

module cable_tie_point(t=1.5, gap=[3,1.5,4]){
    w=gap[0];
    sequential_hull(){
        translate([0,-t/2,-gap[1]-gap[2]/2-5*t/4]) cube([w,t,t/2],center=true);
        translate([0,gap[1]+t/2,-gap[2]/2-t/4]) cube([w,t,t/2],center=true);
        translate([0,gap[1]+t/2,gap[2]/2+t/2]) cube([w,t,t],center=true);
        translate([0,-t/2,gap[2]/2+t/2]) cube([w,t,t],center=true);
    }
}

module screw_seat(travel=5, motor_lugs=false){
	inner=ss_inner(travel);
	outer=ss_outer(travel);
    top_h=outer[2]-1.5;
    motor_shaft_pos=[0,20,outer[2]+d];
    motor_screw_pos=[35/2,motor_shaft_pos[1]-7.8,outer[2]+10];
    t=3;
    module inner_silhouette(h=d){
        resize([inner[0],inner[1],h]) cylinder(r=inner[1]);
    }
	difference(){
		union(){ 
            //////// body of seat (cylinder with conical top)
            difference(){
                hull(){
                    resize(outer-[0,0,1.5]) cylinder(r=outer[1]); //body
                    translate([0,0,outer[2]-1.5]) cylinder(r=outer[0]/2-5,h=2); //body
                }
                //hole for elastic bands	
                reflect([1,0,0]) translate([outer[0]/2-2.5,0,inner[2]]) cube([5+d,outer[1],2*travel],center=true);
			}
            //////// motor lugs
            if(motor_lugs) reflect([1,0,0]) difference(){
                union(){
                    hull(){
                        translate(motor_screw_pos) mirror([0,0,1]) cylinder(r=5,h=3);
                        translate([0,0,inner[2]-travel-5]) resize([outer[0],outer[1],5]) cylinder(r=outer[1]);
                    }
                    rotate(30) translate([0,outer[1]/2,inner[2]-travel-10]) cable_tie_point();
                }
                //space for gears
                translate([0,0,outer[2]-1.5]) cylinder(r1=8,r2=17,h=2);
                translate([0,0,outer[2]-1.5+2-d]) cylinder(h=999,r=17);
                //hollow inside of the structure
                sequential_hull(){
                    translate([0,0,0]) inner_silhouette();
                    translate([0,0,inner[2]-travel]) inner_silhouette();
                    translate([0,0,outer[2]+d]) resize([30,inner[1],999]) cylinder(h=999,r=15);
                }
                //mounting screws
                translate(motor_screw_pos) cylinder(r=1.9,h=20,center=true);
            }

		//		
		}

		//clearance for actuator
		translate([0,0,-d]) resize(inner) cylinder(r=inner[1]);
		translate([0,-outer[1]/2,0]) cube([8,ss_wall_t*3,(actuator_h+travel)*2],center=true);

		//hole for nut at top
		translate([0,0,inner[2]]) cube([3.3,inner[1]-0.7,1],center=true);
		translate([0,0,0]) cylinder(r=3.3/2,h=999, $fn=16, center=true);
        
        //hole for removal of actuator from print bed
        hull(){
            translate([0,outer[1]/2,1]) cube([6,outer[1],d],center=true);
            translate([0,outer[1]/2,6]) cube([2,outer[1],d],center=true);
	}
}

module screw_seat_spring(travel=5, motor_lugs=false){
	inner=ss_inner(travel);
	outer=ss_outer(travel);
    top_h=outer[2]-1.5;
    motor_shaft_pos=[0,20,outer[2]+d];
    motor_screw_pos=[35/2,motor_shaft_pos[1]-7.8,outer[2]+10];
    t=3;
    module inner_silhouette(h=d){
        resize([inner[0],inner[1],h]) cylinder(r=inner[1]);
    }
	difference(){
		union(){ 
            //////// body of seat (cylinder with conical top)
            difference(){
                hull(){
                    resize(outer-[0,0,1.5]) cylinder(r=outer[1]); //body
                    translate([0,0,outer[2]-1.5]) cylinder(r=outer[0]/2-5,h=2); //body
                }
                //hole for spring
                translate([0,outer[1]/2-2.5,inner[2]]) cube([outer[0],5+d,20],center=true);
			}
            //////// motor lugs
            if(motor_lugs) reflect([1,0,0]) difference(){
                union(){
                    hull(){
                        translate(motor_screw_pos) mirror([0,0,1]) cylinder(r=5,h=3);
                        translate([0,0,inner[2]-travel-5]) resize([outer[0],outer[1],5]) cylinder(r=outer[1]);
                    }
                    rotate(30) translate([0,outer[1]/2,inner[2]-travel-10]) cable_tie_point();
                }
                //space for gears
                translate([0,0,outer[2]-1.5]) cylinder(r1=8,r2=17,h=2);
                translate([0,0,outer[2]-1.5+2-d]) cylinder(h=999,r=17);
                //hollow inside of the structure
                sequential_hull(){
                    translate([0,0,0]) inner_silhouette();
                    translate([0,0,inner[2]-travel]) inner_silhouette();
                    translate([0,0,outer[2]+d]) resize([30,inner[1],999]) cylinder(h=999,r=15);
                }
                //mounting screws
                translate(motor_screw_pos) cylinder(r=1.9,h=20,center=true);
            }

		//		
		}

		//clearance for actuator
		translate([0,0,-d]) resize(inner) cylinder(r=inner[1]);
		translate([0,-outer[1]/2,0]) cube([8,ss_wall_t*3,(actuator_h+travel)*2],center=true);

		//hole for nut at top
		translate([0,0,inner[2]]) cube([inner[0]-0.7,3.3,1],center=true);
		translate([0,0,0]) cylinder(r=3.3/2,h=999, $fn=16, center=true);
        }
	}
}

module nut_seat_spring(){
	outer_r=5.5; //outer radius
	top_h=ns_top_h; //overall height
	union(){
		//central nut seat
		difference(){
			union(){
				cylinder(r=outer_r,h=ns_top_h);
                difference(){
                    cylinder(r=outer_r+2,h=6);
                    translate([-99,0,6]) rotate([90+30,0,0]) cube([1,1,1]*999);
                }
				
			}

			//nut
			rotate(30) translate([0,0,ns_top_h-9]) nut_from_bottom(3, h=7,chamfer_h=4);
			//make sure the hole for the nut prints ok in the overhang
			//essentially we ensure that the overhang never goes
			//more than 45 degrees (the hexagonal hole would do this)
			//then bridge it at the top.  This tapers nicely into
			//the hexagonal nut hole to avoid spaghetti.
			assign(r=3*0.9*1.2+0.75) assign(w=r*cos(30)*0.8*2) translate([0,0,actuator_h]) sequential_hull(){
				rotate(30) cylinder(r=r,$fn=6,h=r*1.5);
				translate([-w/2,-r,0]) cube([w,r,r]);
				translate([-r*cos(30)*0.8,-999,0]) cube([w,2*r,r]);
			}
			//flexures
			translate([0,0,zflex_t+1]) cube([999,zflex_l,2],center=true);
			//wedge to make flexure
			hull(){
				translate([0,0,zflex_t+1.75]) cube([999,zflex_l,0.5],center=true);
				translate([-999,-outer_r-d,actuator_h+1]) cube([999*2,d,outer_r+4+zflex_t-actuator_h-1]);
			}
			translate([-999,-ns_outer_r-1,actuator_h]) cube([999*2,3,2]); //truncate the yoke so it has a flat bit to mesh neatly with the actuator
		}
	}
}

/*union(){
    screw_seat_spring(5);
    nut_seat_spring();
    translate([-3,-20-4,0]) cube([6,20,6]);
    difference(){
        reflect([1,0,0]) translate([4,-20-4-1-2,0]) cube([2,22,8]);
        scale([0.95,0.95,1]) screw_seat_outline(center=true);
    }
    translate([-6,-20-4-1-2,0]) cube([6*2,2,4]);
    translate([-3,-20-4-1-2,0]) cube([6,6,0.75]);
}*/


module screw_seat_silhouette(adjustment=0,travel=5){
	assign(inner=ss_inner(travel))
	assign(outer=ss_outer(travel))
	resize([outer[0]+adjustment,outer[1]+adjustment]) circle(r=outer[1]); //body
}
module screw_seat_outline(h=999,adjustment=0,center=false){
	linear_extrude(h,center=center) screw_seat_silhouette(adjustment);
}
module elastic_band_base(h=15,tilt=7){
	assign(inner=ss_inner(5))
	assign(outer=ss_outer(5))
	intersection(){
		translate([-1,-1,0]*999) cube([1,1,1]*999*2); //make sure there's nothing below the XY plane
		translate([0,outer[1]/2,0]) rotate([-tilt,0,0]) translate([0,-outer[1]/2,0]) union(){ //tip over from one corner to make foot
			difference(){
				translate([0,0,-10]) resize([outer[0],outer[1],h+10]) cylinder(r=outer[1]); //body (with some below zero to allow spare when we tilt over)
				translate([0,0,-20]) difference(){
					resize([inner[0]-d,inner[1],999]) cylinder(r=inner[1]); //cutout for nut seat
					cube([inner[0]-8,999,20*2+6],center=true); //crossbar for bands
				}
				//indents for elastic bands
				reflect([0,1,0]) translate([0,4,0]) rotate([5,0,0]){
				//	cube([999,2,6],center=true);
					translate([0,0,-10]) cube([inner[0]-7,2,22],center=true);
				}
				//clearance for actuator arm
				translate([0,999,h]) cube([9,999*2,12],center=true);
			}
			intersection(){ //grips for hole in microscope
				difference(){ //hollow extruded ellipse
					translate([0,0,h-5]) resize([inner[0],inner[1],5+1]) cylinder(r=inner[1]);
					translate([0,0,h-6]) resize([inner[0],inner[1],6+2]) cylinder(r1=inner[1],r2=inner[1]-1.5);
				}
				hull(){ //just the bits at either side
					translate([0,0,-10]) cube([999,6,d],center=true);
					translate([0,0,h+1]) cube([999,6,d],center=true);
				}
			}
		}
	}
}
	

module nut_seat_with_flex(){
    // Flexible actuator, consisting of a nut seat in a
    // column, so that the nut stays vertical even if the
    // beam at the bottom of the actuator tilts.
	outer_r=ns_outer_r; //outer radius
	top_h=ns_top_h; //overall height
    difference(){
        union(){
            cylinder(r=ns_outer_r,h=ns_top_h);
            reflect([1,0,0]) sequential_hull(){
                translate([0,0,top_h-8]) cylinder(r=ns_outer_r,h=d);
                translate([0,0,top_h-1]) scale([1+2/ns_outer_r,1,1]) cylinder(r=ns_outer_r,h=1);
            } //flare the top
        }

        //nut
        rotate(30) translate([0,0,ns_top_h-9]) nut_from_bottom(3, h=7,chamfer_h=4);
        //make sure the hole for the nut prints ok in the overhang
        //essentially we ensure that the overhang never goes
        //more than 45 degrees (the hexagonal hole would do this)
        //then bridge it at the top.  This tapers nicely into
        //the hexagonal nut hole to avoid spaghetti.
        assign(r=3*0.9*1.2+0.75) assign(w=r*cos(30)*0.8*2) translate([0,0,actuator_h]) sequential_hull(){
            rotate(30) cylinder(r=r,$fn=6,h=r*1.5);
            translate([-w/2,-r,0]) cube([w,r,r]);
            translate([-r*cos(30)*0.8,-999,0]) cube([w,2*r,r]);
        }
        //flexures
        translate([0,0,zflex_t+1]) cube([999,zflex_l,2],center=true);
        //wedge to make flexure
        hull(){
            translate([0,0,zflex_t+1.75]) cube([999,zflex_l,0.5],center=true);
            translate([-999,-outer_r-d,actuator_h+1]) cube([999*2,d,outer_r+4+zflex_t-actuator_h-1]);
        }
        translate([-999,-ns_outer_r-1,actuator_h]) cube([999*2,3,2]); //truncate the yoke so it has a flat bit to mesh neatly with the actuator

        //elastic bands
        reflect([1,0,0]) reflect([0,1,0]) translate([outer_r-1,0,top_h]){
            cube([2,999,4],center=true);
            translate([0,5,0]) rotate([5,-5,0]) cube([2,4,15],center=true);
        }
        
        //hole to remove it from print bed with a screwdriver
        translate([0,outer_r,3/2+0.5]) cube([4,3,3],center=true);
    }
}
module back_foot(h=15,tilt=7){

	assign(inner=[0.8,1.1,1]*6*2)
	assign(outer=[0.8,1.1,1]*8*2)
	intersection(){
		translate([-1,-1,0]*999) cube([1,1,1]*999*2); //make sure there's nothing below the XY plane

		translate([0,outer[1]/2,0]) rotate([-tilt,0,0]) translate([0,-outer[1]/2,0]) union(){ //tip over from one corner to make foot
			difference(){
				union(){
					translate([0,0,-10]) resize([outer[0],outer[1],h+10]) cylinder(r=outer[1]); //body (with some below zero to allow spare when we tilt over
					translate([0,0,-10]) resize([inner[0],inner[1],h+5+10]) cylinder(r=inner[1]); //extension at the top
				}
				sequential_hull(){
					translate([0,0,-20]) resize([inner[0]-d,inner[1],d]) cylinder(r=inner[1]); //cutout for nut seat
					translate([0,0,h-4]) resize([inner[0]-d,inner[1],d]) cylinder(r=inner[1]); //cutout for nut seat
					translate([0,0,h-1]) resize([inner[0]-3,inner[1]-2,d]) cylinder(r=inner[1]-1);
					translate([0,0,h-1]) resize([inner[0]-3,inner[1]-2,999]) cylinder(r=inner[1]-1);
				}
				//cable hole
				translate([-1.5,0,h/2]) cube([3,999,999]);
			}
			intersection(){ //grips for hole in microscope
				difference(){ //hollow extruded ellipse
					translate([0,0,-10]) resize([inner[0],inner[1],h+5+10]) cylinder(r=inner[1]);
					translate([0,0,-20]) resize([inner[0]-3,inner[1]-1,999]) cylinder(r=inner[1]-1);
				}
				hull(){ //just the bits at either side
					translate([0,0,-10]) cube([999,10,d],center=true);
					translate([0,0,h+5]) cube([999,6,d],center=true);
				}
			}
			//grips for indents
			reflect([1,0,0]) translate([inner[0]/2,0,h+3]) scale([0.5,1,1]) sphere(r=1);
		}
	}
}


//intersection(){
  screw_seat(motor_lugs=true);
//    translate([0,0,21]) cylinder(r=999,h=999,$fn=8);
//}
nut_seat_with_flex();
//motor_lugs(); // merged into screw_seat, because it crashes STL export otherwise!! I suspect it's due to the large number of almost-duplicated vertices messing up tesselation...
//screw_seat_silhouette();
//elastic_band_base(tilt=0);
//back_foot();