use <utilities.scad>;


//outer_r=8.5;   //square side length
//f=0.5; //feather amount
d=0.05; //small distance!


module camera_bits(){
	union(){
		translate([0,6.5+5,0]) cube([8.5,10,3],center=true);
		translate([7,10,0]) cube([4,3,2],center=true);
	}
}

module picam_push_fit(){
    // This uses four slightly flexible fingers to grip the
    // camera module.  It's designed to be subtracted from a
    // larger shape, and needs space above it.
    // it's often a bit too stiff, and tends to rotate the
    // camera slightly.  v2 is better (see below).
	assign(r=8-0.25) //un-flexed side length of camera box
	assign(finger_w=2) //width of flexure "fingers"
	assign(chamfer=0.75) //How much to shrink the bottom layer
	union(){
		//very tight cut-out for camera
		sequential_hull(){
			cube([r+chamfer*2,r+chamfer*2,d],center=true);
			cube([r,r,chamfer*2],center=true);
			cube([r,r,40],center=true);
		}
		for(a=[0:90:360]) rotate(a){
			translate([0,r/2-1,0.48]) cube([r/2+finger_w+1,1,20]);
			translate([r/2+finger_w,-r/2,-d]) cube([1,r,20]);
		}
		camera_bits();

		//screw holes for safety (M2 "threaded")
		reflect([1,0,0]) translate([21/2,0,0]) cylinder(r=1,h=10);
	}
}



module picam_push_fit_2( beam_length=15){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // It includes cut-outs for the components on the PCB and also a push-fit hole
    // for the camera module.  This uses flexible "fingers" to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.  You may find popping 
    // off the brown ribbon cable and removing the PCB first helps when extracting
    // the camera module again.
    camera = [8,8,3]; //size of camera box
	cw = camera[0]+1; //side length of camera box at bottom (slightly larger)
	finger_w = 1.5; //width of flexure "fingers"
	flex_l = 1; //width of flexible part
    hole_r = camera[0]/2-0.5;
	union(){
		//cut-out for camera
        hull(){
            translate([0,0,-d]) cube([cw+0.5,cw+0.5,d],center=true); //hole for camera
            translate([0,0,1]) cube([cw-0.5,cw-0.5,d],center=true); //hole for camera
        }
        rotate(180/16) cylinder(r=hole_r,h=20,center=true,$fn=16); //hole for light
        
        //looser cut-out for camera, with gripping "fingers" on 3 sides
        difference(){
            //cut-out big enough to include gripping fingers
            intersection(){
                translate([-cw/2-finger_w-flex_l,-cw/2-finger_w-flex_l,0.5])
                    cube([cw+2*finger_w+2*flex_l,
                        cw+finger_w+flex_l,
                        999]);
                //build up the roof gradually so we get a nice hole
                rotate(90) translate([0,0,camera[2]+1.5]) hole_from_bottom(r=hole_r,base_w=cw+2*finger_w+2*flex_l,h=beam_length - camera[2]-1.5);
            }
                
            //gripping "fingers" (NB we subtract these from the cut-out)
            for(a=[90:90:270]) rotate(a) hull(){
                translate([-cw/2+0.5,cw/2,0]) cube([cw-1,finger_w,d]);
                translate([-cw/2+1,camera[0]/2-0.1,camera[2]]) cube([cw-2,finger_w,d]);
            }
            //there's no finger on the top, so add a dimple on the fourth side
            hull(){
                translate([-cw/2+1,cw/2,2]) cube([cw-2,d,camera[2]-2]);
                translate([-cw/2+2,camera[1]/2,camera[2]-0.5]) cube([cw-4,d,0.5]);
            }
		}
        
		//ribbon cable at top of camera
        translate([0,(9.5+5)/2+cw/2-d,0]) cube([cw,9.5+5,4],center=true);
        //resistor/LED
		translate([7,10,0]) cube([4+2,3,2],center=true);
        translate([7+1,8.5,0.3]) cube([1,13,1]); //channel so we can see the LED
                //NB the LED channel is deliberately high to aid adhesion

		//screw holes for safety (M2 "threaded")
		reflect([1,0,0]) translate([21/2,0,0]) cylinder(r=1,h=10,center=true);
	}
}

//difference(){
//    translate([-12.5,-12+2.4,0]) cube([25,24,6]);
//    picam_push_fit_2();
//}

module picam_pcb_bottom(){
    // This is an approximate model of the pi camera PCB for the purposes of making
    // a slide-on cover.  NB z=0 is the bottom of the PCB, which is nominally 1mm thick.
    pcb = [25+0.5,24+0.5,1+0.3];
    socket = [pcb[0],6.0+0.5,2.7];
    components = [pcb[0]-3*2, pcb[1]-1-socket[1], 2];
    translate([0,2.4,0]) union(){ //NB the camera bit isn't centred!
        translate([0,0,pcb[2]/2]) cube(pcb,center=true); //the PCB
        translate([-components[0]/2,-pcb[1]/2+socket[1],-components[2]+d]) cube(components); //the little components
        //the ribbon cable socket
        translate([-socket[0]/2,-pcb[1]/2,-socket[2]+d]) cube(socket); //the ribbon cable socket
        translate([-components[0]/2,-pcb[1]/2,-0.5]) cube([components[0],socket[1]+0.5,0.5+d]); //pins protrude slightly further
        
        //mounting screws (NB could be extruded in -y so the cover can slide on)
        reflect([1,0,0]) mirror([0,0,1]) translate([21/2,-2.4,-d]){
            cylinder(r=2.5,h=10);
            cylinder(r=1.5,h=15,center=true); //screw might poke through the top...
        }
    }
}
translate([0,0,-1]) picam_pcb_bottom();
