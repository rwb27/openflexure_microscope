/*

This file was put together by Graham Gibson, based on a part
by Hazen Babcock https://github.com/ZhuangLab/3D-printing/tree/master/nikon_filter_cube

That, in turn, borrowed from what I believe became the MCAD threads library.

I think everything in here can be considered GPL, but if I've misunderstood, I would be
very happy to be corrected.

-- Richard Bowman, July 2018

*/

$fn = 200;

// reverse trapezoid
module reverse_trapezoid(p0, p1, p2, p3, p4, p5, p6, p7)
{
	polyhedron(
		points = [p0, p1, p2, p3, p4, p5, p6, p7],
		faces = [[0,1,2,3],[0,4,5,1],[0,3,7,4],
				  [6,5,4,7],[6,2,1,5],[6,7,3,2]]);
}

// thread.
module inner_thread (radius = 12.9,
			          thread_height = 0.45,
				      thread_base_width = 0.6,
				      thread_top_width = 0.05,
				      thread_length = 6.5,
				      threads_per_mm = 0.635,
				      extra = -0.5,
				      overlap = 0.01)
{
	cylinder_radius = radius + thread_height;
	inner_diameter = 2.0 * 3.14159 * radius;
	number_divisions = 60;//Originally 180 - changed to 60 to reduce compiler time
	overshoot = extra * number_divisions;
	angle_step = 360.0/number_divisions;
	turns = thread_length/threads_per_mm;
	z_step = threads_per_mm/number_divisions;
	fudge = angle_step * overlap;

	p0 = [cylinder_radius * cos(-0.5 * (angle_step + fudge)),
         cylinder_radius * sin(-0.5 * (angle_step + fudge)),
         -0.5 * thread_base_width];
	p1 = [radius * cos(-0.5 * (angle_step + fudge)),
         radius * sin(-0.5 * (angle_step + fudge)),
         -0.5 * thread_top_width];
	p2 = [radius * cos(-0.5 * (angle_step + fudge)),
         radius * sin(-0.5 * (angle_step + fudge)),
         0.5 * thread_top_width];
   p3 = [cylinder_radius * cos(-0.5 * (angle_step + fudge)),
         cylinder_radius * sin(-0.5 * (angle_step + fudge)),
         0.5 * thread_base_width];
	p4 = [cylinder_radius * cos(0.5 * (angle_step + fudge)),
         cylinder_radius * sin(0.5 * (angle_step + fudge)),
         -0.5 * thread_base_width + z_step];
	p5 = [radius * cos(0.5 * (angle_step + fudge)),
         radius * sin(0.5 * (angle_step + fudge)),
         -0.5 * thread_top_width + z_step];
	p6 = [radius * cos(0.5 * (angle_step + fudge)),
         radius * sin(0.5 * (angle_step + fudge)),
         0.5 * thread_top_width + z_step];
	p7 = [cylinder_radius * cos(0.5 * (angle_step + fudge)),
         cylinder_radius * sin(0.5 * (angle_step + fudge)),
         0.5 * thread_base_width + z_step];

	difference(){
		union(){
			for(i = [-overshoot:(turns*number_divisions+overshoot)]){
			//for(i= [0:1]){
				rotate([0,0,i*angle_step])
				translate([0,0,i*z_step])
				reverse_trapezoid(p0, p1, p2, p3, p4, p5, p6, p7);
			}
		}
		translate([0,0,-2])
		cylinder(r = cylinder_radius+0.1, h = 2);
		translate([0,0,thread_length])
		cylinder(r = cylinder_radius+0.1, h = 2);
	}
}


module outer_thread (radius = 12.9,
			          thread_height = 0.45,
				      thread_base_width = 0.6,
				      thread_top_width = 0.05,
				      thread_length = 6.5,
				      threads_per_mm = 0.635,
				      extra = -0.5,
				      overlap = 0.01)
{
	cylinder_radius = radius + thread_height;
	inner_diameter = 2.0 * 3.14159 * radius;
	number_divisions = 60;//Originally 180 - changed to 60 to reduce compiler time
	overshoot = extra * number_divisions;
	angle_step = 360.0/number_divisions;
	turns = thread_length/threads_per_mm;
	z_step = threads_per_mm/number_divisions;
	fudge = angle_step * overlap;

	p0 = [radius * cos(-0.5 * (angle_step + fudge)),
         radius * sin(-0.5 * (angle_step + fudge)),
         -0.5 * thread_base_width];
	p1 = [cylinder_radius * cos(-0.5 * (angle_step + fudge)),
         cylinder_radius * sin(-0.5 * (angle_step + fudge)),
         -0.5 * thread_top_width];
	p2 = [cylinder_radius * cos(-0.5 * (angle_step + fudge)),
         cylinder_radius * sin(-0.5 * (angle_step + fudge)),
         0.5 * thread_top_width];
   p3 = [radius * cos(-0.5 * (angle_step + fudge)),
         radius * sin(-0.5 * (angle_step + fudge)),
         0.5 * thread_base_width];
	p4 = [radius * cos(0.5 * (angle_step + fudge)),
         radius * sin(0.5 * (angle_step + fudge)),
         -0.5 * thread_base_width + z_step];
	p5 = [cylinder_radius * cos(0.5 * (angle_step + fudge)),
         cylinder_radius * sin(0.5 * (angle_step + fudge)),
         -0.5 * thread_top_width + z_step];
	p6 = [cylinder_radius * cos(0.5 * (angle_step + fudge)),
         cylinder_radius * sin(0.5 * (angle_step + fudge)),
         0.5 * thread_top_width + z_step];
	p7 = [radius * cos(0.5 * (angle_step + fudge)),
         radius * sin(0.5 * (angle_step + fudge)),
         0.5 * thread_base_width + z_step];

	difference(){
		union(){
			for(i = [-overshoot:(turns*number_divisions+overshoot)]){
			//for(i= [0:1]){
				rotate([0,0,i*angle_step])
				translate([0,0,i*z_step])
				reverse_trapezoid(p0, p1, p2, p3, p4, p5, p6, p7);
			}
		}
		translate([0,0,-2])
		cylinder(r = cylinder_radius+0.1, h = 2);
		translate([0,0,thread_length])
		cylinder(r = cylinder_radius+0.1, h = 2);
	}
}