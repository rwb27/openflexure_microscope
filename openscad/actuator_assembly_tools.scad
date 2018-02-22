/*

Tools for assembling the OpenFlexure Microscope v5.16

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <utilities.scad>;
use <compact_nut_seat.scad>;
include <microscope_parameters.scad>;

ns = nut_slot_size();
shaft_d = nut_size()*1.1;
gap = 9; //size of the gap between gear and screw seat
swing_a = 30; //angle through which the tool swings
sso = ss_outer(25); //outer size of screw seat
handle_w = shaft_d+4; //width of the "handle" part
handle_l = sso[0]/2+gap; //length of handle part


module tool_handle(){
    w = handle_w; //width of the handle
    a = swing_a; //angle through which the tool is moved to tighten the nut
    difference(){
        sequential_hull(){
            rotate([-a,0,0]) hull(){
                rc=1.5;
                reflect([1,0,0]) translate([w/2 - rc, rc, rc * tan(45 + a/2)]) sphere(r=rc);
                reflect([1,0,0]) translate([w/2 - rc, rc, gap - rc]) sphere(r=rc);
            }
            translate([-w/2,(gap*cos(a)-ns[2])/tan(a) + gap*sin(a),0]) cube([w,d,ns[2]]);
            //translate([-w/2,ns[2],0]) cube([w,d,ns[2]]);
            translate([-w/2,sso[0]/2*cos(swing_a)+gap*sin(swing_a),0]) cube([w,d,ns[2]]);
            translate([-ns[0]/2,handle_l,0]) cube([ns[0],d,ns[2]]);
        }
        //ground (or bottom of gear)
        mirror([0,0,1]) cylinder(r=999,h=999,$fn=4);
        //screw seat (in swung-in position)
        rotate([0,180-swing_a,-90]) translate([0,0,-(gap+sso[2]/2)]) screw_seat_shell(25);
        //screw
        //rotate([-swing_a,0,0]) cylinder(d=shaft_d,h=999,center=true, $fn=16);
    }
}

module xz_slice(y=0){
    //slice out just the part of something that sits in the XZ plane
    intersection(){
        translate([0,y,0]) cube([9999,2*d,9999],center=true);
        children();
    }
}

module nut_tool(){
    w = ns[0]-0.6; //width of tool tip (needs to fit through the slot that's ns[0] wide
    h = ns[2]-0.7; //height of tool tip (needs to fit through slot)
    l = 5+sso[1]/2+3;
    difference(){
        union(){
            translate([0,-handle_l,0]) tool_handle();
            sequential_hull(){
                xz_slice() translate([0,-handle_l,0]) tool_handle();
                translate([-w/2, 5, 0]) cube([w, d, h]);
                translate([-w/2, l, 0]) cube([w, d, h]);
            }
        }
        
        //nut 
        translate([0,l,-d])rotate(30)cylinder(r=nut_size()*1.15, h=999, $fn=6);
        translate([0,l-nut_size()*1.15+0.4,-d]) cylinder(r=1,h=999,$fn=12);
    }
}

   
module band_tool(){
    w = ns[0]-0.5; //width of tool tip
    h = 4.5; //height of tool tip (needs to fit through slot)
    l = sso[2]/2+foot_height+5;
    // presently, the hook on the actuator is a 1mm radius cylinder, centred
    // 3.5mm from the edge of the (elliptical) wall of the screw seat.
    difference(){
        union(){
            translate([0,-handle_l,0]) tool_handle();
            sequential_hull(){
                xz_slice() translate([0,-handle_l,0]) tool_handle();
                translate([0,l-20,0]) xz_slice() translate([0,-handle_l,0]) tool_handle();
                union(){
                    translate([-3/2, l-12,0]) cube([3,12,h]);
                    translate([-7/2, l-12,h-1]) cube([7,12,1]);
                }
            }
        }
        // cut-out to clear the hook
        hull(){
            translate([0,l,1.5]) scale([1,1,0.66]) rotate([90,0,0]) cylinder(r=1.4,h=18,center=true);
            translate([0,l,2+3]) rotate([90,0,0]) cylinder(r=2.3,h=40,center=true);
        }
        // V shaped end to grip elastic bands
        translate([0,l,0]) hull(){
            translate([0,0.3,1.5]) rotate([0,90,0]) cylinder(r=1,h=999,center=true);
            translate([0,-0.5,h-1.5]) rotate([0,90,0]) cylinder(r=1,h=999,center=true);
        }
        translate([-99,l-0.5,h-1.5]) cube(999);
        // squeeze the sides slightly (commented out for strength)
        reflect([1,0,0]){
//            translate([-7/2,l,h/2-0.3]) rotate([90,15,-3]) scale([1.1,1.5,1]) cylinder(r=1,h=999,center=true);
        }
    }
}

band_tool_l = sso[2]/2+foot_height;
band_tool_w = ns[0]-0.5;
band_tool_h = 4;

module prong_frame(){
    //Move the prongs out and tilt them slightly
    smatrix(xz=0.3, xt=1.9, yt=band_tool_l) children();
}

blade_anchor = [0,-12,0]; //position of the bottom of the slot

module blade_point(pos, d1=1.5, d2=1.5, h=d){
    union(){
        translate(blade_anchor + [0,0,pos[2]]) cylinder(d=d1, h=h);
        translate(pos) cylinder(d=d2, h=h);
    }
}

module band_tool_2(handle=true){
    //forked tool to insert the elastic band
    h = band_tool_h; //overall height of the band insertion tool
    union(){
        // the two "blades" that support the band either side of the hook
        reflect([1,0,0]) prong_frame() sequential_hull(){
            blade_point([0,1.5,0], h=0.5);
            blade_point([0,0,h-1]);
            blade_point([0.3,0.5,h-d],d2=2.1);
        }
        // the flat bottom that passes between the hook and the outside of the column
        hull() reflect([1,0,0]) prong_frame(){ //bottom of the tip
            translate([0,1.5,0]) cylinder(d=1.5,h=0.5);
            translate(blade_anchor) cylinder(d=1.5,h=0.5);
        }
        // connect the business end of the tool to the handle
        difference(){
            hull(){ //join the blades and the handle
                reflect([1,0,0]) prong_frame() translate(blade_anchor) repeat([0,10,0], 2) cylinder(d=1.5,h=h);
                xz_slice() translate([0,-handle_l,0]) tool_handle();
            }
            //cut out to get nice rounded corners at the bottom of the slot for the hook
            hull() reflect([1,0,0]) prong_frame(){
                translate(blade_anchor + [-2.25,3,h]) sphere(r=1.5,h=99);
                translate(blade_anchor + [-1.5,10,0.5]) cube([1.5/2,999,999]);
            }
        }
        //the handle
        if(handle){
            translate([0,-handle_l,0]) tool_handle();
        }
    }
}

module double_ended_band_tool(bent=false){
    roc=2;
    middle_w = 2*column_base_radius()+1.5+2*(band_tool_h-roc)+0.5; //width of the band anchor on the foot
    
    flex_l = roc*3.14/2; //length of the flexible linkers
    
    // We make two tools, spaced out by a flexible joiner
    reflect([0,1,0]) translate([0,middle_w/2+flex_l,0]) if(bent){
        translate([0,roc-3,roc]) rotate([90,0,0]) band_tool_2(handle=false);
    }else{
        band_tool_2(handle=false);
    }
    //flexible links between the two tools and the middle part
    if(bent){
        reflect([0,1,0]) translate([0,middle_w/2,roc]) difference(){
            rotate([0,90,0]) cylinder(r=roc,h=ns[0],center=true);
            rotate([0,90,0]) cylinder(r=roc-0.5,h=99,center=true);
            translate([-99,-99,0]) cube(999);
            translate([-99,-999,-99]) cube(999);
        }
        translate([0,0,0.5/2]) cube([ns[0],middle_w+2*d,0.5],center=true);
    }else{
        translate([0,0,0.5/2]) cube([ns[0],middle_w+2*flex_l+2*d,0.5],center=true);
    }
    //thicker middle part to support the two ends
    hull(){
        translate([0,0,0.5]) cube([ns[0],middle_w,d],center=true);
        translate([0,0,roc]) cube([ns[0],middle_w+2*(roc-0.5),d],center=true);
    }
}

double_ended_band_tool(bent=false);
translate([10,0,0]) nut_tool();
