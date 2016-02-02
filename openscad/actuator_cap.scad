/*********************************************************
This design is for a relatively high-force push fit cap
for the actuator columns, with the aim of making springs 
(or elastic bands) easier to fit.
*********************************************************/
use <utilities.scad>;

d=0.05;
outer_r=8;
outer_flat=7;
outer_flat_r=outer_r+outer_flat/sqrt(3)/2; //distance of flats from Z axis
overlap=6;
cap_bottom_t=1;
cap_gap=0.75;

module trylinder(r=1, flat=1, h=d, center=false){
    //A fade between a cylinder and a triangle.
    hull() for(a=[0,120,240]) rotate(a)
        translate([0,flat/sqrt(3),0]) cylinder(r=r, h=h, center=center);
}

module actuator_column_base(h){
    //The bottom half of a push-fit-together "trylindrical" actuator
    //column
    difference(){
        union(){
            trylinder(r=outer_r,flat=outer_flat, h=h);
            hull(){
                r=outer_r-cap_bottom_t-cap_gap;
                trylinder(r=r,flat=outer_flat, h=h+overlap-0.5);
                trylinder(r=r-0.5,flat=outer_flat, h=h+overlap);
            }
            for(a=[0,120,240]) rotate(a+60)
                translate([0,outer_flat_r-cap_bottom_t-cap_gap-0.5,h+overlap/2])
                    sphere(r=cap_gap+1,$fn=12);
        }
        trylinder(r=outer_r-cap_bottom_t*2-cap_gap,flat=outer_flat,h=999,center=true);
    }
}

module actuator_column_cap(h=10){
    //the push-fit cap for an actuator column
    chamfer_angle=30;
    top_r=15/2;
    difference(){
        hull(){
            trylinder(r=outer_r,flat=outer_flat,h=overlap+1);
            cylinder(r=top_r,h=h);
        }
        
        //cut-out the inside
        sequential_hull(){
            translate([0,0,-0.5]) trylinder(r=outer_r-cap_bottom_t+1,flat=outer_flat);
            translate([0,0,0.5]) trylinder(r=outer_r-cap_bottom_t,flat=outer_flat);
            translate([0,0,overlap]) trylinder(r=outer_r-cap_bottom_t,flat=outer_flat);
            translate([0,0,overlap]) trylinder(r=outer_r-2*cap_bottom_t,flat=outer_flat);
            translate([0,0,h-1]) cylinder(r=top_r-1,h=d);
        }
        
        //screw hole
        cylinder(r=3/2*1.2,h=999,center=true);
        
        //indents for locating bumps
        intersection(){
            trylinder(r=outer_r-0.5,flat=outer_flat,h=overlap+1);
            
            for(a=[0,120,240]) rotate(a+60)
                translate([0,outer_flat_r-cap_bottom_t-cap_gap-0.5,overlap/2])
                    rotate([atan(1/sqrt(2)),60,0]) rotate(45) 
                        cube([2,2,2]*(cap_gap+1-0.5),center=true);
        }
    }
}
            
%cylinder(r=14/2,h=50);
actuator_column_base(14, $fn=24);
//translate([0,0,25]) actuator_column_cap(h=10,$fn=24);
translate([30,0,10]) mirror([0,0,1]) actuator_column_cap(h=10,$fn=24); 