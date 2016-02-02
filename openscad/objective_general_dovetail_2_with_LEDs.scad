use <utilities.scad>;

$fn=32;

///picamera lens
lens_outer_r=3.04+0.075; //outer radius of lens (tweaked down)
lens_aperture_r=2.2; //clear aperture of lens
lens_t=2.0; //thickness of lens
h=24; //was 28
//*/
/*//ball lens, 4mm sapphire
lens_outer_r=2+0.2;
lens_aperture_r=1.9;
lens_t=2;
h=24; //was 28
//*/
/*//asphere, 5.6mm diameter (nom)
lens_outer_r=5.5/2+0.2;
lens_aperture_r = 4/2;
lens_t=2.5;
h=24; //was 28
//*/
/*//blu ray lens
lens_outer_r=3.5/2+0.1;
lens_aperture_r = 2.6/2+0.1;
lens_t=0.3;
h=24; //was 28
//*/
/*//EO lens
lens_outer_r=12/2+0.4;
lens_aperture_r = 11/2+0.1;
lens_t=1.5;
h=20;
//*/

dovetail_h=14;
//neck_h=h-dovetail_h;
outer_r=5; //radius of tube
inner_r=5.5; //inner radius of bottom of tube
body_r=8;
n_leds=3;
led_angle=30;

neck_r = max( (body_r+lens_aperture_r)/2, lens_outer_r+1.5*cos(led_angle)+1);
neck_h = min(h-dovetail_h, (body_r-neck_r)/tan(led_angle));

n_cones=floor((h-lens_t)/2); //how many ridges to make
cone_h=(h-lens_t)/n_cones; //height of each ridge
cone_dr=cone_h/2; //change in radius over each cone
sample_z = h-lens_t+bottom_of_lens_to_sample;


objective_clip_w = 10;
//objective_clip_y = 6; //standard microscope
objective_clip_y = 16; //extra-large objective mount

d=0.05;


module clip_tooth(h){
	intersection(){
		cube([999,999,h]);
		rotate(-45) cube([1,1,1]*999*2);
	}
}

module objective_body(){
	r=0.5;
    corner=[objective_clip_w/2-1.5,objective_clip_y,0];
    difference(){
		union(){
			cylinder(r=body_r,h=h-neck_h); //body
			//translate([0,0,h-neck_h-d]) cylinder(r1=body_r, r2=neck_r,h=chamfer_h);
			translate([0,0,h-neck_h-d]) cylinder(r1=body_r,r2=neck_r,h=neck_h+d);
            
            //dovetail part
            reflect([1,0,0]) translate(corner+[sqrt(3)*r,-r,0]) hull() repeat([1,0,0],2) cylinder(r=r,h=dovetail_h);	
            hull() reflect([1,0,0]) translate(corner) rotate(45) translate([sqrt(3)*r,r,0]) repeat([1,0,0],2) cylinder(r=r,h=dovetail_h);
            //ensure it's joined to the objective body
            translate([-corner[0]-sqrt(3)*r-r-1,0,0]) cube([2*(corner[0]+sqrt(3)*r+r+1), objective_clip_y-r, dovetail_h]);
            hull() reflect([1,0,0]) translate(corner+[sqrt(3)*r/2,-r/2-d,dovetail_h/2]) rotate(45/2) cube([d, 6*r, dovetail_h],center=true);
		}
        
        //dovetail cut-out
		reflect([1,0,0]) translate(corner) cylinder(r=r,h=2*(h-neck_h),center=true);
		reflect([1,0,0]) translate(corner+[0,0,-d]) clip_tooth(h-neck_h);
	}
}

module objective(){
	difference(){
		objective_body();
	
		translate([0, 0, h-lens_t]) cylinder(r=lens_outer_r, h=999); //lens
	
		//clearance for beam, with light-trapping edges
		for(i = [0 : n_cones - 1]) assign(p = i/(n_cones - 1))
			translate([0, 0, i * cone_h - d]) 
				cylinder(r1=(1-p)*inner_r + p*(lens_aperture_r + cone_dr),
							r2=(1-p)*(inner_r - cone_dr) + p*lens_aperture_r,
							h=cone_h+2*d);
        
        //LEDs
        for(i=[0:n_leds]) rotate((i+0.5)*360/n_leds) translate([0,lens_outer_r+1.5/cos(led_angle),h]) rotate([led_angle,0,0]){
            cylinder(r=1.5*1.1,h=999,center=true); //LED body/beam
            translate([0,0,-3]){ //
                cylinder(r=2*1.1,h=1);
                translate([0,0,1-d]) cylinder(r1=2*1.1,r2=1.5*1.1,h=0.5,center=true);
            }
        }
	}
}


//intersection(){
//	objective();
//	translate([0,0,h-neck_h+2]) cylinder(r=999,h=999);
//}
difference(){
	objective();
//	translate([-lens_aperture_r,-999,h-lens_t-2]) cube([lens_aperture_r*2,999,1]);
}