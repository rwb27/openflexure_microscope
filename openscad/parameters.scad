/*
  Useful settings/parameters for the OpenFlexure fibre stage
*/

stage = [37,20,5]; //dimensions of stage part
zflex = [6, 1.5, 0.75]; //dimensions of flexure
xflex = [5,5.5,5]; //default bounding box of x flexure
xflex_t = 1; //thickness of bendy bit in x
flex_a = 0.1; //angle through which flexures are bent, radians
dz = 0.5; //thickness before a bridge is printable-on
xy_stage_reduction = 3; //ratio of sample motion to lower shelf motion
xy_reduction = 5; //mechanical reduction from screw to sample
xy_lever = 10;
xy_travel = xy_lever * flex_a;
xy_bottom_travel = xy_travel * xy_stage_reduction;
xy_column_l = 22; //final part of XY actuators - to allow nut to stay straight
pushstick = [5,35,5]; //cross-section of XY "push stick"
pw = pushstick[0]; //because this is used in a lot of places...
z_lever = 10;
z_travel = z_lever * flex_a;
z_reduction = 5; //mechanical reduction for Z
wall_t = 1.6;
owall_h = pushstick[2] + 1.5 + 1;
d=0.05;

shelf_z1 = xy_lever * xy_stage_reduction;
shelf_z2 = shelf_z1 + xy_lever;

actuator_cross_y = (pw+pushstick[1])*sqrt(2); //if the pushsticks were infinitely long, they'd cross here.
pushstick_anchor_w = 2*(pushstick[1]+pw - xy_lever*xy_stage_reduction - xflex[1]/2); //side length of the square anchor point for the XY pushsticks
z_stage_tip_y = pw/sqrt(2) + xy_bottom_travel * sqrt(2); //position of the pointy end of the Z stage
z_triangle_d = 10; // size of the base of the Z stage
z_anchor_bottom_y = z_stage_tip_y + z_triangle_d + z_lever + zflex[1]; // lower Z stage end of the fixed base

z_pushstick_z = shelf_z1 - pw - 1.5; // height of the Z pushstick
z_pushstick_l = actuator_cross_y - z_anchor_bottom_y + zflex[1];// - pw - zflex[1]; //length of z pushstick, incl. flexures
za_pivot = [pushstick_anchor_w/sqrt(2) + 1.5, z_anchor_bottom_y + z_pushstick_l - zflex[1], 0]; // position of the fixed end of the Z actuator (after, so +y of, the flexure)
z_nut_y = za_pivot[1] + z_lever * z_reduction; // y position of the acutating nut for the Z axis.

xy_column_pivot = [0,actuator_cross_y,0] + [1, -1, 0]*(xy_lever * xy_reduction + pushstick_anchor_w/2 + xflex[1]/2)/sqrt(2); //where the XY "columns" join the actuator
wall_near_xy_column_pivot = xy_column_pivot + [0, (pw/2 + 1.5 + wall_t/2)*sqrt(2), 0] + [1,1,0]*xy_travel*xy_reduction/sqrt(2) + [-1,1,0] * (10-pw)/2/sqrt(2);
