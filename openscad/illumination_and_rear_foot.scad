/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination arm                        *
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

use <utilities.scad>;
use <dovetail.scad>;
include <microscope_parameters.scad>;
use <optics.scad>;

// geometry is now defined by microscope_parameters.scad

clip_w = 12; //external width of clip for dovetail
clip_h = 12; //height of dovetail clip
bottom = -foot_height; //the foot extends below the bottom of the dovetail
  //currently this is also defined in nut_seat_with_flex.scad, should
  //move them both to microscope_parameters really!

led_d = 5; // LED diameter in mm if you want a bigger LED
led_angle = 22; //cone angle for LED beam
working_distance = clip_h + 0; //wd should be >= clip_h so it fits on nicely...
                //working_distance is the distance from condenser to stage
condenser=false;

stage_clearance=6;
shift=[0,0,0];
w = clip_w; //width (size in x direction)
b = 8; //breadth (size of main pillar in y direction)
back = illumination_clip_y-b-stage_clearance; //y coordinate of back of pillar
wd = working_distance; //distance from bottom of "condenser" to sample
arm_h = b; //height of the horizontal arm (cross-sectional size in z)
arm_w = b; //width of the arm (cross-sectional size in x)
t = 1; //thickness of shell
clip_t = 2; //thickness of arms for the dovetail clip
hole_h = max(stage_clearance, b); //height of cut-out above clip
dt_taper = 2; //size of sloping part at top/bottom of dovetail
condenser_clip_w = objective_clip_w+4;

module back_foot_and_arm(clip_y=illumination_clip_y,stage_clearance=6,sample_z=sample_z){
    // Arm that clips on to the microscope, providing the back foot
    // and illumination mount
    w = clip_w; //width (size in x direction)
    difference(){
        $fn=32;
        union(){
            sequential_hull(){
                translate([0,back,bottom+clip_t]) rotate([-90,0,0])cylinder(r=clip_t,h=2); //foot
                union(){ //platform for mounting screw
                    translate([-w/2,back,-dt_taper]) cube([w,d,dt_taper]);
                    translate([0,illumination_clip_y+3,-dt_taper]) cylinder(d=w, h=dt_taper);
                }
                translate([-w/2,back,-dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+dt_taper]) cube([w,b+stage_clearance-2,d]); //dovetail mounts here
                translate([-w/2,back,clip_h+hole_h]) cube([w,b,d]); //start of main shaft
                translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w,b*sqrt(2),d],center=true);//top of main shaft
                translate([0,back+b,sample_z+wd+b]) resize([arm_w,b*2,3]) cylinder(r=b,h=1);
            }
            translate([0,illumination_clip_y,0]) rotate([-90,180,0]) dovetail_clip_y([clip_w,clip_h,2+d],t=clip_t,taper=dt_taper,endstop=true);
        }
        
        // make the structure hollow, for faster printing and 
        // cable management
        hw = w - 2*clip_t; // width of hole near dovetail clip
        sequential_hull(){
            //translate([0,back,bottom+clip_t
            translate([-hw/2,back+t,-dt_taper]) cube([hw,b+stage_clearance-2-t+d,d]); //dovetail mounts here
            translate([-hw/2,back+t,clip_h+dt_taper]) cube([hw,b+stage_clearance-2-t+d,d]); //dovetail mounts here
            translate([-hw/2,back+t,clip_h+hole_h]) cube([hw,b-t+d,d]);//top of hole
            translate([-hw/2,back+t,clip_h+hole_h]) cube([hw,b-2*t,d]);//start of bridge over the main shaft
            translate([-w/2+t,back+t,clip_h+hole_h+clip_t-t]) cube([w-2*t,b-2*t,d]);//main shaft starts here
            //translate([0,back+t,clip_h]) rotate([-90,0,0]) cylinder(d=w-2*t,h=b-2*t);
            translate([0,back+b/2,sample_z+wd+b/2]) rotate([45,0,0]) cube([arm_w-2*t,(b-2*t)*sqrt(2),2*d],center=true);//main shaft (top)
            translate([0,back+2*b,sample_z+wd-b/2]) cube([arm_w-2*t,d,3*b], center=true); //hole just underneath the mount for the horizontal arm
        }
        
        // mounting nut trap for horizontal arm
        translate([0,back+b,sample_z+wd+b]) rotate([-90,0,0]) nut_y(3, fudge=1.3, center=false, shaft_length=6, top_access=true);
        
        // exit holes for cable (option to leave from front or back)
        difference(){
            hull(){
                translate([0,back+t,-dt_taper]) cube([hw,999,2*d],center=true); //bottom of dovetail mount
                translate([0,back+t,bottom+clip_t]) rotate([-90,0,0]) cylinder(r=d,h=999,center=true); //foot
            }
            translate([0,0,bottom*2/3]) mirror([0,0,1]) cylinder(r=999,h=999,$fn=8);
        }
        // hole mounting screw (if dovetail is wobbly)
        translate(illumination_arm_screws[0]+[0,0,d]) mirror([0,0,1]){
            translate([0,0,dt_taper]) hull() repeat([0,99,0],2) cylinder(d=w-2,h=999); //flat part for the washer
            cylinder(d=3*1.25, h=999); //hole for the screw
            reflect([0,1,0]) hull(){ //cut the plate so the clip can flex
                cylinder(r=d,h=dt_taper+2*d);
                translate([-hw/2,hw/2,0]) cube([hw,3,dt_taper+2*d]);
            }
        }
        // entry hole for an M3 screw to mount it to a box
        translate([0,back+t+3/2,clip_h/2]) rotate([90,0,0]) cylinder(d=3.5,h=999, center=true);
    }
    // nut trap for mounting to box (see entry hole above)
    translate([0,back+t+3/2,clip_h/2]) difference(){
        union(){ //thicken the back to hold the nut trap
            cube([w,4,6],center=true);
            translate([0,-1,3]) cube([w,2,8],center=true);
        }
        //cut-out for the nut:
        hull() repeat([0,0,10],2) rotate([90,30,0]) cylinder(r=3*1.3,h=3,center=true, $fn=6);
        cube([2*3*1.3*cos(30),999,3.5],center=true); //screw clearance
    }
}

