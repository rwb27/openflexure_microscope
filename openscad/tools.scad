use <utilities.scad>;

d=0.05;

pcb = [25+0.5,24+0.5,2]; //size of the picam PCB (+0.5mm so it fits)
camera_housing = [8.5,8.5,4]; //size of the plastic housing
camera_housing_y = 2.5; //shift of the camera housing from the centre
lens_unscrew_r = 5.5/2; //size of the bit we unscrew
    
module generous_camera_bits(){
	union(){
		translate([0,pcb[1]/4,0]) cube([camera_housing[1],pcb[1]/2+2*d,4],center=true);
		translate([9.5/2,5.5+4/2,0]) cube([9.5,4,2],center=true);
	}
}

module picam_holder(){
    // this little bit of plastic grips the plastic camera housing
    // and allows you to safely unscrew the lens
    // it protects the (surprisingly delicate) flex that connects the camera to the PCB.
    outer = pcb+[4,-0.5,camera_housing[2]]; //size of the tool
    difference(){
        translate([0,0,outer[2]/2]) cube(outer, center=true);
        
        //central hole for the camera housing
        translate([0,camera_housing_y,0]) cube(camera_housing + [0,0,999],center=true);
        
        //cut-outs for the other bits (cable etc.)
        translate([0,0,camera_housing[2]]) rotate([180,0,0])generous_camera_bits();
        
        //indent for PCB
        translate([0,0,outer[2]]) cube(pcb + [0,0,pcb[2]],center=true);
    
    }
}

module picam_lens_top_cutout(){
    // this generates a tall cylinder with splines on it, similar(ish)
    // to the raspberry pi lens.  You still need to squeeze it to grip
    // the lens, but it seems to work much better than just a cylinder
    wing_w = 2.7;
    union(){
        cylinder(r=4.9/2,h=999,center=true,$fn=16); //inner core
        intersection(){ //outer wings
            cylinder(r=5.5/2,h=999,$fn=16);
            for(a=[0:120:360]){
                rotate(a) translate([-wing_w/2,0,0]) cube([wing_w,999,999]);
            }
        }
    }
}

module picam_lens_pliers(){
    // A set of "pliers" to unscrew the raspberry pi camera lens
    handle = [5,30,4];
    flex_t = 1.5;
    
    module handle_frame(){
        //this puts things on the handle (which is rotated)
        reflect([1,0,0]) translate([0,-handle[0]/2,0]) rotate(7.5) 
            translate([-handle[0]/2,handle[0]/2,0]) children();
    }
    module handle_end(r=handle[0]/2){
        //this makes one end of the handle
        cylinder(r=r,h=handle[2],$fn=16);
    }
    
    difference(){
        union(){
            //curved end part
            intersection(){ //we only want the part at negative y
                hull() handle_frame() handle_end();
                translate([0,-999/2,0]) cube([1,1,1]*999,center=true);
            }
            
            //the two handles
           handle_frame() hull() repeat([0,handle[1],0],2) handle_end();
        }
        
        //cut-out for the flexure
        hull() handle_frame() cylinder(r=handle[0]/2-flex_t,h=999,center=true,$fn=16);
        
        //cut-out for the lens
        translate([0,handle[0]/2+lens_unscrew_r,1]) picam_lens_top_cutout();
    }
}

module hold_gear_10mm_higher(){
    union(){
        difference(){
            cylinder(r=6,h=10,$fn=24);
            cylinder(r=3,h=999,center=true,$fn=12);
            translate([-999,0,-999]) cube([1,1,1]*9999);
        }
        reflect([1,0,0]) translate([4.5,0,0]) hull()
            repeat([0,3,0],2) cylinder(r=1.5,h=10,$fn=12);
    }
}
hold_gear_10mm_higher();
//translate([pcb[0]/2+15,pcb[1]/2,0]) picam_holder();
//picam_lens_pliers();
