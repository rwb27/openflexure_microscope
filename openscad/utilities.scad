/******************************************************************
*                                                                 *
* OpenFlexure Microscope: OpenSCAD Utility functions              *
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


//utilities

d=0.05;


module reflect(axis){ //reflects its children about the origin, but keeps the originals
	children();
	mirror(axis) children();
}
module repeat(delta,N,center=false){ //repeat something along a regular array
	translate( (center ?  -(N-1)/2 : 0) * delta)
				for(i=[0:1:(N-1)]) translate(i*delta) children();
}

module nut(d,h=-1,center=false,fudge=1.18,shaft=false){ //make a nut, for metric bolt of nominal diameter d
	//d: nominal bolt diameter (e.g. 3 for M3)
	//h: height of nut
	//center: works as for cylinder
	//fudge: multiply the diameter by this number (1.22 works when vertical)
	//shaft: include a long cylinder representing the bolt shaft, diameter=d*1.05
	assign(h=(h<0)?d*0.8:h) union(){
		cylinder(h=h,center=center,r=0.9*d*fudge,$fn=6); 
		if(shaft){
			reflect([0,0,1]) cylinder(r=d/2*1.05*(fudge+1)/2,h=99999999999,$fn=16); 
			//the reason I reflect rather than use center=true is that the latter 
			//fails in fast preview mode (I guess because of the lack of points 
			//inside the nut).  Also, less fudge is applied to the shaft, it can
			//always be fixed with a drill after all...
		}
	}
}
module nut_from_bottom(d,h=-1,fudge=1.2,shaft=true,chamfer_r=0.75,chamfer_h=0.75){ //make a nut, for metric bolt of nominal diameter d
	//d: nominal bolt diameter (e.g. 3 for M3)
	//h: height of nut
	//center: works as for cylinder
	//fudge: multiply the diameter by this number (1.22 works when vertical)
	//shaft: include a long cylinder representing the bolt shaft, diameter=d*1.05
	assign(h=(h<0)?d*0.8:h) union(){
		cylinder(h=h,r=0.9*d*fudge,$fn=6); 
		translate([0,0,-0.05]) cylinder(h=chamfer_h,r1=0.9*d*fudge+chamfer_r,r2=0.9*d*fudge,$fn=6); 
		mirror([0,0,1]) cylinder(h=9999,r=0.9*d*fudge+chamfer_r,$fn=6); 
		if(shaft) assign(sr=d/2*1.05*(fudge+1)/2){
			translate([0,0,h/2]) reflect([0,0,1]) cylinder(r=sr,h=99999999999,$fn=16); 
			//the reason I reflect rather than use center=true is that the latter 
			//fails in fast preview mode (I guess because of the lack of points 
			//inside the nut).  Also, less fudge is applied to the shaft, it can
			//always be fixed with a drill after all...
			intersection(){ //we add a little cut to the roof of the surface so the initial bridges don't have to span the hole.
				union(){
					translate([0,0,h]) cube([9999,sr*2,0.5],center=true);
					translate([0,0,h+0.25]) cube([sr*2,sr*2,0.5],center=true);
				}
				cylinder(h=h+1,r=0.9*d*fudge,$fn=6); 
			}
		}
	}
}
//nut_from_bottom(4,chamfer_h=4,h=7);

module nut_y(d,h=-1,center=false,fudge=1.15,extra_height=0.7,shaft=false,top_access=false){ //make a nut, for metric bolt of nominal diameter d
	//d: nominal bolt diameter (e.g. 3 for M3)
	//h: height of nut
	//center: works as for cylinder
	//fudge: multiply the diameter by this number (1.22 works when vertical)
	//shaft: include a long cylinder representing the bolt shaft, diameter=d*1.05
    //top_access: extend the nut upwards to allow it to drop in.
	h=(h<0)?d*0.8:h;
    r=0.9*d*fudge;
    union(){
		rotate([-90,top_access?30:0,0]) cylinder(h=h,center=center,r=r,$fn=6);
		translate([-r*sin(30),center?-h/2:0,0]) cube([2*r*sin(30),h,r*cos(30)+extra_height]);
		if(shaft){
			translate([0,h/2,0]) reflect([0,1,0]) cylinder_with_45deg_top(h=999999,r=d/2*1.05*fudge,$fn=16,extra_height=extra_height); 
			//the reason I reflect rather than use center=true is that the latter 
			//fails in fast preview mode (I guess because of the lack of points 
			//inside the nut).
		}
        if(top_access){ //hole from the top
            translate([-r*cos(30),center?-h/2:0,0]) cube([2*r*cos(30),h,9999]);
        }
	}
}
module screw_y(d,h=-1,center=false,fudge=1.05,extra_height=0.7,shaft=false,shaft_length=999999){ //make a nut, for metric bolt of nominal diameter d
	//d: nominal bolt diameter (e.g. 3 for M3)
	//h: height of nut
	//center: works as for cylinder
	//fudge: multiply the diameter by this number (1.22 works when vertical)
	//shaft: include a long cylinder representing the bolt shaft, diameter=d*1.05
	assign(h=(h<0)?d*0.8:h, r=0.9*d*fudge) union(){
		cylinder_with_45deg_top(h=h,r=d*1.05*fudge,$fn=16,extra_height=extra_height); 
		if(shaft){
			translate([0,center ? 0 : h/2,0]) reflect([0,1,0]) cylinder_with_45deg_top(h=shaft_length+h/2,r=d/2*1.05*fudge,$fn=16,extra_height=extra_height); 
			//the reason I reflect rather than use center=true is that the latter 
			//fails in fast preview mode (I guess because of the lack of points 
			//inside the nut).
		}
	}
}
//screw_y(4,shaft=true, shaft_length=10);
module pinch_y(d, screw_l=999, counterbore_l=999, nut_l=-1, gap=[], t=2,extra_height=0.7,top_access=false){
    //gap with a nut/bolt to squeeze it
    nut_l = nut_l<0 ? d : nut_l; //default nut height
    gap = len(gap)==3 ? gap : [4*d, d, 4*d];
    union(){
        translate([0,gap[1]/2+t]) screw_y(d,h=counterbore_l,shaft=true,shaft_length=2*screw_l,extra_height=extra_height);
        cube(gap,center=true);
        translate([0,-gap[1]/2-t]) mirror([0,1,0]) nut_y(d, h=nut_l,center=false,shaft=false,top_access=top_access);
    }
}
//pinch_y(4,screw_l=10,t=4,top_access=true);

module chamfered_hole(r=10, h=10, chamfer=1,center=false){
    translate([0,0, center ? -h/2 : 0]) union(){
        translate([0,0,-d]) cylinder(r1=r+chamfer+d,r2=r,h=chamfer+d);
        cylinder(r=r,h=h);
        translate([0,0,h-chamfer]) cylinder(r1=r,r2=r+chamfer+d,h=chamfer+d);
    }
}
//chamfered_hole(15,30,center=true);

module unrotate(rotation){
	//undo a previous rotation, NB this is NOT the same as rotate(-rotation) due to ordering.
	rotate([0,0,-rotation[2]]) rotate([0,-rotation[1],0]) rotate([-rotation[0],0,0]) children();
}

module support(size, height, baseheight=0, rotation=[0,0,0], supportangle=45, outline=false){
	//generate "support material" in the STL file for selective supporting of things
	module support_2d() assign(sw=1.0, sp=3){
		union(){
			if(outline){
				difference()	{
					minkowski(){
						children();
						circle(r=sw,$fn=8);
					}
					children();
				}
			}
			intersection(){
				children();
				rotate(supportangle) for(x=[-size:sp:size])
					translate([x,0]) square([sw,2*size],center=true);
			}
		}
	}
	
	unrotate(rotation){
		translate([0,0,baseheight]) linear_extrude(height) support_2d() projection() rotate(rotation) children();
	}
	children();
}

module rightangle_prism(size,center=false){
	intersection(){
		cube(size,center=center);
		rotate([0,45,0]) translate([9999/2,0,0]) cube([1,1,1]*9999,center=true);
	}
}

module sequential_hull(){
	//given a sequence of >2 children, take the convex hull between each pair - a helpful, general extrusion technique.
	for(i=[0:$children-2]){
		hull(){
			children(i);
			children(i+1);
		}
	}
}

module union_preserving_holes(){
	//given a number of children, return the union of them, but preserve holes in each part
	difference(){
		union(){  //the union of all the parts
			children();
		}
		union(){ //the union of all the holes
			for(i=[0:$children-1]){
				difference(){
					hull() children(i);
					children(i);
				}
			}
		}
	}
}

module cylinder_with_45deg_top(h,r,center=false,extra_height=0.7,$fn=$fn){
	union(){
		rotate([90,0,180]) hull(){
			cylinder(h=h,r=r,$fn=$fn,center=center);
			translate([0,r-0.001,center?0:h/2]) cube([2*sin(45/2)*r,0.002,h],center=true);
		}
		rotate([90,0,180]) translate([0,r-0.001,(center?0:h/2)]) cube([2*sin(45/2)*r,0.002+2*extra_height,h],center=true);
	}
}
module cylinder_with_45deg_top_old(h,r,center=false,extra_height=0.7,$fn=$fn){
	union(){
		rotate([90,0,0]) hull(){
			cylinder(h=h,r=r,$fn=$fn,center=center);
			translate([0,r-0.001,center?0:h/2]) cube([2*(sqrt(2)-1)*r,0.002,h],center=true);
		}
		rotate([90,0,0]) translate([0,r-0.001,(center?0:h/2)]) cube([2*(sqrt(2)-1)*r,0.002+2*extra_height,h],center=true);
	}
}

module feather_vertical_edges(flat_h=0.2,fin_r=0.5,fin_h=0.72,object_h=20){
	union(){
	//	children();
		minkowski(){
			intersection(){
				children();
				union() for(i=[-floor(object_h/fin_h):floor(object_h/fin_h)]) translate([0,0,i*fin_h+flat_h*1.5]) cube([9999,9999,flat_h],center=true);
			}
			cylinder(r1=0,r2=fin_r,h=fin_h-2*flat_h,$fn=8);
		}
	}
}

module square_to_circle(r, h, layers=4, top_cylinder=0){
    sides=[4,8,16,32]; //number of sides
    for(i=[0:(layers-1)]) rotate(180/sides[i]) 
        translate([0,0,i*h/layers]) cylinder(r=r/cos(180/sides[i]),h=h/layers+d,$fn=sides[i]);
    if(top_cylinder>0) cylinder(r=r,h=h+top_cylinder, $fn=sides[layers-1]);
}

module hole_from_bottom(r, h, base_w=-1, dz=0.5, big_bottom=true){
    base = base_w>0 ? [base_w,2*r,dz] : [2*r,2*r,dz];
    union(){
        translate([0,0,dz/2]) cube(base,center=true);
        translate([0,0,dz]) square_to_circle(r, dz*4, 4, h-dz*5);
        if(big_bottom) mirror([0,0,1]) cylinder(r=999,h=999,$fn=8);
    }
}

//feather_vertical_edges(fin_r=1){
//	cylinder(r=12,h=10);
//}

//cylinder_with_45deg_top(20,10,center=false,$fn=32,extra_height=0.5);

//$fn=12;
//sequential_hull(){
//	translate([0,0,0]) sphere(r=.2);
//	translate([0,1,0]) sphere(r=.2);
//	translate([0,1,1]) sphere(r=.2);
//	translate([1,1,1]) sphere(r=.2);
//}

//nut(3,shaft=true);

//rightangle_prism([1,1,1],center=true);

//support(50,20,baseheight=-20,rotation=[90,0,0]) sphere(r=8,$fn=16);
