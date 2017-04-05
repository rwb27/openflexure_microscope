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
    w = handle_w;
    difference(){
        sequential_hull(){
            rotate([-swing_a,0,0]) translate([-w/2,0,0]) cube([w,sso[0]/2,gap]);
            translate([-w/2,ns[2],0]) cube([w,d,ns[2]]);
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

module xz_slice(){
    //slice out just the part of something that sits in the XZ plane
    intersection(){
        cube([9999,2*d,9999],center=true);
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
            hull(){
                xz_slice() translate([0,-handle_l,0]) tool_handle();
                translate([0,l-20,0]) xz_slice() translate([0,-handle_l,0]) tool_handle();
            }
            hull(){
                translate([0,l-20,0])xz_slice() translate([0,-handle_l,0]) tool_handle();
                translate([-3/2, l-12,0]) cube([3,12,h]);
                translate([-7/2, l-12,h-1]) cube([7,12,1]);
            }
        }
        // cut-out to clear the hook
        hull(){
            translate([0,l,1.5]) scale([1,1,0.66]) rotate([90,0,0]) cylinder(r=1.4,h=18,center=true);
            translate([0,l,2+3]) rotate([90,0,0]) cylinder(r=2.3,h=18,center=true);
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


band_tool();
translate([10,0,0]) nut_tool();