module illumination_horizontal_arm(){
    // Arm that joins the illumination/condenser to the vertical arm at the back
    translate([0,0,sample_z+wd]) difference(){
        $fn=32;
        w1 = arm_w+2*t+1; //width of the post end of the arm
        w2 = condenser ? condenser_clip_w : w1;
        union(){
            sequential_hull(){
                translate([0,back+b-2,b+3]) cylinder(d=w1,h=t);
                translate([-w1/2,back+b/2,3]) cube([w1,d,b+t]);
                translate([-w2/2,back+b*2,3]) cube([w2,d,b+t]);
                if(condenser){
                    translate([-condenser_clip_w/2,condenser_clip_y-8,4]+shift) cube([condenser_clip_w,d,8]);
                }else{
                    translate([-arm_w/2,-6-4,4]) cube([arm_w,d,arm_h]);
                }
                if(!condenser) cylinder(r=6,h=arm_h+4,$fn=32);
            }
            if(condenser){
                translate([0,condenser_clip_y,4+8]+shift) rotate(180) mirror([0,0,1]) dovetail_clip([objective_clip_w+4,8,8+d],t=clip_t,slope_front=0,solid_bottom=0.2); //rotate([-90,180,0]) dovetail_clip_y([objective_clip_w+4,8,8+d],t=clip_t,taper=0,endstop=false);
            }
        }
        
        // make the structure hollow, for faster printing and 
        // cable management
        hw = clip_w - 2*clip_t; // width of hole near dovetail clip
        iw1 = w1 - 2*t; //inner width near post
        iw2 = w2 - 2*2; //inner width near dovetail
        sequential_hull(){
            translate([-iw1/2,back,3]) cube([iw1,2*b,b]);
            translate([-iw2/2,back+2*b,3+t]) cube([iw2,d,b-t]);
            if(condenser){
                translate([-iw2/2,condenser_clip_y-2,3+t]) cube([iw2,d,b-t]);
            }else{
                translate([-3,-6-4,4+4]) cube([6,d,3]); //this hole is set to fit a 2-way header.  This is the end of the channel, at the opening where the LED sits.
            }
            if(!condenser){
                translate([-3,-6-4,4+4]) cube([6,6+4,999]); //through to LED and to top
            }
        }
        // mounting slot to screw onto vertical arm
        translate([0,back+b,b+3]) hull(){
            repeat([0,4,0], 2, center=true) cylinder(d=3*1.25, h=10,center=true);
        }
        
        // enlarge the channel a bit next to the LED to allow it to be put in LED-first
        sequential_hull(){
            translate([-arm_w/2-0.5,back+2*b,3+t]) cube([arm_w+1,d,b-t]);
            translate([0,-12,4+4])  rotate([90,0,0]) cylinder(r=2.5, h=d);
            translate([-3,-4,4+4]) cube([6,d,10]);
        }
        
        // Holes for LED and beam (only relevant if condenser=false)
        translate([0,0,-wd+10+8.5]){
            cylinder(r=led_d*1.1/2,h=999,center=true,$fn=24);
            cylinder(r=(led_d+1)*1.2/2,h=999,$fn=24);
        }
        translate([0,0,-wd]) cylinder(h=wd+4,r1=(wd+4)*tan(led_angle/2)+3/2,r2=3/2);
    }
}

