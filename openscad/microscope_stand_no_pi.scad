use <microscope_stand.scad>;
use <utilities.scad>;

h=15;

module microscope_stand_no_pi(){
    difference(){
        union(){
            bucket_base_with_microscope_top(h=h);
        }
        
        mounting_holes();
        
    }
}

microscope_stand_no_pi();
