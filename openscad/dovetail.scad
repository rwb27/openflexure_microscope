/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination arm                        *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file deals with the dovetail clips that are used to hold   *
* the objective and illumination, and provide coarse Z adjustment.*
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <utilities.scad>;
$fn=16;
d=0.05;

module dovetail_clip_cutout(size,dt=1.5,t=2,slope_front=0,solid_bottom=0){
    // This will form a female dovetail when subtracted from a block.
    // cut this out of a cube (of size "size", with one edge centred along
    // the X axis extending into +y, +z
    //
    // dt sets the size of the 45-degree clips
    // t sets the thickness of the dovetail arms (2mm is good)
    // slope_front cuts off the bottom of the ends of the arms, i.e.
    //   the part that does the gripping starts above Z=0.  This can
    //   avoid the splodginess that comes from the bottom few layers,
    //   and make it print much better - useful if you want to insert
    //   things from the bottom.
    // solid_bottom joins the bottoms of the arms with a thin layer.
    //   this can help it stick to the print bed.
    //
    // I reccommend using ~8-10mm arms for a tight fit.  On all my
    // printers, the ooze of the plastic is enough to keep it tight, so I
    // set the size of the M and F dovetails to be identical.  You might
    // want to make it tighter, either by increasing dt slightly or by
    // decreasing the size slightly (in both cases, of this, the female
    // dovetail).
    // NB that it starts at z=-d and stops at z=size[2]+d to make
    // it easy to subtract from a block.
    
    cutout_bottom = solid_bottom > 0 ? solid_bottom+d : -d;
    inner_w = size[0] - 2*t; // width between arms
    
    hull() reflect([1,0,0]) translate([-size[0]/2+t,0,cutout_bottom]){
        translate([dt,size[1]-dt,0]) cylinder(r=dt,h=size[2]+2*d,$fn=16);
        translate([0,dt,0]) rotate(-45) cube([dt*2,d,size[2]+2*d]);
    }
    
    if(slope_front>0){
        //sloped bottom to improve quality of the dovetail clip and
        //allow insertion of the male dovetail from the bottom
        rotate([45,0,0]) cube([999,1,1]*sqrt(2)*slope_front,center=true); //slope up arms
        //also, slope in the dovetail tooth to avoid marring at the bottom:
        hull() reflect([0,0,1]) translate([0,0,slope_front]) 
            rotate([0,45,0]) cube([(inner_w)/sqrt(2),dt*2,inner_w/sqrt(2)],center=true);
    }
}
module dovetail_clip(size=[10,2,10],dt=1.5,t=2,back_t=0,slope_front=0,solid_bottom=0){
    // This forms a clip that will grip a dovetail, with the
    // contact between the m/f parts in the y=0 plane.
    // This is the female part, and it is centred in X and 
    // extends into +y, +z.
    // The outer dimensions of the clip are given by size.
    // dt sets the size of the clip's teeth, and t is the
    // thickness of the arms.  By default it has no back, and
    // should be attached to a solid surface.  Specifying back_t>0
    // will add material at the back (by shortening the arms).
    // slope_front will add a sloped section to the front of the arms.
    // this can improve the quality of the bottom of the dovetail 
    // (good if you're inserting from the bottom)
    // solid_bottom will join the arms together at the bottom, which
    // can help with bed adhesion.
    // see dovetail_clip_cutout - most of the options are just passed through.
	difference(){
		translate([-size[0]/2,0,0]) cube(size);
		dovetail_clip_cutout(size-[0,back_t+d,0],dt=dt,t=t,h=999,slope_front=slope_front,solid_bottom=solid_bottom);
	}
}

