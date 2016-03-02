use <utilities.scad>;

sep = 26;
$fn=24;

difference(){
    hull(){
        reflect([1,0,0]) translate([sep/2,0,0]) cylinder(r=4,h=6);
    }
    reflect([1,0,0]) translate([sep/2,0,1]){
       cylinder(r=3/2*1.15,999,center=true);
       cylinder(r=3*1.15,h=999);
    }
} 
    