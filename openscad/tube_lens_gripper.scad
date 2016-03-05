/******************************************************************
*                                                                 *
* OpenFlexure Microscope: inline holder for a lens                *
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

$fn=32;
d=0.05;

tube_lens_r=5+0.1;
tube_lens_edge_h=2;
tube_lens_centre_h=4;
gripper_t=1;

body_r=8;
inner_r=body_r-1;
cutout_h=tube_lens_centre_h+1;
roof_r = inner_r-cutout_h+tube_lens_edge_h;
floor_t = 1;

pedestal_h=0.5;
        
module lens_holder(){
    t=0.7; //thickness of wall
    union(){
        //pedestal for lens
        difference(){
            translate([0,0,-d]) cylinder(r=tube_lens_r,h=d+pedestal_h);
            //beam clearance
            cylinder(r=tube_lens_r-t,h=999,center=true); 
        }
        
        //gripper
        m=1.7; //gradient of wall
        tightness=0.5; //how much the lens is squeezed in position
        transient_tightness=0.6; //how much more the lens is squeezed on the way in
        bottom_r=tube_lens_r + (tube_lens_edge_h+pedestal_h)/m -tightness;
        //distance of the bottom of the wall from the centre
        gripper_h=tube_lens_edge_h+pedestal_h+m*0.5; //height of the gripper "wall" (0.5mm above the lens edge)
        dr=gripper_h/m; //distance of top of wall from cavity edge
        reflect([1,0,0]){
            f_bottom_r = inner_r - bottom_r + transient_tightness;
            translate([-inner_r,-body_r+f_bottom_r+dr,-d]) difference(){
                intersection(){
                    cylinder(r1=f_bottom_r,r2=f_bottom_r+dr, h=gripper_h);
                    rotate(-90) cube(999);
                }
                translate([0,0,-d]) cylinder(r1=f_bottom_r-t,
                         r2=f_bottom_r+dr-t, h=gripper_h+2*d);
            }
            intersection(){
                //side wall grippers, incl. rounded bit
                translate([0,0,-d]) cylinder(r=body_r,h=body_r);
                difference(){
                    union(){
                        //straight part of the grippers
                        translate([0,f_bottom_r+dr,-d]) hull(){
                            cube([(bottom_r-transient_tightness)*2+2*t,2*body_r,2*d],center=true);
                            cube([(bottom_r-transient_tightness-dr)*2+2*t,2*body_r,2*gripper_h],center=true);
                        }
                        //curved part of the grippers
                        translate([0,0,-d]) cylinder(r1=bottom_r+t, r2=bottom_r+t+-dr, h=gripper_h);
                    }
                    union(){
                        translate([0,f_bottom_r+dr,-d]) hull(){
                            cube([(bottom_r-transient_tightness)*2,999,2*d],center=true);
                            cube([(bottom_r-transient_tightness-dr)*2,999,2*gripper_h+d],center=true);
                        }
                        translate([0,0,-d]) cylinder(r1=bottom_r, r2=bottom_r+-dr, h=gripper_h+d);
                    }
                }
            }
//            intersection(){
//                cylinder(r=inner_r+d,h=999);
//                hull(){
//                    translate([-7+top_r-0.5,-tube_lens_r+1-d,1.25+tube_lens_edge_h+1-d]) cube([0.5,999,d]);
//                    translate([-7+top_r-0.5-tube_lens_edge_h/2,-tube_lens_r+1-d,1.25-d]) cube([0.5,999,d]);
//                }
//            }
        }
    }
}
module lens() {
    intersection(){
        dh=tube_lens_centre_h-tube_lens_edge_h;
        rs=(pow(dh,2) + pow(tube_lens_r,2))/(2*dh);
        cylinder(r=tube_lens_r,h=999);
        translate([0,0,tube_lens_centre_h-rs]) sphere(r=rs);
    }
}

//gripper();
lens_holder();

%translate([0,0,0.5]) lens();