module dovetail_plug(corner_x, r, dt, zx_profile=[[0,0],[10,0],[12,-1]]){
    // Just the "plug" of a male dovetail (i.e. not the flat surface
    // it's attached to, just the bit that fits inside the female).
    // zx_profile is a list of 2-element vectors, each of which defines
    //   a point in Z-X space, i.e. first element is height and second
    //   is the shift in the corner position.  For example,
    //   zx_profile=[[0,0],[10,0],[12,-1]] creates a plug 12mm+d high 
    //   where the top 2mm are sloped at 60 degrees.  NB the use of d.
    union(){
        // sorry for the copy-paste code; I'm fairly sure it's less readable
        // if I arrange things in a way that avoids it...
        // four fat cylinders make the contact point
        for(i=[0:len(zx_profile)-2]){
            hull() for(j=[0:1]){
                z = zx_profile[i+j][0];
                x = zx_profile[i+j][1];
                reflect([1,0,0]) translate([corner_x+x,0,z]) rotate(45) translate([sqrt(3)*r,r,0]) repeat([dt*sqrt(2) - (1+sqrt(3))*r,0,0],2) cylinder(r=r,h=d);
            }
        }
        // another four cylinders join the plug to the y=0 plane
        for(i=[0:len(zx_profile)-2]){
            hull() for(j=[0:1]){
                z = zx_profile[i+j][0];
                x = zx_profile[i+j][1];
                reflect([1,0,0]) translate([corner_x+x,0,z]) rotate(45) repeat([sqrt(3)*r,r,0],2) cylinder(r=d,h=d);
            }
        }
    }
}
module dovetail_m(size=[10,2,10],dt=1.5,t=2,top_taper=1,bottom_taper=0.5,waist=0,waist_dx=0.5,r=0.5){
    // Male dovetail, contact plane is y=0, dovetail is in y>0
    // size is a box that is centred in X, sits on Z=0, and extends
    // in the -y direction from y=0.  This is the mount for the
    // dovetail, which sits in the +y direction.
    // The width of the box should be the same as the width of the
    // female dovetail clip.  The size of the dovetail is set by dt.
    // t sets the thickness of the female dovetail arms; the dovetail
    // is actually size[0]-2*t wide.
    r=r; //radius of curvature - something around nozzle width is good.
    w=size[0]-2*t; //width of dovetail
    h=size[2]; //height
    corner=[w/2-dt,0,0]; //location of the pointy bit of the dovetail
    difference(){
		union(){
            //back of the dovetail (the mount) plus the start of the
            //dovetail's neck (as far as y=0)
			sequential_hull(){
                // start with the cube that the dovetail attaches to
				translate([-w/2-t,-size[1],0]) cube([w+2*t,size[1]-r,h]);
                // then add shapes that take in the centres of the cylinders
                // from the next step.  This joins together the nicely-rounded
                // contact points, such that when we subtract out the cylinders
                // at the corners we get a nice smooth shape.
                reflect([1,0,0]) translate(corner+[sqrt(3)*r,-r,0]) cylinder(r=d,h=h);
                reflect([1,0,0]) translate(corner) cylinder(r=d,h=h);
			}
            //contact points (with rounded edges to avoid burrs)
			difference(){
				union(){
					reflect([1,0,0]) hull(){
						translate(corner+[sqrt(3)*r,-r,0]) cylinder(r=r,h=h);	
						translate([w/2+t-r,-r,0]) cylinder(r=r,h=h);	
                    }
					//hull() reflect([1,0,0]) translate(corner) rotate(45) translate([sqrt(3)*r,r,0]) repeat([1,0,0],2) cylinder(r=r,h=h);
                    // the "plug" is tapered for easy insertion, and may
                    // have optional indents in the middle (a "waist").
                    waist_dx = waist>waist_dx*4 ? waist_dx : 0;
                    waist_dz = waist>waist_dx*4 ? waist_dx*2 : d;
                    zx_profile = [[0,-bottom_taper],
                                  [bottom_taper,0],
                                  [h/2-waist/2,0],
                                  [h/2-waist/2+waist_dz,-waist_dx],
                                  [h/2+waist/2-waist_dz,-waist_dx],
                                  [h/2+waist/2,0],
                                  [h-top_taper,0],
                                  [h-d,-top_taper/2]];
                    dovetail_plug(corner[0], r, dt, zx_profile);
                        
				}
			}
		}
        // We round out the internal corner so that we grip with the edges
        // of the tooth and not the point (you get better contact this way).
		reflect([1,0,0]) translate(corner) cylinder(r=r,h=3*h,center=true);
	}
}

module dovetail_clip_y(size, dt=1.5, t=2, taper=0, endstop=false){
    // Make a dovetail where the sliding axis is along y, i.e. horizontal
    // This means it's the top of the object that grips the dovetail.
    //
    // the x and y elements of size set the dovetail width and "height"
    // the z element sets the distance from the end of the teeth (z=0) to
    // the bottom of the mount.
    // dt is the size of the dovetail teeth
    // endstop enables a link on the other side of the Y axis, to stop motion there.
    // endstop_w, endstop_t set the width and thickness (in y and z) of the link
    // taper optionally feathers the dovetail onto an edge
    // the dovetail extends along the +y direction from y=0
    h = size[1];
    ew = 0;//endstop ? endstop_w : 0;
    reflect([1,0,0]) translate([-size[0]/2,0,0]) mirror([0,0,1]) sequential_hull(){
        translate([0,dt,0]) cube([t+dt,h-2*dt,d]);
        cube([t,h,dt]);
        translate([0,-ew,0]) cube([t,h+ew,dt]);
        translate([0,-taper,size[2]-d]) cube([t,h+2*taper,d]);
    }
    if(endstop){
        difference(){
            hull(){ // make a bridge between the lower tapers
                translate([0,-taper/2,-size[2]+d]) cube([size[0],taper,2*d],center=true);
                translate([0,0,-d]) cube([size[0],d,2*d],center=true);
            }
            translate([0,0,-size[2]+0.5+999/2]) cube([(size[0]-2*t-2*dt)-2,999,999],center=true); //cut the middle
            translate([0,-taper/2,-size[2]]) cube([size[0],taper-1.5,0.5*2+d],center=true);
        }
    }
}
//dovetail_clip_y([12,12,3],taper=2,endstop=true);
///
test_size = [14,10,24];
test_dt = 2;
//color("blue") dovetail_clip(test_size,dt=test_dt,slope_front=3,solid_bottom=0.5);
color("green") translate([0,0,-2]) dovetail_m(test_size, waist=10, dt=test_dt,waist_dx=0.2);
//*/