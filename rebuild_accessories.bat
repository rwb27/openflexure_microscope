rem "compiling feet, gears, and sample clips"

"C:\Program Files\OpenSCAD\openscad.com" -o builds/feet.stl  OpenSCAD/feet.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/feet_tall.stl -D foot_height=26  OpenSCAD/feet.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/gears.stl OpenSCAD/gears.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/sample_clips.stl OpenSCAD/sample_clips.scad

rem "compiling elastic band tools"
"C:\Program Files\OpenSCAD\openscad.com" -o builds/actuator_assembly_tools.stl OpenSCAD/actuator_assembly_tools.scad
