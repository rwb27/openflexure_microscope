use <utilities.scad>;

chars = ["0","1","2","3","4","5","6","7","8","9"];

for(i=[1:5]){
    translate([0,i*15,0]) linear_extrude(2) text(chars[i],13,font="Arial:style=Bold");
}