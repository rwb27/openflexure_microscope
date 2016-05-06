/*

A box for holding lots of little glass or silicon samples, 10-20mm square and 1-3mm thick.
Most of the solutions for this I've seen either require the bits to be an exact size, or
they lay them flat which is bad (partly because the flat surfaces touch the top/bottom
and partly because they're hard to insert/remove).

This box packs them closer, but avoids these problems by using curved surfaces - so the little bits of glass can't get stuck.

(c) Richard Bowman 2016, released under CERN Open Hardware License.

*/

use <utilities.scad>;
d = 0.05;
$fn = 64;

unit_padding = [1,2,0]; //extra space around each sample
holder_padding = [0.5,1,1]; //extra material at the edges of the sample holders
box_space = [4,0,2]; //spacing between sample holders in the box to allow for extractor tool
box_wall = [2,2,1]; //thickness of the outer box wall
holder_clearance = 0.7; //extra space around sample holder
lid_clearance = 0.4; //extra space between box and lid
lid_lip = 4; //height of the lip around the lid
lid_t = [1.4,1.4,1]; //thickness of lid

// this calculates the size needed per sample
function diag(vec) = [[vec[0],0,0],[0,vec[1],0],[0,0,vec[2]]];
function unit_size(sample) = sample + [sample[1],0,0] + unit_padding;
function holder_size(N, sample) = unit_size(sample) * diag([1,N,1]) + holder_padding * 2 - [0,0,holder_padding[2]+lid_lip];

module sample_cutout(sample=[15, 1, 19]){
    intersection(){
        //crop to one unit
        translate([0,0,(sample + unit_padding)[2]/2]) 
            cube(sample+[sample[1],0,0]+unit_padding+[d,d,d], center=true); 
        
        hull(){
            reflect([1,0,0]) translate([-sample[0]/2,0,0]){
                cylinder(d=sample[1], h=sample[2], $fn=8);
                reflect([0,1,0]) rotate(30) cube([sample[0]/2, sample[1]/2, sample[2]]);
            }
        }
    }
}

module sample_holder(N, sample){
    //A small box for holding a number of glass samples.
    //There's fittings at either end for a handle with which the samples can be manipulated.
    //The bottom is open to allow drainage of solvents.
    unit = unit_size(sample);
    body = holder_size(N, sample);
    difference(){
        translate([0,0,body[2]/2-holder_padding[2]]) cube(body, center=true);
        
        //the samples
        repeat([0,unit[1],0], N, center=true) sample_cutout(sample+[0,0,1]);
        
        //drainage slot
        cube([unit[0]-8, unit[1]*N, 999],center=true);
    }
}

module sample_holder_box(N=[2,12], sample=[15,1,19]){
    // A sample box for holding lots of small bits of glass
    holder = holder_size(N[1], sample);
    void = holder * diag([N[0], 1, 1]) + diag([N[0]+1,0,1]) * box_space + [0,2,0] * holder_clearance + [0,0,lid_lip];
    body = void + diag([2,2,1]) * box_wall;
    lid_t = box_wall/2 + [1,1,1]*lid_clearance/2; //how much space to allow for the lid
    difference(){
        union(){
            translate([0,0,(body[2]-lid_lip-box_wall[0]-box_space[0])/2]) cube(body - [0,0,lid_lip], center=true);
            translate([0,0,(body[2]-box_wall[0]-box_space[0])/2]) cube(body - lid_t*diag([2,2,0]), center=true);
        }
        
        //cutouts for sample holders
        repeat([holder[0]+box_space[0],0,0], N[0], center=true) 
            translate(-diag(holder)*[1,1,0]/2-[1,1,0]*holder_clearance) cube(holder + [2,2,999]*holder_clearance);
        
        //cutout for tongs
        translate([0,0,void[2]/2-box_space[2]]) cube(void - [0,8,0], center=true);
        
        //cutout for inner lip of lid
        translate([0,0,void[2]/2 + holder[2]]) cube(void, center=true);
    }
}

module sample_box_lid(N=[2,12], sample=[15,1,19]){
    // A lid for the above sample box
    holder = holder_size(N[1], sample);
    void = holder * diag([N[0], 1, 1]) + diag([N[0]+1,0,1]) * box_space + [0,2,0] * holder_clearance + [0,0,lid_lip];
    body = void + diag([2,2,1]) * box_wall;
    lid_t = box_wall/2 - [1,1,1]*lid_clearance/2; //how much space to allow for the lid
    clearance = 0.4;
    union(){
        translate([0,0,box_wall[2]/2]) cube(diag([1,1,0]) * body + [0,0,box_wall[2]], center=true); //flat top
        
        for(outer=[body, void - [2,2,0]*lid_clearance]) difference(){
            translate([0,0,-lid_lip/2+d]) cube(diag([1,1,0]) * outer + [0,0,lid_lip+2*d], center=true);
            cube(diag([1,1,0]) * (outer - 2*lid_t) + [0,0,999], center=true);
        }
    }
}

//sample_cutout();

N=[2,12];
sample = [15.5,1.5,18];

//sample_holder(N[1], sample);
//sample_holder_box(N, sample);
rotate([180,0,0]) 
//translate([40,0,0]) 
sample_box_lid(N);