module illumination_horizontal_arm_condenser(){
    // Arm that joins the illumination/condenser to the vertical arm at the back
    translate([0,0,sample_z+wd+b+3+t]) mirror([0,0,1]) difference(){
        $fn=32;
        w1 = arm_w+2*t+1; //width of the post end of the arm
        w2 = condenser_clip_w;
        cclip_y = condenser_clip_y;
        h = b+t;
        union(){
            sequential_hull(){
                translate([0,back+b-2,0]) cylinder(d=w1,h=t);
                translate([-w1/2,back+b-2,0]) cube([w1,d,h]);
                translate([-w1/2,back+b+2,0]) cube([w1,d,h]);
                translate([-w2/2,back+b*2,0]) cube([w2,d,h]);
                translate([-w2/2,cclip_y-8,0]) cube([w2,d,h]);
            }
            translate([0,cclip_y,0]) rotate(180) dovetail_clip([w2,8,h],t=clip_t,slope_front=0,solid_bottom=0.2);
        }
        
        // make the structure hollow, for faster printing and 
        // cable management
        iw1 = w1 - 2*t; //inner width near post
        iw2 = w2 - 2*clip_t; //inner width near dovetail
        ih = h-2*t; //inner height
        sequential_hull(){
            translate([-iw1/2,back,t]) cube([iw1,2*b,999]);
            translate([-iw1/2,back+b+2,t]) cube([iw1,d,ih]);
            translate([-iw2/2,back+2*b,t]) cube([iw2,d,ih]);
            translate([-iw2/2,cclip_y-2,t]) cube([iw2,d,ih]);
        }
        // mounting slot to screw onto vertical arm
        translate([0,back+b,0]) hull(){
            repeat([0,4,0], 2, center=true) cylinder(d=3*1.25, h=10,center=true);
        }
        // hole for cable management and to allow more flex of the clip
        hull() reflect([1,0,0]) translate([-iw2/2+2,0,0]){
            translate([0,cclip_y-4,0]) cube([4,d,999],center=true);
            translate([0,max(back+2*b+4+2, cclip_y-11),0]) cylinder(r=2,h=999,center=true); //make the clip arms 11+2=13mm long
        }
    }
}
module print_ready_parts(){
    // make a nice, compact assembly of all the parts, sitting on z=0
    translate([0,0,-back]) rotate([90,0,0]) back_foot_and_arm();
    if(condenser){
        translate([clip_w+3,back-3,0]) condenser();
        translate([clip_w+3,back,sample_z+wd+b+3+t]) rotate([180,0,0])  illumination_horizontal_arm_condenser();
    }else{
        translate([clip_w+3,back,sample_z+wd+b+3+t]) rotate([180,0,0])  illumination_horizontal_arm();
    }
}

module parts_in_situ(){
    // generate all the parts as they would appear in the microscope.
    back_foot_and_arm();
    if(condenser){
        illumination_horizontal_arm_condenser();
        translate([0,0,sample_z+wd+16]) rotate([0,180,0]) condenser();
    }else{
        illumination_horizontal_arm();
    }
}

/*
rotate([90,0,0]) difference(){
    // standard size
    echo("clip_y",illumination_clip_y,"sample_z",sample_z);
    //rotate([90,0,0]) 
    //back_foot_and_illumination(clip_y=illumination_clip_y, sample_z=sample_z, condenser=false, shift=[0,0,0], screws=false);
    //back_foot_and_illumination(clip_y=illumination_clip_y, sample_z=sample_z, condenser=true, shift=[0,-2,0], screws=true);
    union(){
        //back_foot_and_arm(clip_y=illumination_clip_y, sample_z=sample_z);
        illumination_horizontal_arm(condenser=use_condenser);
    }
    //adjustable_condenser_arm();
    // large stage version
    //rotate([90,0,0]) back_foot_and_illumination(clip_y=-36.5772, sample_z=65);
    //rotate([0,90,0]) cylinder(r=999,h=999,$fn=8);
}
//translate([0,0,sample_z+working_distance+20]) mirror([0,0,1]) condenser();
*/
print_ready_parts();
//parts_in_situ();