/*
  Useful settings/parameters for the OpenFlexure fibre stage
*/
version_numstring = "0.2.0";
stage = [37,20,5]; //dimensions of stage part

// Range of travel is lever length * flex_a
xy_lever = 10;
z_lever = 10;

//mechanical reduction settings
xy_stage_reduction = 3; //ratio of sample motion to lower shelf motion
xy_reduction = 5; //mechanical reduction from screw to sample
z_reduction = 5; //mechanical reduction for Z

// Flexure dimensions - good for PLA and ~0.5mm nozzle
zflex = [6, 1.5, 0.75]; //dimensions of flexure
xflex = [5,5.5,5]; //default bounding box of x flexure
xflex_t = 1; //thickness of bendy bit in x
flex_a = 0.1; //angle through which flexures are bent, radians
dz = 0.5; //thickness before a bridge is printable-on

xy_travel = xy_lever * flex_a; //max. travel in X or Y
xy_bottom_travel = xy_travel * xy_stage_reduction; //travel of bottom of XY stage
xy_actuator_pivot_w = 25; //width of the hinge for the actuating lever

pushstick = [5,38,5]; //cross-section of XY "push stick"
pw = pushstick[0]; //because this is used in a lot of places...

wall_t = 1.6;
d=0.05;

// Height of the bridging "shelves" in the XY axis "table" structure
shelf_z1 = xy_lever * xy_stage_reduction;
shelf_z2 = shelf_z1 + xy_lever;

// Z axis geometry
z_travel = z_lever * flex_a; //max. travel in Z
z_stage_base_y = -stage[1]/2-xy_bottom_travel; //position of the flexure edge of the Z stage
z_stage_base_w = stage[0] + 2*zflex[1] - 2*xy_bottom_travel - 2; //width of the flexure edge of the Z stage
z_anchor_bottom_y = z_stage_base_y - z_lever - zflex[1]; // lower Z stage end of the fixed base
z_actuator_pivot_y = stage[1]/2 + zflex[1] + zflex[0] + xy_bottom_travel + wall_t;
z_actuator_pivot_w = 20; //width of the hinge for the Z actuator lever
z_pushstick_z = shelf_z1 - pw - 2.5; // height of the Z pushstick

// Mounting stuff
mounting_bolts = [[-1,0,0],[0,-1,0],[1,0,0]]*25*1*1.41; //bolt to the bench
platform_z = shelf_z2 + stage[2] + 7;
fixed_platform_standoff = 10;
fixed_platform = [50,30,4];
platform_gap = xy_travel + 1;
casing_top = shelf_z2 + stage[2] - z_travel; //top of the wall