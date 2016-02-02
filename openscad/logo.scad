use <utilities.scad>;

$fn=64;

module waterscope_logo(){
    difference(){
        //eye shape
        intersection(){
            translate([0,13,0]) cylinder(r=30,h=1);
            translate([0,-13,0]) cylinder(r=30,h=1);
        }
        
        //tear-drop shaped pupil
        difference(){
            translate([0,-((12-1)*sqrt(2)+1 - 12)/2,0]) hull(){
                cylinder(r=12,h=999,center=true);
                translate([0,(12-1)*sqrt(2),0])cylinder(r=1,h=999,center=true);
            }
            
            //tick
            translate([2,-11,0]) sequential_hull(){
                translate([-3,3,0]) cylinder(r=1,h=1);
                translate([0,0,0]) cylinder(r=1,h=1);
                translate([6,6,0]) cylinder(r=1,h=1);
            }
        }
    }
}

module logo_and_name(){
    union(){
        waterscope_logo();
        
        translate([30,-6,0]) linear_extrude(1){
            text("WaterScope", size=15, font="Calibri");
        }
    }
}

logo_and_name();