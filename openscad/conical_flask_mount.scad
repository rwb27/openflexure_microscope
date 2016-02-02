use <utilities.scad>;

// Mount for the light sensor to be used with conical flask

flask_max_r = 63.5/2; //maximum radius of flask
flask_ramp_h = 60; //height of sloping part of flask
flask_min_r = 22/2; //minimum radius of flask
flask_roc = 8.5; //radius of curvature of bottom
flask_neck_h = 32;

pcb_w = 20.4-0.8;
pcb_t = 1.5;
led_h = 1.3-0.3;
pcb_h = 20.8;

w = pcb_w + 2*3;
b = 25;
h = pcb_h - 5;

d=0.05;
$fn=32;

module conical_flask(){
    union(){
        minkowski(){
            $fn=32;
            translate([0,0,flask_roc]) cylinder(r1=flask_max_r-flask_roc,r2=flask_min_r-flask_roc,h=flask_ramp_h);
            sphere(r=flask_roc);
        }
        translate([0,0,flask_ramp_h+flask_roc-d]) cylinder(r=flask_min_r,h=flask_neck_h);
    }
}

module pcb_holder(){
    difference(){
        translate([-w/2,flask_max_r-b/2,0]) cube([w,b,h]);
        
        translate([-5,0,0]) #conical_flask();
        
        // cutout for PCB
        hull() reflect([1,0,0]) translate([-pcb_w/2+pcb_t/2-0.3,flask_max_r + led_h + pcb_t/2,0]) 
            rotate(45) cube([1,1,999] * pcb_t*sqrt(2), center=true);
        
        // cutout for optical access
        translate([0,flask_max_r,10]) cube([pcb_w - 8, (led_h+pcb_t) * 2, 7], center=true);
    }
}

module led_holder(){
    w = 15;
    h = 15;
    b = 25;
    rotate(180) difference(){
        translate([-w/2,flask_max_r-b/2,0]) cube([w,b,h]);
        
        #conical_flask();
        
        
        // cutout for LED
        translate([0,0,10]) cylinder_with_45deg_top(r=3/2*1.15, h=999, center=true, extra_height=0.3);
        translate([0,flask_max_r+5,10]) cylinder_with_45deg_top(r=4.5/2*1.15, h=999, extra_height=0.3);
    }
}

translate([5,0,0]) pcb_holder();
//led_holder();